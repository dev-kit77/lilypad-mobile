import 'dart:convert';
import 'dart:io';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' show runWithClient;
import 'package:lilypad/models/post.dart';
import 'package:lilypad/models/user.dart';
import 'package:lilypad/services/cache.dart';
import 'package:lilypad/services/content.dart';
import 'package:lilypad/services/geolocation.dart';
import 'package:lilypad/services/session.dart';
import 'package:lilypad/util/api_ex.dart';
import 'package:location_platform_interface/location_platform_interface.dart';
import 'package:test/test.dart';

import '../support/content_fixtures.dart';
import '../support/fake_location_platform.dart';
import '../support/http_stub.dart';

void main() {
  final LocationPlatform originalPlatform = LocationPlatform.instance;

  final StubClient api = StubClient();

  late FakeLocationPlatform platform;
  late StubClient geocoder;

  setUp(() async {
    FlutterSecureStorage.setMockInitialValues(<String, String>{});
    await SessionService.invalidate();
    CacheService.clear();
    GeolocationService.clear();

    api.reset();

    platform = FakeLocationPlatform();
    LocationPlatform.instance = platform;
    geocoder = StubClient();
  });

  tearDown(() {
    LocationPlatform.instance = originalPlatform;
    platform.controller.close();
  });

  ///runs with the API stub injected as the HTTP client.
  Future<T> withApi<T>(Future<T> Function() body) =>
      runWithClient(body, () => api);

  /// gives the content service a current location. empty geocoder result leaves
  /// the area unset, so service falls back to the last known coordinates
  Future<void> givenLocation({
    double latitude = 51.5074,
    double longitude = -0.1278,
  }) async {
    platform.lastKnownLocation = at(latitude, longitude);
    geocoder.queueJson(<Object>[]);
    await runWithClient(GeolocationService.init, () => geocoder);
  }

  Matcher throwsHttpException(int statusCode) {
    return throwsA(
      isA<APIException>().having(
        (APIException e) => e.statusCode,
        'statusCode',
        statusCode,
      ),
    );
  }

  void queueHttpError(
    int statusCode, {
    String? error,
    Map<String, Object?>? body,
  }) {
    api.queueResponse(
      StubResponse(
        statusCode,
        headers: const <String, String>{'content-type': 'application/json'},
        body: jsonEncode(body ?? <String, Object?>{'error': ?error}),
      ),
    );
  }

  group('fetchFeed', () {
    test('throws when the location is not available', () async {
      await expectLater(
        withApi(ContentService.fetchFeed),
        throwsA(
          isA<Exception>().having(
            (Exception e) => e.toString(),
            'message',
            contains('Location Not Available'),
          ),
        ),
      );

      expect(api.requests, isEmpty);
    });

    test('requests the nearby feed for the current location', () async {
      await givenLocation(latitude: 51.5074, longitude: -0.1278);
      api.queueJson(<String, Object>{
        'posts': <Object>[],
        'replies': <Object>[],
      });

      final List<Post> feed = await withApi(ContentService.fetchFeed);

      expect(feed, isEmpty);

      final RecordedRequest recorded = api.requests.single;
      expect(recorded.request.method, equals('GET'));
      expect(
        recorded.request.url.toString(),
        equals(
          'http://localhost:3000/api/feed-spatial?lat=51.5074&lon=-0.1278',
        ),
      );
      expect(recorded.body, isEmpty);
    });

    test('returns root posts and links replies to their parents', () async {
      await givenLocation();
      api.queueJson(<String, Object>{
        'posts': <Object>[postJson(id: 'root')],
        'replies': <Object>[postJson(id: 'reply', replyingTo: 'root')],
      });

      final List<Post> feed = await withApi(ContentService.fetchFeed);

      expect(feed, hasLength(1));
      expect(feed.single.uuid, equals('root'));
      expect(feed.single.replies, hasLength(1));
      expect(feed.single.replies.single.uuid, equals('reply'));
      expect(feed.single.replies.single.replying, equals('root'));
    });

    test('links replies that reply to other replies', () async {
      await givenLocation();
      api.queueJson(<String, Object>{
        'posts': <Object>[postJson(id: 'root')],
        'replies': <Object>[
          postJson(id: 'reply', replyingTo: 'root'),
          postJson(id: 'nested', replyingTo: 'reply'),
        ],
      });

      final List<Post> feed = await withApi(ContentService.fetchFeed);

      final Post root = feed.single;
      expect(root.replies.single.uuid, equals('reply'));
      expect(root.replies.single.replies.single.uuid, equals('nested'));
    });

    test('caches the feed and each post it contains', () async {
      await givenLocation();
      api.queueJson(<String, Object>{
        'posts': <Object>[postJson(id: 'root')],
        'replies': <Object>[postJson(id: 'reply', replyingTo: 'root')],
      });

      final List<Post> feed = await withApi(ContentService.fetchFeed);

      const String feedKey =
          'http://localhost:3000/api/feed-spatial?lat=51.5074&lon=-0.1278';
      final List<Post>? cachedFeed = CacheService.fetch(feedKey) as List<Post>?;

      expect(cachedFeed, isNotNull);
      expect(cachedFeed!.map((Post p) => p.uuid), equals(<String>['root']));
      expect(CacheService.fetch('root'), same(feed.single));
      expect(CacheService.fetch('reply'), isA<Post>());
    });

    test('returns the cached feed without contacting the server', () async {
      await givenLocation();
      api.queueJson(<String, Object>{
        'posts': <Object>[postJson(id: 'root')],
        'replies': <Object>[],
      });

      final List<Post> first = await withApi(ContentService.fetchFeed);
      final List<Post> second = await withApi(ContentService.fetchFeed);

      expect(api.requests, hasLength(1));
      expect(second.single.uuid, equals(first.single.uuid));
    });

    test('noCache ignores the cached feed and fetches again', () async {
      await givenLocation();
      api.queueJson(<String, Object>{
        'posts': <Object>[postJson(id: 'first')],
        'replies': <Object>[],
      });
      await withApi(ContentService.fetchFeed);

      api.queueJson(<String, Object>{
        'posts': <Object>[postJson(id: 'second')],
        'replies': <Object>[],
      });
      final List<Post> feed = await withApi(
        () => ContentService.fetchFeed(noCache: true),
      );

      expect(api.requests, hasLength(2));
      expect(feed.single.uuid, equals('second'));
    });

    test('returns a copy so callers cannot mutate the cache', () async {
      await givenLocation();
      api.queueJson(<String, Object>{
        'posts': <Object>[postJson(id: 'root')],
        'replies': <Object>[],
      });

      final List<Post> feed = await withApi(ContentService.fetchFeed);
      feed.clear();

      final List<Post> cached = await withApi(ContentService.fetchFeed);

      expect(api.requests, hasLength(1));
      expect(cached, hasLength(1));
    });

    test('throws HTTPException on 400 INVALID_FIELD', () async {
      await givenLocation();
      queueHttpError(400, error: 'INVALID_FIELD');

      await expectLater(
        withApi(ContentService.fetchFeed),
        throwsHttpException(400),
      );
    });

    test('throws HTTPException on 401 no session', () async {
      await givenLocation();
      queueHttpError(401);

      await expectLater(
        withApi(ContentService.fetchFeed),
        throwsHttpException(401),
      );
    });

    test('throws HTTPException on 500 INTERNAL_SERVER', () async {
      await givenLocation();
      queueHttpError(500, error: 'INTERNAL_SERVER');

      await expectLater(
        withApi(ContentService.fetchFeed),
        throwsHttpException(500),
      );
    });

    test('throws SocketException when the server cannot be reached', () async {
      await givenLocation();
      api.queueResponse(StubResponse.error(const SocketException('refused')));

      await expectLater(
        withApi(ContentService.fetchFeed),
        throwsA(isA<SocketException>()),
      );
    });
  });

  group('fetchPost', () {
    test('requests a post by id and caches it', () async {
      api.queueJson(<String, Object>{
        'post': postJson(id: 'post-1', content: 'hello world'),
      });

      final Post post = await withApi(() => ContentService.fetchPost('post-1'));

      final RecordedRequest recorded = api.requests.single;
      expect(recorded.request.method, equals('GET'));
      expect(
        recorded.request.url.toString(),
        equals('http://localhost:3000/api/content/post/post-1'),
      );
      expect(post.uuid, equals('post-1'));
      expect(post.content, equals('hello world'));
      expect(CacheService.fetch('post-1'), same(post));
    });

    test('returns a cached post without contacting the server', () async {
      final Post post = cachedPost();
      CacheService.store(o: post);

      final Post fetched = await withApi(
        () => ContentService.fetchPost('post-1'),
      );

      expect(api.requests, isEmpty);
      expect(fetched, same(post));
    });

    test('noCache ignores the cached post', () async {
      CacheService.store(o: cachedPost(content: 'old content'));
      api.queueJson(<String, Object>{
        'post': postJson(id: 'post-1', content: 'new content'),
      });

      final Post fetched = await withApi(
        () => ContentService.fetchPost('post-1', noCache: true),
      );

      expect(api.requests, hasLength(1));
      expect(fetched.content, equals('new content'));
    });

    test('throws HTTPException on 401 no session', () async {
      queueHttpError(401);

      await expectLater(
        withApi(() => ContentService.fetchPost('post-1')),
        throwsHttpException(401),
      );
    });

    test('throws HTTPException on 403 INVALID_USER', () async {
      queueHttpError(403, error: 'INVALID_USER');

      await expectLater(
        withApi(() => ContentService.fetchPost('post-1')),
        throwsHttpException(403),
      );
    });

    test('throws HTTPException on 404 INVALID_ID', () async {
      queueHttpError(404, error: 'INVALID_ID');

      await expectLater(
        withApi(() => ContentService.fetchPost('post-1')),
        throwsHttpException(404),
      );
    });

    test('throws SocketException when the server cannot be reached', () async {
      api.queueResponse(StubResponse.error(const SocketException('refused')));

      await expectLater(
        withApi(() => ContentService.fetchPost('post-1')),
        throwsA(isA<SocketException>()),
      );
    });
  });

  group('newPost', () {
    test('throws when the location is not available', () async {
      await expectLater(
        withApi(() => ContentService.newPost('hello')),
        throwsA(
          isA<Exception>().having(
            (Exception e) => e.toString(),
            'message',
            contains('Location Not Available'),
          ),
        ),
      );

      expect(api.requests, isEmpty);
    });

    test('creates a post at the current location and caches it', () async {
      await givenLocation(latitude: 55.9533, longitude: -3.1883);
      api.queueJson(<String, Object>{
        'post': postJson(id: 'new-post', content: 'hello'),
      });

      final Post post = await withApi(() => ContentService.newPost('hello'));

      final RecordedRequest recorded = api.requests.single;
      expect(recorded.request.method, equals('POST'));
      expect(
        recorded.request.url.toString(),
        equals('http://localhost:3000/api/content/post'),
      );
      expect(
        recorded.request.headers['content-type'],
        equals('application/json'),
      );
      expect(
        jsonDecode(recorded.body),
        equals(<String, Object>{
          'content': 'hello',
          'locality': <String, double>{'lat': 55.9533, 'lon': -3.1883},
        }),
      );

      expect(post.uuid, equals('new-post'));
      expect(CacheService.fetch('new-post'), same(post));
    });

    test('throws HTTPException on 400 INVALID_FIELD', () async {
      await givenLocation();
      queueHttpError(400, error: 'INVALID_FIELD');

      await expectLater(
        withApi(() => ContentService.newPost('hello')),
        throwsHttpException(400),
      );
    });

    test('throws HTTPException on 401 no session', () async {
      await givenLocation();
      queueHttpError(401);

      await expectLater(
        withApi(() => ContentService.newPost('hello')),
        throwsHttpException(401),
      );
    });

    test('throws HTTPException on 404 INVALID_ID', () async {
      await givenLocation();
      queueHttpError(404, error: 'INVALID_ID');

      await expectLater(
        withApi(() => ContentService.newPost('hello')),
        throwsHttpException(404),
      );
    });

    test('throws HTTPException on 500 INTERNAL_SERVER', () async {
      await givenLocation();
      queueHttpError(500, error: 'INTERNAL_SERVER');

      await expectLater(
        withApi(() => ContentService.newPost('hello')),
        throwsHttpException(500),
      );
    });

    test('throws SocketException when the server cannot be reached', () async {
      await givenLocation();
      api.queueResponse(StubResponse.error(const SocketException('refused')));

      await expectLater(
        withApi(() => ContentService.newPost('hello')),
        throwsA(isA<SocketException>()),
      );
    });
  });

  group('newReply', () {
    test('creates a reply and invalidates the cached parent', () async {
      CacheService.store(o: cachedPost(uuid: 'parent'));
      api.queueJson(<String, Object>{
        'post': postJson(
          id: 'reply-1',
          content: 'hello back',
          replyingTo: 'parent',
        ),
      });

      final Post reply = await withApi(
        () => ContentService.newReply('parent', 'hello back'),
      );

      final RecordedRequest recorded = api.requests.single;
      expect(recorded.request.method, equals('POST'));
      expect(
        recorded.request.url.toString(),
        equals('http://localhost:3000/api/content/post/parent/reply'),
      );
      expect(
        recorded.request.headers['content-type'],
        equals('application/json'),
      );
      expect(
        jsonDecode(recorded.body),
        equals(<String, String>{'content': 'hello back'}),
      );

      expect(CacheService.fetch('parent'), isNull);
      expect(reply.uuid, equals('reply-1'));
      expect(CacheService.fetch('reply-1'), same(reply));
    });

    test('throws HTTPException on 400 INVALID_FIELD', () async {
      queueHttpError(400, error: 'INVALID_FIELD');

      await expectLater(
        withApi(() => ContentService.newReply('parent', 'hello back')),
        throwsHttpException(400),
      );
    });

    test('throws HTTPException on 401 no session', () async {
      queueHttpError(401);

      await expectLater(
        withApi(() => ContentService.newReply('parent', 'hello back')),
        throwsHttpException(401),
      );
    });

    test('throws HTTPException on 404 INVALID_ID', () async {
      queueHttpError(404, error: 'INVALID_ID');

      await expectLater(
        withApi(() => ContentService.newReply('parent', 'hello back')),
        throwsHttpException(404),
      );
    });

    test('throws HTTPException on 500 INTERNAL_SERVER', () async {
      queueHttpError(500, error: 'INTERNAL_SERVER');

      await expectLater(
        withApi(() => ContentService.newReply('parent', 'hello back')),
        throwsHttpException(500),
      );
    });

    test('throws SocketException when the server cannot be reached', () async {
      api.queueResponse(StubResponse.error(const SocketException('refused')));

      await expectLater(
        withApi(() => ContentService.newReply('parent', 'hello back')),
        throwsA(isA<SocketException>()),
      );
    });
  });

  group('modifyPost', () {
    test('updates a post and caches the returned version', () async {
      CacheService.store(o: cachedPost(content: 'old content'));
      api.queueJson(<String, Object>{
        'post': postJson(
          id: 'post-1',
          content: 'edited content',
          updated: '2026-01-02T12:00:00.000Z',
        ),
      });

      final Post post = await withApi(
        () => ContentService.modifyPost('post-1', 'edited content'),
      );

      final RecordedRequest recorded = api.requests.single;
      expect(recorded.request.method, equals('PUT'));
      expect(
        recorded.request.url.toString(),
        equals('http://localhost:3000/api/content/post/post-1'),
      );
      expect(
        jsonDecode(recorded.body),
        equals(<String, String>{'content': 'edited content'}),
      );

      expect(post.content, equals('edited content'));
      expect(post.updated, isNotNull);
      expect(CacheService.fetch('post-1'), same(post));
    });

    test('throws HTTPException on 400 INVALID_FIELD', () async {
      queueHttpError(400, error: 'INVALID_FIELD');

      await expectLater(
        withApi(() => ContentService.modifyPost('post-1', 'edited content')),
        throwsHttpException(400),
      );
    });

    test('throws HTTPException on 401 no session', () async {
      queueHttpError(401);

      await expectLater(
        withApi(() => ContentService.modifyPost('post-1', 'edited content')),
        throwsHttpException(401),
      );
    });

    test('throws HTTPException on 403 INVALID_USER', () async {
      queueHttpError(403, error: 'INVALID_USER');

      await expectLater(
        withApi(() => ContentService.modifyPost('post-1', 'edited content')),
        throwsHttpException(403),
      );
    });

    test('throws HTTPException on 404 INVALID_ID', () async {
      queueHttpError(404, error: 'INVALID_ID');

      await expectLater(
        withApi(() => ContentService.modifyPost('post-1', 'edited content')),
        throwsHttpException(404),
      );
    });

    test('throws HTTPException on 500 INTERNAL_SERVER', () async {
      queueHttpError(500, error: 'INTERNAL_SERVER');

      await expectLater(
        withApi(() => ContentService.modifyPost('post-1', 'edited content')),
        throwsHttpException(500),
      );
    });

    test('throws SocketException when the server cannot be reached', () async {
      api.queueResponse(StubResponse.error(const SocketException('refused')));

      await expectLater(
        withApi(() => ContentService.modifyPost('post-1', 'edited content')),
        throwsA(isA<SocketException>()),
      );
    });
  });

  group('removePost', () {
    test('deletes a post and removes it from the cache', () async {
      CacheService.store(o: cachedPost());
      api.queueJson(<String, String>{'status': 'OK'});

      final bool removed = await withApi(
        () => ContentService.removePost('post-1'),
      );

      final RecordedRequest recorded = api.requests.single;
      expect(recorded.request.method, equals('DELETE'));
      expect(
        recorded.request.url.toString(),
        equals('http://localhost:3000/api/content/post/post-1'),
      );
      expect(recorded.body, isEmpty);

      expect(removed, isTrue);
      expect(CacheService.fetch('post-1'), isNull);
    });

    test('throws HTTPException on 401 no session', () async {
      queueHttpError(401);

      await expectLater(
        withApi(() => ContentService.removePost('post-1')),
        throwsHttpException(401),
      );
    });

    test('throws HTTPException on 403 INVALID_USER', () async {
      queueHttpError(403, error: 'INVALID_USER');

      await expectLater(
        withApi(() => ContentService.removePost('post-1')),
        throwsHttpException(403),
      );
    });

    test('throws HTTPException on 404 INVALID_ID', () async {
      queueHttpError(404, error: 'INVALID_ID');

      await expectLater(
        withApi(() => ContentService.removePost('post-1')),
        throwsHttpException(404),
      );
    });

    test('throws HTTPException on 500 INVALID_FIELD', () async {
      queueHttpError(500, error: 'INVALID_FIELD');

      await expectLater(
        withApi(() => ContentService.removePost('post-1')),
        throwsHttpException(500),
      );
    });

    test('throws HTTPException on 500 INTERNAL_SERVER', () async {
      queueHttpError(500, error: 'INTERNAL_SERVER');

      await expectLater(
        withApi(() => ContentService.removePost('post-1')),
        throwsHttpException(500),
      );
    });

    test('throws SocketException when the server cannot be reached', () async {
      api.queueResponse(StubResponse.error(const SocketException('refused')));

      await expectLater(
        withApi(() => ContentService.removePost('post-1')),
        throwsA(isA<SocketException>()),
      );
    });
  });

  group('upvotePost', () {
    test('upvotes a post and caches the updated version', () async {
      api.queueJson(<String, Object>{
        'post': postJson(id: 'post-1', upvotes: 3),
      });

      final Post post = await withApi(
        () => ContentService.upvotePost('post-1'),
      );

      final RecordedRequest recorded = api.requests.single;
      expect(recorded.request.method, equals('PUT'));
      expect(
        recorded.request.url.toString(),
        equals('http://localhost:3000/api/content/post/post-1/upvote'),
      );
      expect(recorded.body, isEmpty);

      expect(post.upvotes, equals(3));
      expect(CacheService.fetch('post-1'), same(post));
    });

    test('throws HTTPException on 401 no session', () async {
      queueHttpError(401);

      await expectLater(
        withApi(() => ContentService.upvotePost('post-1')),
        throwsHttpException(401),
      );
    });

    test('throws HTTPException on 404 INVALID_ID', () async {
      queueHttpError(404, error: 'INVALID_ID');

      await expectLater(
        withApi(() => ContentService.upvotePost('post-1')),
        throwsHttpException(404),
      );
    });

    test('throws HTTPException on 500 INTERNAL_SERVER', () async {
      queueHttpError(500, error: 'INTERNAL_SERVER');

      await expectLater(
        withApi(() => ContentService.upvotePost('post-1')),
        throwsHttpException(500),
      );
    });

    test('throws SocketException when the server cannot be reached', () async {
      api.queueResponse(StubResponse.error(const SocketException('refused')));

      await expectLater(
        withApi(() => ContentService.upvotePost('post-1')),
        throwsA(isA<SocketException>()),
      );
    });
  });

  group('fetchReplies', () {
    test('requests replies for a post and caches them', () async {
      api.queueJson(<String, Object>{
        'replies': <Object>[
          postJson(id: 'reply-2', replyingTo: 'post-1'),
          postJson(id: 'reply-1', replyingTo: 'post-1'),
        ],
      });

      final List<Post> replies = await withApi(
        () => ContentService.fetchReplies('post-1'),
      );

      final RecordedRequest recorded = api.requests.single;
      expect(recorded.request.method, equals('GET'));
      expect(
        recorded.request.url.toString(),
        equals('http://localhost:3000/api/content/post/post-1/reply'),
      );

      expect(
        replies.map((Post p) => p.uuid),
        equals(<String>['reply-2', 'reply-1']),
      );

      final List<Post>? cached =
          CacheService.fetch(recorded.request.url.toString()) as List<Post>?;
      expect(cached, isNotNull);
      expect(
        cached!.map((Post p) => p.uuid),
        equals(<String>['reply-2', 'reply-1']),
      );
    });

    test('returns cached replies without contacting the server', () async {
      api.queueJson(<String, Object>{
        'replies': <Object>[postJson(id: 'reply-1', replyingTo: 'post-1')],
      });

      final List<Post> first = await withApi(
        () => ContentService.fetchReplies('post-1'),
      );
      final List<Post> second = await withApi(
        () => ContentService.fetchReplies('post-1'),
      );

      expect(api.requests, hasLength(1));
      expect(second.single.uuid, equals(first.single.uuid));
    });

    test('noCache ignores the cached replies', () async {
      api.queueJson(<String, Object>{
        'replies': <Object>[postJson(id: 'reply-1', replyingTo: 'post-1')],
      });
      await withApi(() => ContentService.fetchReplies('post-1'));

      api.queueJson(<String, Object>{
        'replies': <Object>[postJson(id: 'reply-2', replyingTo: 'post-1')],
      });
      final List<Post> replies = await withApi(
        () => ContentService.fetchReplies('post-1', noCache: true),
      );

      expect(api.requests, hasLength(2));
      expect(replies.single.uuid, equals('reply-2'));
    });

    test('throws HTTPException on 401 no session', () async {
      queueHttpError(401);

      await expectLater(
        withApi(() => ContentService.fetchReplies('post-1')),
        throwsHttpException(401),
      );
    });

    test('throws HTTPException on 404 INVALID_ID', () async {
      queueHttpError(404, error: 'INVALID_ID');

      await expectLater(
        withApi(() => ContentService.fetchReplies('post-1')),
        throwsHttpException(404),
      );
    });

    test('throws SocketException when the server cannot be reached', () async {
      api.queueResponse(StubResponse.error(const SocketException('refused')));

      await expectLater(
        withApi(() => ContentService.fetchReplies('post-1')),
        throwsA(isA<SocketException>()),
      );
    });
  });

  group('fetchUser', () {
    test('requests a user by id and caches it', () async {
      api.queueJson(<String, Object>{
        'user': userJson(id: 'user-1', username: 'kit', bio: 'hello'),
      });

      final User user = await withApi(() => ContentService.fetchUser('user-1'));

      final RecordedRequest recorded = api.requests.single;
      expect(recorded.request.method, equals('GET'));
      expect(
        recorded.request.url.toString(),
        equals('http://localhost:3000/api/user/user-1'),
      );

      expect(user.uuid, equals('user-1'));
      expect(user.username, equals('kit'));
      expect(user.bio, equals('hello'));
      expect(CacheService.fetch('user-1'), same(user));
    });

    test('returns a cached user without contacting the server', () async {
      final User user = User(uuid: 'user-1', username: 'kit');
      CacheService.store(o: user);

      final User fetched = await withApi(
        () => ContentService.fetchUser('user-1'),
      );

      expect(api.requests, isEmpty);
      expect(fetched, same(user));
    });

    test('noCache ignores the cached user', () async {
      CacheService.store(
        o: User(uuid: 'user-1', username: 'old name'),
      );
      api.queueJson(<String, Object>{
        'user': userJson(id: 'user-1', username: 'new name'),
      });

      final User fetched = await withApi(
        () => ContentService.fetchUser('user-1', noCache: true),
      );

      expect(api.requests, hasLength(1));
      expect(fetched.username, equals('new name'));
    });

    test('throws HTTPException on 401 no session', () async {
      queueHttpError(401);

      await expectLater(
        withApi(() => ContentService.fetchUser('user-1')),
        throwsHttpException(401),
      );
    });

    test('throws HTTPException on 404 INVALID_USER', () async {
      queueHttpError(404, error: 'INVALID_USER');

      await expectLater(
        withApi(() => ContentService.fetchUser('user-1')),
        throwsHttpException(404),
      );
    });

    test('throws SocketException when the server cannot be reached', () async {
      api.queueResponse(StubResponse.error(const SocketException('refused')));

      await expectLater(
        withApi(() => ContentService.fetchUser('user-1')),
        throwsA(isA<SocketException>()),
      );
    });
  });

  group('newestFeed', () {
    test('returns posts sorted by newest created date first', () async {
      await givenLocation();
      api.queueJson(<String, Object>{
        'posts': <Object>[
          postJson(id: 'older', time: '2026-01-01T12:00:00.000Z'),
          postJson(id: 'newer', time: '2026-01-02T12:00:00.000Z'),
          postJson(id: 'middle', time: '2026-01-01T18:00:00.000Z'),
        ],
        'replies': <Object>[],
      });

      await withApi(ContentService.fetchFeed);

      final List<Post> newest = ContentService.newestFeed;

      expect(
        newest.map((Post p) => p.uuid),
        equals(<String>['newer', 'middle', 'older']),
      );
    });

    test('uses updated time when present for sorting', () async {
      await givenLocation();
      api.queueJson(<String, Object>{
        'posts': <Object>[
          postJson(
            id: 'old-updated',
            time: '2026-01-01T12:00:00.000Z',
            updated: '2026-01-03T12:00:00.000Z',
          ),
          postJson(id: 'new-created', time: '2026-01-02T12:00:00.000Z'),
        ],
        'replies': <Object>[],
      });

      await withApi(ContentService.fetchFeed);

      final List<Post> newest = ContentService.newestFeed;

      expect(
        newest.map((Post p) => p.uuid),
        equals(<String>['old-updated', 'new-created']),
      );
    });

    test('returns a copy without mutating the feed order', () async {
      await givenLocation();
      api.queueJson(<String, Object>{
        'posts': <Object>[
          postJson(id: 'older', time: '2026-01-01T12:00:00.000Z'),
          postJson(id: 'newer', time: '2026-01-02T12:00:00.000Z'),
        ],
        'replies': <Object>[],
      });

      final List<Post> feed = await withApi(ContentService.fetchFeed);
      final List<Post> newest = ContentService.newestFeed;

      expect(
        newest.map((Post p) => p.uuid),
        equals(<String>['newer', 'older']),
      );
      expect(feed.map((Post p) => p.uuid), equals(<String>['older', 'newer']));
      expect(identical(feed, newest), isFalse);
    });
  });

  group('fetchUserContent', () {
    test(
      'requests the current user content and returns posts and replies',
      () async {
        api.queueJson(<String, Object>{
          'posts': <Object>[postJson(id: 'root')],
          'replies': <Object>[postJson(id: 'reply', replyingTo: 'root')],
        });

        final Map<String, List<Post>> content = await withApi(
          ContentService.fetchUserContent,
        );

        final RecordedRequest recorded = api.requests.single;
        expect(recorded.request.method, equals('GET'));
        expect(
          recorded.request.url.toString(),
          equals('http://localhost:3000/api/content'),
        );

        expect(content['posts'], hasLength(1));
        expect(content['posts']!.single.uuid, equals('root'));
        expect(content['replies'], hasLength(1));
        expect(content['replies']!.single.uuid, equals('reply'));

        final Map<String, List<Post>>? cached = CacheService.fetch(
          recorded.request.url.toString(),
        ) as Map<String, List<Post>>?;
        expect(cached, isNotNull);
        expect(cached!['posts']!.single.uuid, equals('root'));
        expect(cached['replies']!.single.uuid, equals('reply'));
        expect(CacheService.fetch('reply'), isA<Post>());
      },
    );

    test('returns cached content without contacting the server', () async {
      api.queueJson(<String, Object>{
        'posts': <Object>[postJson(id: 'root')],
        'replies': <Object>[],
      });

      final Map<String, List<Post>> first = await withApi(
        ContentService.fetchUserContent,
      );
      final Map<String, List<Post>> second = await withApi(
        ContentService.fetchUserContent,
      );

      expect(api.requests, hasLength(1));
      expect(second['posts']!.single.uuid, equals(first['posts']!.single.uuid));
      expect(second['replies'], isEmpty);
    });

    test('noCache ignores the cached content', () async {
      api.queueJson(<String, Object>{
        'posts': <Object>[postJson(id: 'first')],
        'replies': <Object>[],
      });
      await withApi(ContentService.fetchUserContent);

      api.queueJson(<String, Object>{
        'posts': <Object>[postJson(id: 'second')],
        'replies': <Object>[],
      });
      final Map<String, List<Post>> content = await withApi(
        () => ContentService.fetchUserContent(noCache: true),
      );

      expect(api.requests, hasLength(2));
      expect(content['posts']!.single.uuid, equals('second'));
    });

    test('throws HTTPException on 401 no session', () async {
      queueHttpError(401);

      await expectLater(
        withApi(ContentService.fetchUserContent),
        throwsHttpException(401),
      );
    });

    test('throws SocketException when the server cannot be reached', () async {
      api.queueResponse(StubResponse.error(const SocketException('refused')));

      await expectLater(
        withApi(ContentService.fetchUserContent),
        throwsA(isA<SocketException>()),
      );
    });
  });
}
