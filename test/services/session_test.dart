import 'dart:convert';
import 'dart:io';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:lilypad/services/session.dart';
import 'package:test/test.dart';

/// Matches the private key used by [SessionService] for its storage entry.
const String storageKey = 'lilypad_cookies';

void main() {
  setUp(() async {
    // Fresh in-memory secure storage for every test.
    FlutterSecureStorage.setMockInitialValues(<String, String>{});
    // `_cookies` is static, so clear it between tests too.
    await SessionService.clear();
  });

  group('parseSetCookie', () {
    test('parses a single cookie and strips its attributes', () {
      final List<Cookie> cookies = SessionService.parseSetCookie(
        'better-auth.session_token=abc123; Path=/; '
        'Expires=Wed, 21 Oct 2026 07:28:00 GMT; HttpOnly; Secure',
      );

      expect(cookies, hasLength(1));
      final Cookie cookie = cookies.single;
      expect(cookie.name, equals('better-auth.session_token'));
      expect(cookie.value, equals('abc123'));
      expect(cookie.path, equals('/'));
      expect(cookie.httpOnly, isTrue);
      expect(cookie.secure, isTrue);
      expect(cookie.expires, isNotNull);
    });

    test('does not split on the comma inside Expires', () {
      final List<Cookie> cookies = SessionService.parseSetCookie(
        'token=abc; Expires=Wed, 21 Oct 2026 07:28:00 GMT; HttpOnly',
      );

      expect(cookies.map((Cookie c) => '${c.name}=${c.value}'), ['token=abc']);
    });

    test('splits comma-joined cookies with no space after the comma', () {
      // package:http joins repeated headers with a bare ','.
      final List<Cookie> cookies = SessionService.parseSetCookie(
        'a=1; Path=/,b=2; Path=/; HttpOnly',
      );

      expect(cookies.map((Cookie c) => '${c.name}=${c.value}'), ['a=1', 'b=2']);
      expect(cookies[1].httpOnly, isTrue);
    });

    test('splits comma-separated cookies that do include a space', () {
      final List<Cookie> cookies = SessionService.parseSetCookie(
        'a=1; Path=/, b=2; Path=/',
      );

      expect(cookies.map((Cookie c) => '${c.name}=${c.value}'), ['a=1', 'b=2']);
    });

    test('parses attributes as attributes, not as cookies', () {
      final List<Cookie> cookies = SessionService.parseSetCookie(
        'token=abc; Path=/; Domain=localhost; SameSite=Lax; HttpOnly',
      );

      expect(cookies, hasLength(1));
      expect(cookies.single.domain, equals('localhost'));
      expect(cookies.single.sameSite, equals(SameSite.lax));
    });

    test('returns an empty list for an empty header', () {
      expect(SessionService.parseSetCookie(''), isEmpty);
      expect(SessionService.parseSetCookie('   '), isEmpty);
    });

    test('skips malformed input instead of throwing', () {
      expect(
        () => SessionService.parseSetCookie('not-a-cookie'),
        returnsNormally,
      );
      expect(SessionService.parseSetCookie('not-a-cookie'), isEmpty);
    });

    test('preserves = padding in cookie values', () {
      final List<Cookie> cookies = SessionService.parseSetCookie(
        'token=YWJjZA==; Path=/',
      );

      expect(cookies.single.value, equals('YWJjZA=='));
    });

    test('parses a deletion cookie (empty value, Max-Age=0)', () {
      final List<Cookie> cookies = SessionService.parseSetCookie(
        'token=; Max-Age=0; Path=/',
      );

      expect(cookies, hasLength(1));
      expect(cookies.single.name, equals('token'));
      expect(cookies.single.value, isEmpty);
      expect(cookies.single.maxAge, equals(0));
    });

    test('parses a realistic better-auth header', () {
      final List<Cookie> cookies = SessionService.parseSetCookie(
        'better-auth.session_token=Ek2v9c3x.7fHq; Max-Age=604800; '
        'Path=/; HttpOnly; SameSite=Lax',
      );

      expect(cookies, hasLength(1));
      final Cookie cookie = cookies.single;
      expect(cookie.name, equals('better-auth.session_token'));
      expect(cookie.value, equals('Ek2v9c3x.7fHq'));
      expect(cookie.maxAge, equals(604800));
      expect(cookie.sameSite, equals(SameSite.lax));
    });
  });

  group('getCookieHeader', () {
    test('returns null when no cookies are stored', () {
      expect(SessionService.getCookieHeader(), isNull);
    });

    // Cookie formatting (single cookie, joining multiple with '; ') is
    // covered by the capture group via the same assertions.
  });

  group('capture', () {
    test('stores a cookie in memory', () async {
      await SessionService.capture('token=abc; Path=/; HttpOnly; SameSite=Lax');

      expect(SessionService.getCookieHeader(), equals('token=abc'));
    });

    test('overwrites a refreshed cookie instead of duplicating it', () async {
      await SessionService.capture('token=old; Path=/');
      await SessionService.capture('token=new; Path=/');

      expect(SessionService.getCookieHeader(), equals('token=new'));
    });

    test('merges cookies with different names', () async {
      await SessionService.capture('a=1; Path=/');
      await SessionService.capture('b=2; Path=/');

      expect(SessionService.getCookieHeader(), equals('a=1; b=2'));
    });

    test('removes a cookie expired with Max-Age=0', () async {
      await SessionService.capture('token=abc; Path=/');
      await SessionService.capture('token=; Max-Age=0; Path=/');

      expect(SessionService.getCookieHeader(), isNull);
    });

    test('removes a cookie expired with a past Expires', () async {
      await SessionService.capture('token=abc; Path=/');
      await SessionService.capture(
        'token=; Expires=Thu, 01 Jan 1970 00:00:00 GMT',
      );

      expect(SessionService.getCookieHeader(), isNull);
    });

    test('keeps other cookies when one is deleted', () async {
      await SessionService.capture('a=1; Path=/, b=2; Path=/');
      await SessionService.capture('a=; Max-Age=0; Path=/');

      expect(SessionService.getCookieHeader(), equals('b=2'));
    });

    test('leaves existing cookies alone on a malformed header', () async {
      await SessionService.capture('token=abc; Path=/');
      await SessionService.capture('not-a-cookie');

      expect(SessionService.getCookieHeader(), equals('token=abc'));
    });
  });

  group('clear', () {
    test('empties memory and storage', () async {
      await SessionService.capture('token=abc; Path=/');
      await SessionService.clear();

      expect(SessionService.getCookieHeader(), isNull);
      expect(await FlutterSecureStorage().read(key: storageKey), isNull);
    });

    test('stays empty after a later init', () async {
      await SessionService.capture('token=abc; Path=/');
      await SessionService.clear();
      await SessionService.init();

      expect(SessionService.getCookieHeader(), isNull);
      expect(await FlutterSecureStorage().read(key: storageKey), isNull);
    });
  });

  group('init', () {
    test('loads cookies persisted by a previous run', () async {
      FlutterSecureStorage.setMockInitialValues(<String, String>{
        storageKey: jsonEncode(<String>[
          'token=abc; Path=/; HttpOnly',
          'theme=dark; Path=/',
        ]),
      });

      await SessionService.init();

      expect(SessionService.getCookieHeader(), equals('token=abc; theme=dark'));
    });

    test('does not duplicate cookies when called twice', () async {
      FlutterSecureStorage.setMockInitialValues(<String, String>{
        storageKey: jsonEncode(<String>['token=abc; Path=/']),
      });

      await SessionService.init();
      await SessionService.init();

      expect(SessionService.getCookieHeader(), equals('token=abc'));
    });

    test('ignores expired cookies stored on disk', () async {
      FlutterSecureStorage.setMockInitialValues(<String, String>{
        storageKey: jsonEncode(<String>[
          'token=; Max-Age=0; Path=/',
          'theme=dark; Path=/',
        ]),
      });

      await SessionService.init();

      expect(SessionService.getCookieHeader(), equals('theme=dark'));
    });

    test('malformed entries stored on disk', () async {
      FlutterSecureStorage.setMockInitialValues(<String, String>{
        storageKey: jsonEncode(<String>['not-a-cookie', 'theme=dark; Path=/']),
      });

      await SessionService.init();

      expect(SessionService.getCookieHeader(), equals('theme=dark'));
    });

    test('corrupted JSON in storage', () async {
      FlutterSecureStorage.setMockInitialValues(<String, String>{
        storageKey: 'not json at all',
      });

      await SessionService.init();

      expect(SessionService.getCookieHeader(), isNull);
    });

    // Known issue: stored entries are read as dynamic, so a non-string
    // entry hits String.trim on an int and crashes init.
    // Re-enable once that is fixed.
    test('non-string entries in storage', () async {
      FlutterSecureStorage.setMockInitialValues(<String, String>{
        storageKey: jsonEncode(<dynamic>[123, true]),
      });

      await SessionService.init();

      expect(SessionService.getCookieHeader(), isNull);
    });

    test('is a no-op when storage is empty', () async {
      await SessionService.init();

      expect(SessionService.getCookieHeader(), isNull);
    });
  });

  group('round trip', () {
    test('restores captured cookies on init', () async {
      await SessionService.capture('token=abc; Path=/; HttpOnly');
      await SessionService.capture('theme=dark; Path=/');

      // init() reloads from storage, simulating an app restart.
      await SessionService.init();

      expect(SessionService.getCookieHeader(), equals('token=abc; theme=dark'));
    });

    test('retains a cookie with a future Expires across init', () async {
      await SessionService.capture(
        'token=abc; Expires=Wed, 21 Oct 2099 07:28:00 GMT; Path=/',
      );

      await SessionService.init();

      expect(SessionService.getCookieHeader(), equals('token=abc'));
    });
  });

  group('persistence', () {
    test('capture writes cookies to secure storage', () async {
      await SessionService.capture('token=abc; Path=/');

      final String? stored = await FlutterSecureStorage().read(key: storageKey);

      expect(stored, isNotNull);
      expect(stored, contains('token'));
      expect(stored, contains('abc'));
    });

    test('capture updates the stored value on refresh', () async {
      await SessionService.capture('token=old; Path=/');
      await SessionService.capture('token=new; Path=/');

      final String? stored = await FlutterSecureStorage().read(key: storageKey);

      expect(stored, isNotNull);
      expect(stored, contains('new'));
      expect(stored, isNot(contains('old')));
    });
  });
}
