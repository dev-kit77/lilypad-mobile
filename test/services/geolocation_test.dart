import 'dart:async';
import 'dart:convert';

import 'package:geocoder_pro/geocoder_pro.dart' show NetworkException;
import 'package:http/http.dart';
import 'package:lilypad/services/geolocation.dart';
import 'package:location_platform_interface/location_platform_interface.dart';
import 'package:test/test.dart';

/// A canned geocoder response for GeocoderStub to return.
class StubResponse {
  StubResponse(this.body, {this.statusCode = 200});

  final String body;
  final int statusCode;
}

/// Stands in for the HTTP client the geocoder creates internally.
class GeocoderStub extends BaseClient {
  final List<Uri> requests = <Uri>[];
  final List<StubResponse> _responses = <StubResponse>[];

  void queueJson(Object body) => _responses.add(StubResponse(jsonEncode(body)));

  void queueStatus(int statusCode) =>
      _responses.add(StubResponse('', statusCode: statusCode));

  void reset() {
    requests.clear();
    _responses.clear();
  }

  @override
  Future<StreamedResponse> send(BaseRequest request) async {
    requests.add(request.url);

    if (_responses.isEmpty) {
      throw StateError(
        'GeocoderStub received a request for ${request.url} but no response was queued for it.',
      );
    }

    final StubResponse response = _responses.removeAt(0);
    final List<int> bytes = utf8.encode(response.body);

    return StreamedResponse(
      Stream<List<int>>.value(bytes),
      response.statusCode,
      contentLength: bytes.length,
      headers: const <String, String>{'content-type': 'application/json'},
    );
  }
}

/// Replaces the method-channel location implementation with an in-memory one.
class FakeLocationPlatform extends LocationPlatform {
  LocationData? lastKnownLocation;
  LocationData? currentLocation;
  PermissionStatus permissionStatus = PermissionStatus.granted;
  PermissionStatus permissionStatusAfterRequest = PermissionStatus.granted;

  int getLocationCalls = 0;
  int hasPermissionCalls = 0;
  int requestPermissionCalls = 0;
  int changeSettingsCalls = 0;
  int enableBackgroundModeCalls = 0;
  int requestServiceCalls = 0;

  LocationAccuracy? accuracy;
  int? interval;
  double? distanceFilter;
  bool? backgroundModeEnabled;

  final StreamController<LocationData> controller =
      StreamController<LocationData>.broadcast();

  @override
  Future<LocationData?> getLastKnownLocation() async => lastKnownLocation;

  @override
  Future<LocationData> getLocation() async {
    getLocationCalls++;
    return currentLocation ??
        (throw StateError('No current location configured'));
  }

  @override
  Future<PermissionStatus> hasPermission() async {
    hasPermissionCalls++;
    return permissionStatus;
  }

  @override
  Future<PermissionStatus> requestPermission() async {
    requestPermissionCalls++;
    return permissionStatusAfterRequest;
  }

  @override
  Future<bool> changeSettings({
    LocationAccuracy? accuracy,
    int? interval,
    double? distanceFilter,
    bool? pausesLocationUpdatesAutomatically,
    int? backgroundInterval,
  }) async {
    changeSettingsCalls++;
    this.accuracy = accuracy;
    this.interval = interval;
    this.distanceFilter = distanceFilter;
    return true;
  }

  @override
  Future<bool> enableBackgroundMode({
    bool? enable = true,
    bool requireBackgroundPermission = true,
  }) async {
    enableBackgroundModeCalls++;
    backgroundModeEnabled = enable;
    return true;
  }

  @override
  Future<bool> requestService() async {
    requestServiceCalls++;
    return true;
  }

  @override
  Stream<LocationData> get onLocationChanged => controller.stream;
}

/// Builds a [LocationData] with nothing but the coordinates filled in.
LocationData at(double latitude, double longitude) => LocationData.fromMap(
  <String, dynamic>{'latitude': latitude, 'longitude': longitude},
);

