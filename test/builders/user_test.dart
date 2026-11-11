import 'dart:convert';

import 'package:http/http.dart';
import 'package:lilypad/builders/user.dart';
import 'package:test/test.dart';

void main() {
  test('build get user get request', () {
    Request r = UserRequestBuilder.getUser();
    expect(r.method, equals('GET'));
    expect(r.url.toString(), equals('http://localhost:3000/api/user'));
    expect(r.headers, isEmpty);
    expect(r.body, isEmpty);
    expect(r.encoding, equals(utf8));
  });

  test('build get content get request', () {
    Request r = UserRequestBuilder.getContent();
    expect(r.method, equals('GET'));
    expect(r.url.toString(), equals('http://localhost:3000/api/content'));
    expect(r.headers, isEmpty);
    expect(r.body, isEmpty);
    expect(r.encoding, equals(utf8));
  });

  test('build update user put request with a username', () {
    Request r = UserRequestBuilder.updateUser(username: "kit");
    expect(r.method, equals('PUT'));
    expect(r.url.toString(), equals('http://localhost:3000/api/user'));
    expect(
      r.headers,
      equals(<String, String>{"content-type": "application/json"}),
    );
    expect(jsonDecode(r.body), equals(<String, Object?>{"username": "kit"}));
    expect(r.encoding, equals(utf8));
  });

  test('build update user put request with profile fields', () {
    Request r = UserRequestBuilder.updateUser(
      username: "kit",
      status: "pond hopping",
      bio: "i am a lilypad",
    );
    expect(r.method, equals('PUT'));
    expect(r.url.toString(), equals('http://localhost:3000/api/user'));
    expect(
      r.headers,
      equals(<String, String>{"content-type": "application/json"}),
    );
    expect(
      jsonDecode(r.body),
      equals(<String, Object?>{
        "username": "kit",
        "status": "pond hopping",
        "bio": "i am a lilypad",
      }),
    );
    expect(r.encoding, equals(utf8));
  });

  test('build update user put request with settings', () {
    Request r = UserRequestBuilder.updateUser(dark: true, anon: false);
    expect(r.method, equals('PUT'));
    expect(r.url.toString(), equals('http://localhost:3000/api/user'));
    expect(
      r.headers,
      equals(<String, String>{"content-type": "application/json"}),
    );
    expect(
      jsonDecode(r.body),
      equals(<String, Object?>{
        "settings": <String, bool>{"dark": true, "anon": false},
      }),
    );
    expect(r.encoding, equals(utf8));
  });

  test('build update user put request with a profile field and a setting', () {
    Request r = UserRequestBuilder.updateUser(
      bio: "i am a lilypad",
      anon: true,
    );
    expect(r.method, equals('PUT'));
    expect(r.url.toString(), equals('http://localhost:3000/api/user'));
    expect(
      r.headers,
      equals(<String, String>{"content-type": "application/json"}),
    );
    expect(
      jsonDecode(r.body),
      equals(<String, Object?>{
        "bio": "i am a lilypad",
        "settings": <String, bool>{"anon": true},
      }),
    );
    expect(r.encoding, equals(utf8));
  });

  test('build delete user delete request', () {
    Request r = UserRequestBuilder.deleteUser();
    expect(r.method, equals('DELETE'));
    expect(r.url.toString(), equals('http://localhost:3000/api/user'));
    expect(r.headers, isEmpty);
    expect(r.body, isEmpty);
    expect(r.encoding, equals(utf8));
  });

  test('build gdpr sar get request', () {
    Request r = UserRequestBuilder.gdprSar();
    expect(r.method, equals('GET'));
    expect(r.url.toString(), equals('http://localhost:3000/api/user/gdpr-sar'));
    expect(r.headers, isEmpty);
    expect(r.body, isEmpty);
    expect(r.encoding, equals(utf8));
  });
}
