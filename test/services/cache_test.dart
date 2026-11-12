import 'package:lilypad/models/post.dart';
import 'package:lilypad/models/user.dart';
import 'package:lilypad/services/cache.dart';
import 'package:test/test.dart';

void main() {
  setUp(() {
    CacheService.clear();
  });

  group('store and fetch with explicit key', () {
    test('stores and retrieves an object by key', () {
      final user = User(uuid: 'u1', username: 'kit');

      CacheService.store(o: user, key: 'custom-key');

      final fetched = CacheService.fetch('custom-key');

      expect(fetched, same(user));
    });

    test('returns null for a missing key', () {
      expect(CacheService.fetch('missing'), isNull);
    });

    test('overwrites an existing entry for the same key', () {
      CacheService.store(o: 'first', key: 'k');
      CacheService.store(o: 'second', key: 'k');

      expect(CacheService.fetch('k'), equals('second'));
    });
  });

  group('store with derived key', () {
    test('stores a User using uuid as key', () {
      final user = User(uuid: 'user-123', username: 'alice');

      CacheService.store(o: user);

      final fetched = CacheService.fetch('user-123');

      expect(fetched, same(user));
    });

    test('stores an anonymous User under the "anon" key when uuid is null', () {
      final user = User(uuid: null, username: 'anon');

      CacheService.store(o: user);

      final fetched = CacheService.fetch('anon');

      expect(fetched, same(user));
    });

    test('stores a Post using uuid as key', () {
      final post = Post(
        uuid: 'post-123',
        content: 'hello',
        user: User(uuid: 'u1', username: 'alice'),
        created: DateTime.utc(2026, 1, 1),
      );

      CacheService.store(o: post);

      final fetched = CacheService.fetch('post-123');

      expect(fetched, same(post));
    });

    test('stores other objects using hashCode string as key', () {
      const value = 'plain-string';

      CacheService.store(o: value);

      final fetched = CacheService.fetch(value.hashCode.toString());

      expect(fetched, same(value));
    });
  });

  group('clear', () {
    test('removes all cached entries', () {
      CacheService.store(o: 'a', key: 'a');
      CacheService.store(o: 'b', key: 'b');

      CacheService.clear();

      expect(CacheService.fetch('a'), isNull);
      expect(CacheService.fetch('b'), isNull);
    });
  });

  group('freeInvalid', () {
    test('keeps valid (non-expired) entries', () {
      CacheService.store(o: 'value', key: 'k');

      CacheService.freeInvalid();

      expect(CacheService.fetch('k'), equals('value'));
    });
  });
}