/// Builds a Nominatim reverse-geocoding response.
///
/// [boundingBox] is ordered the way Nominatim returns it:
/// south, north, west, east.
Map<String, dynamic> nominatimResult({
  required int placeId,
  required String displayName,
  required double latitude,
  required double longitude,
  required String city,
  required String state,
  required String country,
  required String countryCode,
  required String postcode,
  required String houseNumber,
  required String road,
  required String suburb,
  required String county,
  List<double>? boundingBox,
}) => <String, dynamic>{
  'place_id': placeId,
  'lat': latitude.toString(),
  'lon': longitude.toString(),
  'display_name': displayName,
  if (boundingBox != null)
    'boundingbox': boundingBox.map((double d) => d.toString()).toList(),
  'address': <String, dynamic>{
    'house_number': houseNumber,
    'road': road,
    'suburb': suburb,
    'city': city,
    'county': county,
    'state': state,
    'postcode': postcode,
    'country': country,
    'country_code': countryCode.toLowerCase(),
  },
};

/// Toronto, with a bounding box around the city.
Map<String, dynamic> toronto({
  bool withBounds = true,
  String displayName = 'Toronto, Ontario, Canada',
}) => nominatimResult(
  placeId: 269367963,
  displayName: displayName,
  latitude: 43.6532,
  longitude: -79.3832,
  city: 'Toronto',
  state: 'Ontario',
  country: 'Canada',
  countryCode: 'CA',
  postcode: 'M5H 2N2',
  houseNumber: '100',
  road: 'King Street West',
  suburb: 'Downtown Toronto',
  county: 'Toronto Division',
  boundingBox: withBounds ? <double>[43.58, 43.85, -79.64, -79.11] : null,
);

/// Vancouver, with a bounding box around the city.
Map<String, dynamic> vancouver({bool withBounds = true}) => nominatimResult(
  placeId: 162443612,
  displayName: 'Vancouver, British Columbia, Canada',
  latitude: 49.2827,
  longitude: -123.1207,
  city: 'Vancouver',
  state: 'British Columbia',
  country: 'Canada',
  countryCode: 'CA',
  postcode: 'V6B 1A1',
  houseNumber: '800',
  road: 'West Georgia Street',
  suburb: 'Downtown Vancouver',
  county: 'Metro Vancouver Regional District',
  boundingBox: withBounds ? <double>[49.19, 49.31, -123.27, -123.02] : null,
);

