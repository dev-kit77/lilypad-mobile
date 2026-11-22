import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' show runWithClient;
import 'package:lilypad/services/background.dart';
import 'package:lilypad/services/cache.dart';
import 'package:lilypad/services/content.dart';
import 'package:lilypad/services/geolocation.dart';
import 'package:lilypad/services/session.dart';
import 'package:location_platform_interface/location_platform_interface.dart';

import '../support/content_fixtures.dart';
import '../support/fake_location_platform.dart';
import '../support/geolocation_fixtures.dart';
import '../support/http_stub.dart';

const String _pluginPath = 'com.transistorsoft/flutter_background_fetch';
const String _methodChannelName = '$_pluginPath/methods';
const String _eventChannelName = '$_pluginPath/events';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final LocationPlatform originalPlatform = LocationPlatform.instance;

  final StubClient api = StubClient();
  final StubClient geocoder = StubClient();

  ///captures everything the service prints so tests can assert on logs.
  final List<String> logs = <String>[];

  ///the zone the service is initialised in. background callbacks inherit it,
  ///which keeps their logs visible to every test. lines are recorded for
  ///assertions and forwarded so they still appear in the test output.
  final Zone appZone = Zone.current.fork(
    specification: ZoneSpecification(
      print: (self, parent, zone, line) {
        logs.add(line);
        parent.print(zone, line);
      },
    ),
  );

  late FakeLocationPlatform platform;

  final TestDefaultBinaryMessenger messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  int configureStatus = 2;
  final List<Map<String, Object?>> configureCalls = <Map<String, Object?>>[];
  final List<String> finishedTasks = <String>[];
  Completer<void>? finishGate;

  // Stand in for the native side of the background fetch plugin.
  messenger.setMockMethodCallHandler(const MethodChannel(_methodChannelName), (
    MethodCall call,
  ) async {
    switch (call.method) {
      case 'configure':
        configureCalls.add(
          Map<String, Object?>.from(call.arguments as Map<Object?, Object?>),
        );
        return configureStatus;
      case 'finish':
        final String taskId = call.arguments as String;
        finishedTasks.add(taskId);
        if (finishGate != null && !finishGate!.isCompleted) {
          finishGate!.complete();
        }
        return null;
      default:
        return null;
    }
  });

  // The plugin subscribes to its event channel while configuring. Answering
  // listen/cancel is enough; events are injected with handlePlatformMessage.
  messenger.setMockMethodCallHandler(
    const MethodChannel(_eventChannelName),
    (MethodCall call) async => null,
  );

  setUp(() async {
    FlutterSecureStorage.setMockInitialValues(<String, String>{});
    await SessionService.invalidate();
    CacheService.clear();
    GeolocationService.clear();

    api.reset();
    geocoder.reset();

    logs.clear();
    configureCalls.clear();
    finishedTasks.clear();
    configureStatus = 2;
    finishGate = null;

    platform = FakeLocationPlatform();
    LocationPlatform.instance = platform;
  });

  tearDown(() {
    LocationPlatform.instance = originalPlatform;
    platform.controller.close();
  });

  ///runs work with the app's HTTP client redirected at the stub.
  Future<T> inAppZone<T>(Future<T> Function() body) =>
      appZone.run(() => runWithClient(body, () => api));

  ///configures the background service under test.
  Future<void> initService() => inAppZone(BackgroundService.init);

  ///gives the geolocation service a cached location in Toronto.
  Future<void> givenLocation() async {
    platform.lastKnownLocation = at(43.6532, -79.3832);
    geocoder.queueJson(toronto());
    await appZone.run(
      () => runWithClient(GeolocationService.init, () => geocoder),
    );
  }

  ///loads a nearby feed as if it had been fetched earlier in the session.
  Future<void> givenFeed({
    String id = 'seed',
    String time = '2026-01-01T12:00:00.000Z',
  }) async {
    api.queueJson(<String, Object>{
      'posts': <Object>[postJson(id: id, time: time)],
      'replies': <Object>[],
    });

    await inAppZone(ContentService.fetchFeed);
  }

  ///delivers a background-fetch event through the plugin's event channel.
  Future<void> emitEvent(String taskId, {bool timeout = false}) async {
    final ByteData data = const StandardMethodCodec().encodeSuccessEnvelope(
      <String, Object>{'taskId': taskId, 'timeout': timeout},
    );
    await messenger.handlePlatformMessage(_eventChannelName, data, null);
  }

  ///delivers an event and waits for the service to report the task finished.
  Future<void> runEvent(String taskId, {bool timeout = false}) async {
    finishGate = Completer<void>();
    await emitEvent(taskId, timeout: timeout);
    await finishGate!.future.timeout(const Duration(seconds: 5));
  }

  bool logged(String message) =>
      logs.any((String line) => line.contains(message));

  void queueHttpError(int statusCode, {String? error}) {
    api.queueResponse(
      StubResponse(
        statusCode,
        headers: const <String, String>{'content-type': 'application/json'},
        body: jsonEncode(<String, Object?>{'error': ?error}),
      ),
    );
  }

  group('configure', () {
    test('configures background fetch with the expected options', () async {
      await initService();

      expect(configureCalls, hasLength(1));
      final Map<String, Object?> config = configureCalls.single;
      expect(config, containsPair('minimumFetchInterval', 15));
      expect(config, containsPair('stopOnTerminate', false));
      expect(config, containsPair('startOnBoot', true));
      expect(config, containsPair('enableHeadless', true));
    });

    test('logs a message according to the configure status', () async {
      const Map<int, String> expectations = <int, String>{
        2: 'Background Service Enabled',
        1: 'explicitly disabled',
        0: 'unavailable and the user cannot enable',
      };

      for (final MapEntry<int, String> expectation in expectations.entries) {
        //clear the log so each iteration only inspects its own output.
        logs.clear();
        configureStatus = expectation.key;

        await initService();

        expect(
          logged(expectation.value),
          isTrue,
          reason: 'status ${expectation.key} should log "${expectation.value}"',
        );
      }

      //an unknown status should not log anything about the status.
      logs.clear();
      configureStatus = 7;

      await initService();

      expect(logged('Background fetcher configure status'), isFalse);
    });
  });

  group('fetch events', () {
    test(
      'logs, refreshes the feed without cache, and finishes the task',
      () async {
        await initService();
        await givenLocation();
        await givenFeed(time: '2026-01-01T12:00:00.000Z');

        api.queueJson(<String, Object>{
          'posts': <Object>[
            postJson(id: 'new', time: '2026-02-01T12:00:00.000Z'),
          ],
          'replies': <Object>[],
        });

        await runEvent('fetch-1');

        expect(logged('Background event received: fetch-1'), isTrue);
        expect(finishedTasks, equals(<String>['fetch-1']));
        expect(api.requests, hasLength(2));
        expect(
          api.requests.last.request.url.toString(),
          equals(
            'http://localhost:3000/api/feed-spatial?lat=43.6532&lon=-79.3832',
          ),
        );
        expect(ContentService.latest, equals(DateTime.utc(2026, 2, 1, 12)));
        expect(logged('send notification'), isTrue);
      },
    );

    test('does not notify when the refreshed feed has no newer post', () async {
      await initService();
      await givenLocation();
      await givenFeed(time: '2026-01-01T12:00:00.000Z');

      api.queueJson(<String, Object>{
        'posts': <Object>[
          postJson(id: 'seed', time: '2026-01-01T12:00:00.000Z'),
        ],
        'replies': <Object>[],
      });

      await runEvent('fetch-2');

      expect(api.requests, hasLength(2));
      expect(logged('send notification'), isFalse);
    });

    test(
      'logs the failure and finishes the task when the refresh fails',
      () async {
        await initService();
        await givenLocation();
        await givenFeed();
        queueHttpError(500, error: 'INTERNAL_SERVER');

        await runEvent('fetch-fail');

        expect(
          logged('Background event failed to fetch feed: fetch-fail'),
          isTrue,
        );

        //the catch logs the failure, finishes the task, and returns.
        expect(finishedTasks, equals(<String>['fetch-fail']));
      },
    );

    test('logs a timeout and finishes the task without fetching', () async {
      await initService();

      await runEvent('timeout-1', timeout: true);

      expect(logged('Background event timeout: timeout-1'), isTrue);
      expect(finishedTasks, equals(<String>['timeout-1']));
      expect(api.requests, isEmpty);
    });
  });
}
