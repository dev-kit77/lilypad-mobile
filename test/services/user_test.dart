import 'dart:convert';
import 'dart:io';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' show runWithClient;
import 'package:lilypad/models/user.dart';
import 'package:lilypad/services/cache.dart';
import 'package:lilypad/services/session.dart';
import 'package:lilypad/services/user.dart';
import 'package:lilypad/util/api_ex.dart';
import 'package:test/test.dart';

import '../support/http_stub.dart';

void main() {
  final StubClient api = StubClient();

  setUp(() async {
    FlutterSecureStorage.setMockInitialValues(<String, String>{});
    await SessionService.invalidate();
    CacheService.clear();
    api.reset();
  });

  ///runs the service call with the API stub injected as the HTTP client.
  Future<T> withApi<T>(Future<T> Function() body) =>
      runWithClient(body, () => api);

  ///simulates the current user as the server returns it.
  Map<String, Object?> currentUserJson({
    String id = 'user-1',
    String username = 'kit',
    String? status,
    String? bio,
    bool dark = false,
    bool anon = false,
    bool pushNotifications = false,
    bool useSysTheme = false,
  }) => <String, Object?>{
    'userId': id,
    'username': username,
    'status': ?status,
    'bio': ?bio,
    'settings': <String, Object?>{
      'dark': dark,
      'anon': anon,
      'pushNotifications': pushNotifications,
      'useSysTheme': useSysTheme,
    },
  };

  Matcher throwsHttpException(int statusCode) {
    return throwsA(
      isA<APIException>().having(
        (APIException e) => e.statusCode,
        'statusCode',
        statusCode,
      ),
    );
  }

  void queueHttpError(int statusCode, {String? error}) {
    api.queueResponse(
      StubResponse(
        statusCode,
        headers: const <String, String>{'content-type': 'application/json'},
        body: jsonEncode(<String, Object?>{'error': ?error}),
      ),
    );
  }

  group('createAccount', () {
    test(
      'creates an account and reports success when a token is returned',
      () async {
        api.queueJson(<String, Object?>{
          'token': 'signup-token',
          'user': <String, Object?>{
            'id': '123',
            'name': 'kit',
            'email': 'kit@example.com',
          },
        });

        final bool created = await withApi(
          () => UserService.createAccount(
            'kit',
            'kit@example.com',
            'password123',
          ),
        );

        expect(created, isTrue);

        final RecordedRequest recorded = api.requests.single;
        expect(recorded.request.method, equals('POST'));
        expect(
          recorded.request.url.toString(),
          equals('http://localhost:3000/api/auth/sign-up/email'),
        );
        expect(
          recorded.request.headers['content-type'],
          equals('application/json'),
        );
        expect(
          jsonDecode(recorded.body),
          equals(<String, String>{
            'name': 'kit',
            'email': 'kit@example.com',
            'password': 'password123',
          }),
        );
      },
    );

    test('reports failure when the response has no token', () async {
      api.queueJson(<String, Object?>{
        'user': <String, Object?>{'id': '123', 'name': 'kit'},
      });

      final bool created = await withApi(
        () =>
            UserService.createAccount('kit', 'kit@example.com', 'password123'),
      );

      expect(created, isFalse);
    });

    test('throws HTTPException on 400 VALIDATION', () async {
      queueHttpError(400, error: 'VALIDATION');

      await expectLater(
        withApi(
          () => UserService.createAccount(
            'kit',
            'kit@example.com',
            'password123',
          ),
        ),
        throwsHttpException(400),
      );
    });

    test('throws HTTPException on 422 duplicate email', () async {
      queueHttpError(422, error: 'USER_ALREADY_EXISTS');

      await expectLater(
        withApi(
          () => UserService.createAccount(
            'kit',
            'kit@example.com',
            'password123',
          ),
        ),
        throwsHttpException(422),
      );
    });

    test('throws SocketException when the server cannot be reached', () async {
      api.queueResponse(StubResponse.error(const SocketException('refused')));

      await expectLater(
        withApi(
          () => UserService.createAccount(
            'kit',
            'kit@example.com',
            'password123',
          ),
        ),
        throwsA(isA<SocketException>()),
      );
    });
  });

  group('login', () {
    test('signs in and reports success when a token is returned', () async {
      api.queueJson(<String, Object?>{
        'token': 'signin-token',
        'user': <String, Object?>{'id': '123', 'name': 'kit'},
      });

      final bool loggedIn = await withApi(
        () => UserService.login('kit@example.com', 'password123'),
      );

      expect(loggedIn, isTrue);

      final RecordedRequest recorded = api.requests.single;
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
        jsonDecode(recorded.body),
        equals(<String, String>{
          'email': 'kit@example.com',
          'password': 'password123',
        }),
      );
    });

    test('reports failure when the response has no token', () async {
      api.queueJson(<String, Object?>{
        'user': <String, Object?>{'id': '123', 'name': 'kit'},
      });

      final bool loggedIn = await withApi(
        () => UserService.login('kit@example.com', 'password123'),
      );

      expect(loggedIn, isFalse);
    });

    test('throws HTTPException on 401 invalid credentials', () async {
      queueHttpError(401);

      await expectLater(
        withApi(() => UserService.login('kit@example.com', 'wrong-password')),
        throwsHttpException(401),
      );
    });

    test('throws SocketException when the server cannot be reached', () async {
      api.queueResponse(StubResponse.error(const SocketException('refused')));

      await expectLater(
        withApi(() => UserService.login('kit@example.com', 'password123')),
        throwsA(isA<SocketException>()),
      );
    });
  });

  group('fetchSession', () {
    test(
      'reports an active session when the payload contains a session',
      () async {
        api.queueJson(<String, Object?>{
          'session': 'session-token',
          'user': <String, Object?>{'id': '123', 'name': 'kit'},
        });

        final bool active = await withApi(UserService.fetchSession);

        expect(active, isTrue);

        final RecordedRequest recorded = api.requests.single;
        expect(recorded.request.method, equals('GET'));
        expect(
          recorded.request.url.toString(),
          equals('http://localhost:3000/api/auth/get-session'),
        );
        expect(recorded.body, isEmpty);
      },
    );

    test('reports no session when the payload has no token', () async {
      api.queueJson(<String, Object?>{});

      final bool active = await withApi(UserService.fetchSession);

      expect(active, isFalse);
    });

    test('detects a session from the documented get-session payload', () async {
      api.queueJson(<String, Object?>{
        'session': <String, Object?>{
          'id': 'session-1',
          'token': 'session-token',
          'userId': 'user-1',
        },
        'user': <String, Object?>{
          'id': 'user-1',
          'name': 'kit',
          'email': 'kit@example.com',
        },
      });

      final bool active = await withApi(UserService.fetchSession);

      expect(active, isTrue);
    });

    test('throws HTTPException on 401 no session', () async {
      queueHttpError(401);

      await expectLater(
        withApi(UserService.fetchSession),
        throwsHttpException(401),
      );
    });

    test('throws SocketException when the server cannot be reached', () async {
      api.queueResponse(StubResponse.error(const SocketException('refused')));

      await expectLater(
        withApi(UserService.fetchSession),
        throwsA(isA<SocketException>()),
      );
    });
  });

  group('fetch', () {
    test('requests the current user and caches it', () async {
      api.queueJson(<String, Object?>{
        'user': currentUserJson(
          id: 'user-1',
          username: 'kit',
          status: 'pond hopping',
          bio: 'i am a lilypad',
          dark: true,
          anon: false,
          pushNotifications: true,
          useSysTheme: true,
        ),
      });

      final CurrentUser user = await withApi(UserService.fetch);

      final RecordedRequest recorded = api.requests.single;
      expect(recorded.request.method, equals('GET'));
      expect(
        recorded.request.url.toString(),
        equals('http://localhost:3000/api/user'),
      );
      expect(recorded.body, isEmpty);

      expect(user.uuid, equals('user-1'));
      expect(user.username, equals('kit'));
      expect(user.status, equals('pond hopping'));
      expect(user.bio, equals('i am a lilypad'));
      expect(user.dark, isTrue);
      expect(user.anon, isFalse);
      expect(user.pushNotifications, isTrue);
      expect(user.useSysTheme, isTrue);
      expect(CacheService.fetch('user-1'), same(user));
    });

    test('keeps notification and theme settings on currentUser', () async {
      api.queueJson(<String, Object?>{
        'user': currentUserJson(
          id: 'user-1',
          username: 'kit',
          pushNotifications: true,
          useSysTheme: true,
        ),
      });

      await withApi(UserService.fetch);

      final CurrentUser current = UserService.currentUser!;
      expect(current.pushNotifications, isTrue);
      expect(current.useSysTheme, isTrue);
    });

    test('returns the cached user on subsequent calls', () async {
      api.queueJson(<String, Object?>{
        'user': currentUserJson(id: 'user-1', username: 'kit'),
      });

      final CurrentUser first = await withApi(UserService.fetch);
      final CurrentUser second = await withApi(UserService.fetch);

      expect(api.requests, hasLength(1));
      expect(second, same(first));
    });

    test('noCache refetches and replaces the cached user', () async {
      api.queueJson(<String, Object?>{
        'user': currentUserJson(id: 'user-1', username: 'old name'),
      });
      await withApi(UserService.fetch);

      api.queueJson(<String, Object?>{
        'user': currentUserJson(id: 'user-1', username: 'new name'),
      });
      final CurrentUser user = await withApi(
        () => UserService.fetch(noCache: true),
      );

      expect(api.requests, hasLength(2));
      expect(user.username, equals('new name'));
      expect(CacheService.fetch('user-1'), same(user));
    });

    test('throws HTTPException on 401 no session', () async {
      queueHttpError(401);

      await expectLater(withApi(UserService.fetch), throwsHttpException(401));
    });

    test('throws HTTPException on 403 USER_BANNED', () async {
      queueHttpError(403, error: 'USER_BANNED');

      await expectLater(withApi(UserService.fetch), throwsHttpException(403));
    });

    test('throws HTTPException on 404 INVALID_USER', () async {
      queueHttpError(404, error: 'INVALID_USER');

      await expectLater(withApi(UserService.fetch), throwsHttpException(404));
    });

    test('throws SocketException when the server cannot be reached', () async {
      api.queueResponse(StubResponse.error(const SocketException('refused')));

      await expectLater(
        withApi(UserService.fetch),
        throwsA(isA<SocketException>()),
      );
    });
  });

  group('update', () {
    test('sends every provided field and caches the updated user', () async {
      api.queueJson(<String, Object?>{
        'user': currentUserJson(
          id: 'user-1',
          username: 'new name',
          status: 'pond hopping',
          bio: 'i am a lilypad',
          dark: true,
          anon: true,
          pushNotifications: true,
          useSysTheme: true,
        ),
      });

      final CurrentUser user = await withApi(
        () => UserService.update(
          username: 'new name',
          status: 'pond hopping',
          bio: 'i am a lilypad',
          dark: true,
          anon: true,
          pushNotifications: true,
          useSysTheme: true,
        ),
      );

      final RecordedRequest recorded = api.requests.single;
      expect(recorded.request.method, equals('PUT'));
      expect(
        recorded.request.url.toString(),
        equals('http://localhost:3000/api/user'),
      );
      expect(
        recorded.request.headers['content-type'],
        equals('application/json'),
      );
      expect(
        jsonDecode(recorded.body),
        equals(<String, Object?>{
          'username': 'new name',
          'status': 'pond hopping',
          'bio': 'i am a lilypad',
          'settings': <String, bool>{
            'dark': true,
            'anon': true,
            'pushNotifications': true,
            'useSysTheme': true,
          },
        }),
      );

      expect(user.username, equals('new name'));
      expect(user.status, equals('pond hopping'));
      expect(user.bio, equals('i am a lilypad'));
      expect(user.dark, isTrue);
      expect(user.anon, isTrue);
      expect(user.pushNotifications, isTrue);
      expect(user.useSysTheme, isTrue);
      expect(CacheService.fetch('user-1'), same(user));
    });

    test('sends only the fields that were provided', () async {
      api.queueJson(<String, Object?>{
        'user': currentUserJson(id: 'user-1', bio: 'new bio', anon: true),
      });

      await withApi(() => UserService.update(bio: 'new bio', anon: true));

      expect(
        jsonDecode(api.requests.single.body),
        equals(<String, Object?>{
          'bio': 'new bio',
          'settings': <String, bool>{'anon': true},
        }),
      );
    });

    test('throws HTTPException on 400 INVALID_FIELD', () async {
      queueHttpError(400, error: 'INVALID_FIELD');

      await expectLater(
        withApi(() => UserService.update(username: 'kit')),
        throwsHttpException(400),
      );
    });

    test('throws HTTPException on 401 no session', () async {
      queueHttpError(401);

      await expectLater(
        withApi(() => UserService.update(username: 'kit')),
        throwsHttpException(401),
      );
    });

    test('throws HTTPException on 404 INVALID_USER', () async {
      queueHttpError(404, error: 'INVALID_USER');

      await expectLater(
        withApi(() => UserService.update(username: 'kit')),
        throwsHttpException(404),
      );
    });

    test('throws HTTPException on 500 INTERNAL_SERVER', () async {
      queueHttpError(500, error: 'INTERNAL_SERVER');

      await expectLater(
        withApi(() => UserService.update(username: 'kit')),
        throwsHttpException(500),
      );
    });

    test('throws SocketException when the server cannot be reached', () async {
      api.queueResponse(StubResponse.error(const SocketException('refused')));

      await expectLater(
        withApi(() => UserService.update(username: 'kit')),
        throwsA(isA<SocketException>()),
      );
    });
  });

  group('delete', () {
    test('deletes the account and reports success', () async {
      api.queueJson(<String, String>{'status': 'OK'});

      final bool deleted = await withApi(UserService.delete);

      expect(deleted, isTrue);

      final RecordedRequest recorded = api.requests.single;
      expect(recorded.request.method, equals('DELETE'));
      expect(
        recorded.request.url.toString(),
        equals('http://localhost:3000/api/user'),
      );
      expect(recorded.body, isEmpty);
    });

    test('reports failure when the response has no status', () async {
      api.queueJson(<String, Object?>{});

      final bool deleted = await withApi(UserService.delete);

      expect(deleted, isFalse);
    });

    test('throws HTTPException on 401 no session', () async {
      queueHttpError(401);

      await expectLater(withApi(UserService.delete), throwsHttpException(401));
    });

    test('throws HTTPException on 404 INVALID_USER', () async {
      queueHttpError(404, error: 'INVALID_USER');

      await expectLater(withApi(UserService.delete), throwsHttpException(404));
    });

    test('throws HTTPException on 500 INTERNAL_SERVER', () async {
      queueHttpError(500, error: 'INTERNAL_SERVER');

      await expectLater(withApi(UserService.delete), throwsHttpException(500));
    });

    test('throws SocketException when the server cannot be reached', () async {
      api.queueResponse(StubResponse.error(const SocketException('refused')));

      await expectLater(
        withApi(UserService.delete),
        throwsA(isA<SocketException>()),
      );
    });
  });

  group('logout', () {
    test('reports success when the server confirms', () async {
      api.queueJson(<String, bool>{'success': true});

      final bool loggedOut = await withApi(UserService.logout);

      expect(loggedOut, isTrue);
      expect(api.requests, hasLength(1));
    });

    test('reports failure when the server does not confirm', () async {
      api.queueJson(<String, Object?>{});

      final bool loggedOut = await withApi(UserService.logout);

      expect(loggedOut, isFalse);
    });

    test('signs out through the auth sign-out endpoint', () async {
      api.queueJson(<String, bool>{'success': true});

      await withApi(UserService.logout);

      final RecordedRequest recorded = api.requests.single;
      expect(recorded.request.method, equals('POST'));
      expect(
        recorded.request.url.toString(),
        equals('http://localhost:3000/api/auth/sign-out'),
      );
    });

    test('throws HTTPException on 401 no session', () async {
      queueHttpError(401);

      await expectLater(withApi(UserService.logout), throwsHttpException(401));
    });

    test('throws SocketException when the server cannot be reached', () async {
      api.queueResponse(StubResponse.error(const SocketException('refused')));

      await expectLater(
        withApi(UserService.logout),
        throwsA(isA<SocketException>()),
      );
    });
  });

  group('fetchGdprSar', () {
    test('returns the GDPR subject access report', () async {
      final Map<String, Object?> report = <String, Object?>{
        'generatedAt': '2026-01-01T00:00:00.000Z',
        'requestType': 'GDPR_ARTICLE_15_SAR',
        'user': currentUserJson(id: 'user-1', username: 'kit'),
        'posts': <Object>[
          <String, Object?>{'id': 'post-1', 'content': 'hello world'},
        ],
        'reportsFiled': <Object>[],
        'reportsAgainstUser': <Object>[],
      };
      api.queueJson(report);

      final Map<String, Object?> result = await withApi(
        UserService.fetchGdprSar,
      );

      expect(result, equals(report));
      expect(api.requests, hasLength(1));
    });

    test('requests the GDPR export endpoint', () async {
      api.queueJson(<String, Object?>{'requestType': 'GDPR_ARTICLE_15_SAR'});

      await withApi(UserService.fetchGdprSar);

      final RecordedRequest recorded = api.requests.single;
      expect(recorded.request.method, equals('GET'));
      expect(
        recorded.request.url.toString(),
        equals('http://localhost:3000/api/user/gdpr-sar'),
      );
    });

    test('throws HTTPException on 401 no session', () async {
      queueHttpError(401);

      await expectLater(
        withApi(UserService.fetchGdprSar),
        throwsHttpException(401),
      );
    });

    test('throws HTTPException on 404 INVALID_USER', () async {
      queueHttpError(404, error: 'INVALID_USER');

      await expectLater(
        withApi(UserService.fetchGdprSar),
        throwsHttpException(404),
      );
    });

    test('throws SocketException when the server cannot be reached', () async {
      api.queueResponse(StubResponse.error(const SocketException('refused')));

      await expectLater(
        withApi(UserService.fetchGdprSar),
        throwsA(isA<SocketException>()),
      );
    });
  });
}