void main() {
  final LocationPlatform originalPlatform = LocationPlatform.instance;

  late FakeLocationPlatform platform;
  late GeocoderStub geocoder;

  setUp(() {
    GeolocationService.clear();

    platform = FakeLocationPlatform();
    LocationPlatform.instance = platform;

    geocoder = GeocoderStub();
  });

  tearDown(() {
    LocationPlatform.instance = originalPlatform;
    platform.controller.close();
  });

  /// Runs GeolocationService.init with the geocoder stub injected.
  Future<void> init() => runWithClient(GeolocationService.init, () => geocoder);

  /// Runs GeolocationService.requestUpdate with the geocoder stub injected.
  Future<void> requestUpdate() =>
      runWithClient(GeolocationService.forceUpdate, () => geocoder);

  /// Pushes a location through the service's location stream.
  Future<void> emit(LocationData location) async {
    platform.controller.add(location);
    await pumpEventQueue();
  }

  group('before initialisation', () {
    test('reports an unknown locale and no coordinates', () {
      expect(GeolocationService.locale, equals('Unknown, The Void'));
      expect(
        GeolocationService.location,
        equals(<String, double?>{'lat': null, 'lon': null}),
      );
    });
  });

  group('init without a cached location', () {
    test('does not geocode anything', () async {
      await init();

      expect(geocoder.requests, isEmpty);
      expect(
        GeolocationService.location,
        equals(<String, double?>{'lat': null, 'lon': null}),
      );
      expect(GeolocationService.locale, equals('Unknown, The Void'));
    });

    test('configures balanced background updates', () async {
      await init();

      expect(platform.changeSettingsCalls, equals(1));
      expect(platform.accuracy, equals(LocationAccuracy.balanced));
      expect(platform.interval, equals(30000));
      expect(platform.distanceFilter, equals(50));
      expect(platform.enableBackgroundModeCalls, equals(1));
      expect(platform.backgroundModeEnabled, isTrue);
      expect(platform.requestServiceCalls, equals(1));
      expect(platform.controller.hasListener, isTrue);
    });
  });

  group('permissions', () {
    test('does not request permission when it is already granted', () async {
      await init();

      expect(platform.hasPermissionCalls, equals(1));
      expect(platform.requestPermissionCalls, equals(0));
    });

    test('requests permission when it is missing', () async {
      platform.permissionStatus = PermissionStatus.denied;
      platform.permissionStatusAfterRequest = PermissionStatus.granted;

      await init();

      expect(platform.requestPermissionCalls, equals(1));
      expect(platform.changeSettingsCalls, equals(1));
      expect(platform.controller.hasListener, isTrue);
    });

    test('continues when only limited permission is granted', () async {
      platform.permissionStatus = PermissionStatus.denied;
      platform.permissionStatusAfterRequest = PermissionStatus.grantedLimited;

      await init();

      expect(platform.requestPermissionCalls, equals(1));
      expect(platform.changeSettingsCalls, equals(1));
      expect(platform.accuracy, equals(LocationAccuracy.low));
      expect(platform.enableBackgroundModeCalls, equals(1));
      expect(platform.requestServiceCalls, equals(1));
      expect(platform.controller.hasListener, isTrue);
    });

    test(
      'stops before configuring anything when permission is denied',
      () async {
        platform.permissionStatus = PermissionStatus.denied;
        platform.permissionStatusAfterRequest = PermissionStatus.denied;

        await init();

        expect(platform.requestPermissionCalls, equals(1));
        expect(platform.changeSettingsCalls, equals(0));
        expect(platform.enableBackgroundModeCalls, equals(0));
        expect(platform.requestServiceCalls, equals(0));
        expect(platform.controller.hasListener, isFalse);
      },
    );

    test('stops when permission is denied forever', () async {
      platform.permissionStatus = PermissionStatus.deniedForever;
      platform.permissionStatusAfterRequest = PermissionStatus.deniedForever;

      await init();

      expect(platform.requestPermissionCalls, equals(1));
      expect(platform.changeSettingsCalls, equals(0));
      expect(platform.controller.hasListener, isFalse);
    });
  });

  group('init with a cached location', () {
    test('geocodes the last known location at startup', () async {
      platform.lastKnownLocation = at(43.6532, -79.3832);
      geocoder.queueJson(toronto());

      await init();

      expect(geocoder.requests, hasLength(1));

      final Uri request = geocoder.requests.single;
      expect(request.host, equals('nominatim.openstreetmap.org'));
      expect(request.path, equals('/reverse'));
      expect(request.queryParameters['lat'], equals('43.6532'));
      expect(request.queryParameters['lon'], equals('-79.3832'));
      expect(request.queryParameters['format'], equals('jsonv2'));
      expect(request.queryParameters['zoom'], equals('13'));

      expect(
        GeolocationService.location,
        equals(<String, double?>{'lat': 43.6532, 'lon': -79.3832}),
      );
      expect(GeolocationService.locale, equals('Toronto, Ontario'));
    });

    test('geocodes before checking permission', () async {
      platform.lastKnownLocation = at(43.6532, -79.3832);
      platform.permissionStatus = PermissionStatus.denied;
      platform.permissionStatusAfterRequest = PermissionStatus.denied;
      geocoder.queueJson(toronto());

      await init();

      expect(geocoder.requests, hasLength(1));
      expect(
        GeolocationService.location,
        equals(<String, double?>{'lat': 43.6532, 'lon': -79.3832}),
      );
      // The denied permission still prevents updates and background mode.
      expect(platform.changeSettingsCalls, equals(0));
      expect(platform.controller.hasListener, isFalse);
    });
  });

  group('locale parsing', () {
    Future<void> loadDisplayName(String displayName) async {
      platform.lastKnownLocation = at(43.6532, -79.3832);
      geocoder.queueJson(toronto(displayName: displayName));
      await init();
    }

    test('uses the first two parts of a full display name', () async {
      await loadDisplayName('Toronto, Ontario, Canada');

      expect(GeolocationService.locale, equals('Toronto, Ontario'));
    });

    test('keeps both parts of a two-part display name', () async {
      await loadDisplayName('Toronto, Canada');

      expect(GeolocationService.locale, equals('Toronto, Canada'));
    });

    test('keeps a single-part display name', () async {
      await loadDisplayName('Toronto');

      expect(GeolocationService.locale, equals('Toronto'));
    });

    test('falls back when the display name is empty', () async {
      await loadDisplayName('');

      expect(GeolocationService.locale, equals('Unknown, The Void'));
    });

    test('falls back when the display name is only whitespace', () async {
      await loadDisplayName('   ');

      expect(GeolocationService.locale, equals('Unknown, The Void'));
    });
  });

  group('requestUpdate', () {
    test('fetches and geocodes the current location', () async {
      platform.currentLocation = at(43.6532, -79.3832);
      geocoder.queueJson(toronto());

      await requestUpdate();

      expect(platform.getLocationCalls, equals(1));
      expect(geocoder.requests, hasLength(1));

      final Uri request = geocoder.requests.single;
      expect(request.path, equals('/reverse'));
      expect(request.queryParameters['lat'], equals('43.6532'));
      expect(request.queryParameters['lon'], equals('-79.3832'));
      expect(request.queryParameters['zoom'], equals('13'));

      expect(
        GeolocationService.location,
        equals(<String, double?>{'lat': 43.6532, 'lon': -79.3832}),
      );
      expect(GeolocationService.locale, equals('Toronto, Ontario'));
      // A manual update never starts listening to the location stream.
      expect(platform.controller.hasListener, isFalse);
    });

    test('keeps the cached area for a location inside its bounds', () async {
      platform.lastKnownLocation = at(43.6532, -79.3832);
      geocoder.queueJson(toronto());
      await init();

      platform.currentLocation = at(43.66, -79.39);

      await requestUpdate();

      expect(platform.getLocationCalls, equals(1));
      expect(geocoder.requests, hasLength(1));
      expect(GeolocationService.locale, equals('Toronto, Ontario'));
    });

    test('refreshes the area for a location outside its bounds', () async {
      platform.lastKnownLocation = at(43.6532, -79.3832);
      geocoder.queueJson(toronto());
      await init();

      platform.currentLocation = at(49.2827, -123.1207);
      geocoder.queueJson(vancouver());

      await requestUpdate();

      expect(platform.getLocationCalls, equals(1));
      expect(geocoder.requests, hasLength(2));
      expect(
        GeolocationService.location,
        equals(<String, double?>{'lat': 49.2827, 'lon': -123.1207}),
      );
      expect(GeolocationService.locale, equals('Vancouver, British Columbia'));
    });

    test('propagates a failure to read the current location', () async {
      await expectLater(requestUpdate(), throwsA(isA<StateError>()));

      expect(platform.getLocationCalls, equals(1));
      expect(geocoder.requests, isEmpty);
    });
  });

  group('area updates from the location stream', () {
    setUp(() async {
      platform.lastKnownLocation = at(43.6532, -79.3832);
      geocoder.queueJson(toronto());
      await init();
    });

    test('keeps the area when an update stays inside the bounds', () async {
      await emit(at(43.66, -79.39));

      expect(geocoder.requests, hasLength(1));
      expect(
        GeolocationService.location,
        equals(<String, double?>{'lat': 43.6532, 'lon': -79.3832}),
      );
      expect(GeolocationService.locale, equals('Toronto, Ontario'));
    });

    test('refetches when an update leaves the bounds', () async {
      geocoder.queueJson(vancouver());

      await emit(at(49.2827, -123.1207));

      expect(geocoder.requests, hasLength(2));

      final Uri request = geocoder.requests.last;
      expect(request.queryParameters['lat'], equals('49.2827'));
      expect(request.queryParameters['lon'], equals('-123.1207'));
      expect(request.queryParameters['zoom'], equals('13'));

      expect(
        GeolocationService.location,
        equals(<String, double?>{'lat': 49.2827, 'lon': -123.1207}),
      );
      expect(GeolocationService.locale, equals('Vancouver, British Columbia'));
    });

    test('ignores stream errors', () async {
      platform.controller.addError(StateError('gps lost'));
      await pumpEventQueue();

      expect(
        GeolocationService.location,
        equals(<String, double?>{'lat': 43.6532, 'lon': -79.3832}),
      );
    });
  });

  group('area updates without bounds', () {
    test('keeps the area for a nearby update', () async {
      platform.lastKnownLocation = at(43.6532, -79.3832);
      geocoder.queueJson(toronto(withBounds: false));
      await init();

      // Roughly 1 km north of the initial fix.
      await emit(at(43.6622, -79.3832));

      expect(geocoder.requests, hasLength(1));
      expect(
        GeolocationService.location,
        equals(<String, double?>{'lat': 43.6532, 'lon': -79.3832}),
      );
    });

    test('refetches for an update past the distance threshold', () async {
      platform.lastKnownLocation = at(43.6532, -79.3832);
      geocoder.queueJson(toronto(withBounds: false));
      await init();

      geocoder.queueJson(vancouver(withBounds: false));

      // Well beyond the 4.5 km threshold.
      await emit(at(49.2827, -123.1207));

      expect(geocoder.requests, hasLength(2));
      expect(
        GeolocationService.location,
        equals(<String, double?>{'lat': 49.2827, 'lon': -123.1207}),
      );
      expect(GeolocationService.locale, equals('Vancouver, British Columbia'));
    });
  });

  group('geocoder returns no data', () {
    test('falls back to the last known location at startup', () async {
      platform.lastKnownLocation = at(43.6532, -79.3832);
      geocoder.queueJson(<Object>[]);

      await init();

      expect(geocoder.requests, hasLength(1));
      expect(
        GeolocationService.location,
        equals(<String, double?>{'lat': 43.6532, 'lon': -79.3832}),
      );
      expect(GeolocationService.locale, equals('Unknown, The Void'));
    });

    test('retries on the next update after an initial failure', () async {
      platform.lastKnownLocation = at(43.6532, -79.3832);
      geocoder.queueJson(<Object>[]);
      await init();

      platform.currentLocation = at(43.6532, -79.3832);
      geocoder.queueJson(toronto());

      await requestUpdate();

      expect(geocoder.requests, hasLength(2));
      expect(GeolocationService.locale, equals('Toronto, Ontario'));
    });

    test('keeps the previous area when a refresh returns no data', () async {
      platform.lastKnownLocation = at(43.6532, -79.3832);
      geocoder.queueJson(toronto());
      await init();

      geocoder.queueJson(<Object>[]);

      await emit(at(49.2827, -123.1207));

      expect(geocoder.requests, hasLength(2));
      expect(
        GeolocationService.location,
        equals(<String, double?>{'lat': 43.6532, 'lon': -79.3832}),
      );
      expect(GeolocationService.locale, equals('Toronto, Ontario'));
    });
  });

  group('geocoder failures', () {
    test('requestUpdate propagates a failed request', () async {
      platform.currentLocation = at(43.6532, -79.3832);
      geocoder.queueStatus(500);

      await expectLater(requestUpdate(), throwsA(isA<NetworkException>()));

      expect(platform.getLocationCalls, equals(1));
      expect(
        GeolocationService.location,
        equals(<String, double?>{'lat': 43.6532, 'lon': -79.3832}),
      );
      expect(GeolocationService.locale, equals('Unknown, The Void'));
    });

    test(
      'init propagates a failed request before checking permission',
      () async {
        platform.lastKnownLocation = at(43.6532, -79.3832);
        geocoder.queueStatus(500);

        await expectLater(init(), throwsA(isA<NetworkException>()));

        expect(platform.hasPermissionCalls, equals(0));
        expect(platform.controller.hasListener, isFalse);
      },
    );
  });

  group('clear', () {
    test('forgets the cached location and area', () async {
      platform.lastKnownLocation = at(43.6532, -79.3832);
      geocoder.queueJson(toronto());
      await init();

      GeolocationService.clear();

      expect(
        GeolocationService.location,
        equals(<String, double?>{'lat': null, 'lon': null}),
      );
      expect(GeolocationService.locale, equals('Unknown, The Void'));
    });
  });

  group('without permission', () {
    test('ignores location stream updates after aborting init', () async {
      platform.permissionStatus = PermissionStatus.denied;
      platform.permissionStatusAfterRequest = PermissionStatus.denied;

      await init();
      await emit(at(49.2827, -123.1207));

      expect(geocoder.requests, isEmpty);
      expect(
        GeolocationService.location,
        equals(<String, double?>{'lat': null, 'lon': null}),
      );
    });
  });
}
