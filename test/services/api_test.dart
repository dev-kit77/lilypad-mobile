import 'dart:convert';
import 'dart:io';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart';
import 'package:lilypad/builders/auth.dart';
import 'package:lilypad/services/api.dart';
import 'package:lilypad/services/session.dart';
import 'package:test/test.dart';

import '../support/http_stub.dart';

//init stub client for file.
final StubClient stub = StubClient();

void main() {
  setUp(() async {
    // refresh in-memory secure storage for every test.
    FlutterSecureStorage.setMockInitialValues(<String, String>{});
    // clear cookies between tests
    await SessionService.clear();
    // drop responses and requests left over from the previous test.
    stub.reset();
  });

  /// Sends request through APIService with the shared stub injected.
  Future<Response> sendViaStub(Request request) =>
      runWithClient(() => APIService.send(request), () => stub);

  /// Pings the server through APIService with the shared stub injected.
  Future<bool> pingViaStub() => runWithClient(APIService.ping, () => stub);

  group('ping', () {
    test('returns true when the server replies 200', () async {
      stub.queueResponse(StubResponse(200, body: 'pong'));
      await SessionService.capture(
        'better-auth.session_token=ping-token; Path=/; HttpOnly',
      );

      final bool result = await pingViaStub();

      expect(result, isTrue);

      final RecordedRequest recorded = stub.requests.single;
      expect(recorded.request.method, equals('GET'));
      expect(
        recorded.request.url.toString(),
        equals('http://localhost:3000/api/'),
      );
      expect(recorded.request.headers['cookie'], isNull);
      expect(recorded.body, isEmpty);
    });

    test(
      'returns false when the server replies with an error status',
      () async {
        stub.queueResponse(StubResponse(500));

        final bool result = await pingViaStub();

        expect(result, isFalse);
        expect(stub.requests.single.request.method, equals('GET'));
      },
    );

    test('returns false when the server cannot be reached', () async {
      stub.queueResponse(StubResponse.error(SocketException('refused')));

      final bool result = await pingViaStub();

      expect(result, isFalse);
      expect(stub.requests.single.request.method, equals('GET'));
    });
  });

  group('send', () {
    test(
      'delivers a sign-up request with no cookie when there is no session',
      () async {
        stub.queueResponse(
          StubResponse(
            200,
            headers: <String, String>{
              'set-cookie':
                  'better-auth.session_token=signup-token; Path=/; '
                  'HttpOnly; SameSite=Lax',
            },
            body: '{"token":"signup-token"}',
          ),
        );

        final Response response = await sendViaStub(
          AuthRequestBuilder.signUp('kit', 'kit@example.com', 'password123'),
        );

        expect(response.statusCode, equals(200));

        final RecordedRequest recorded = stub.requests.single;
        expect(recorded.request.method, equals('POST'));
        expect(
          recorded.request.url.toString(),
          equals('http://localhost:3000/api/auth/sign-up/email'),
        );
        expect(
          recorded.request.headers['content-type'],
          equals('application/json'),
        );
        expect(recorded.request.headers['cookie'], isNull);
        expect(
          jsonDecode(recorded.body),
          equals(<String, String>{
            'name': 'kit',
            'email': 'kit@example.com',
            'password': 'password123',
          }),
        );

        expect(
          SessionService.getCookieHeader(),
          equals('better-auth.session_token=signup-token'),
        );
      },
    );

    test('delivers a sign-in request and captures the new cookie', () async {
      stub.queueResponse(
        StubResponse(
          200,
          headers: <String, String>{
            'set-cookie':
                'better-auth.session_token=fresh-token; Path=/; '
                'HttpOnly; SameSite=Lax',
          },
          body: '{"user":{"id":"123","name":"kit"}}',
        ),
      );
      await SessionService.capture(
        'better-auth.session_token=stale-token; Path=/; HttpOnly',
      );

      final Response response = await sendViaStub(
        AuthRequestBuilder.signIn('kit@example.com', 'password123'),
      );

      expect(response.statusCode, equals(200));
      expect(response.body, equals('{"user":{"id":"123","name":"kit"}}'));

      final RecordedRequest recorded = stub.requests.single;
      expect(recorded.request.method, equals('POST'));
      expect(
        recorded.request.url.toString(),
        equals('http://localhost:3000/api/auth/sign-in/email'),
      );
      expect(
        recorded.request.headers['content-type'],
        equals('application/json'),
      );
      expect(
        recorded.request.headers['cookie'],
        equals('better-auth.session_token=stale-token'),
      );
      expect(
        jsonDecode(recorded.body),
        equals(<String, String>{
          'email': 'kit@example.com',
          'password': 'password123',
        }),
      );

      expect(
        SessionService.getCookieHeader(),
        equals('better-auth.session_token=fresh-token'),
      );
    });

    test(
      'delivers a session refresh and captures the rotated cookie',
      () async {
        stub.queueResponse(
          StubResponse(
            200,
            headers: <String, String>{
              'set-cookie':
                  'better-auth.session_token=rotated-token; Path=/; '
                  'HttpOnly; SameSite=Lax',
            },
          ),
        );
        await SessionService.capture(
          'better-auth.session_token=current-token; Path=/; HttpOnly',
        );

        final Response response = await sendViaStub(
          AuthRequestBuilder.sessionRefresh(),
        );

        expect(response.statusCode, equals(200));

        final RecordedRequest recorded = stub.requests.single;
        expect(recorded.request.method, equals('GET'));
        expect(
          recorded.request.url.toString(),
          equals('http://localhost:3000/api/auth/get-session'),
        );
        expect(recorded.body, isEmpty);
        expect(recorded.request.headers['content-type'], isNull);
        expect(
          recorded.request.headers['cookie'],
          equals('better-auth.session_token=current-token'),
        );

        expect(
          SessionService.getCookieHeader(),
          equals('better-auth.session_token=rotated-token'),
        );
      },
    );

    test('delivers a sign-out request and drops the expired cookie', () async {
      stub.queueResponse(
        StubResponse(
          200,
          headers: <String, String>{
            'set-cookie': 'better-auth.session_token=; Max-Age=0; Path=/',
          },
        ),
      );
      await SessionService.capture(
        'better-auth.session_token=bye-token; Path=/; HttpOnly',
      );

      final Response response = await sendViaStub(AuthRequestBuilder.signOut());

      expect(response.statusCode, equals(200));

      final RecordedRequest recorded = stub.requests.single;
      expect(recorded.request.method, equals('POST'));
      expect(
        recorded.request.url.toString(),
        equals('http://localhost:3000/api/auth/sign-out'),
      );
      expect(
        recorded.request.headers['cookie'],
        equals('better-auth.session_token=bye-token'),
      );
      expect(recorded.body, isEmpty);

      expect(SessionService.activeSession, isFalse);
      expect(SessionService.getCookieHeader(), isNull);
    });

    test('clears the session when the server replies 401', () async {
      stub.queueResponse(StubResponse(401));
      await SessionService.capture(
        'better-auth.session_token=expired-token; Path=/; HttpOnly',
      );

      final Response response = await sendViaStub(
        AuthRequestBuilder.sessionRefresh(),
      );

      expect(response.statusCode, equals(401));
      expect(
        stub.requests.single.request.headers['cookie'],
        equals('better-auth.session_token=expired-token'),
      );
      expect(SessionService.activeSession, isFalse);
    });

    test('captures the set-cookie header on other error responses', () async {
      stub.queueResponse(
        StubResponse(
          500,
          headers: <String, String>{
            'set-cookie':
                'better-auth.session_token=error-token; Path=/; HttpOnly',
          },
        ),
      );
      await SessionService.capture(
        'better-auth.session_token=old-token; Path=/; HttpOnly',
      );

      final Response response = await sendViaStub(
        AuthRequestBuilder.signIn('kit@example.com', 'password123'),
      );

      expect(response.statusCode, equals(500));
      expect(
        SessionService.getCookieHeader(),
        equals('better-auth.session_token=error-token'),
      );
    });

    test(
      'leaves the session alone when a 200 has no set-cookie header',
      () async {
        stub.queueResponse(StubResponse(200));
        await SessionService.capture(
          'better-auth.session_token=old-token; Path=/; HttpOnly',
        );

        final Response response = await sendViaStub(
          AuthRequestBuilder.sessionRefresh(),
        );

        expect(response.statusCode, equals(200));
        expect(
          SessionService.getCookieHeader(),
          equals('better-auth.session_token=old-token'),
        );
      },
    );

    test(
      'leaves the session alone when an error has no set-cookie header',
      () async {
        stub.queueResponse(StubResponse(500));
        await SessionService.capture(
          'better-auth.session_token=old-token; Path=/; HttpOnly',
        );

        final Response response = await sendViaStub(
          AuthRequestBuilder.signIn('kit@example.com', 'password123'),
        );

        expect(response.statusCode, equals(500));
        expect(
          SessionService.getCookieHeader(),
          equals('better-auth.session_token=old-token'),
        );
      },
    );
  });
}
