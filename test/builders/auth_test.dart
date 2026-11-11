import 'dart:convert';

import 'package:http/http.dart';
import 'package:lilypad/builders/auth.dart';
import 'package:test/test.dart';

void main() {
  test('build sign up post request', () {
    Request r = AuthRequestBuilder.signUp(
      "kit",
      "kit@example.com",
      "password123",
    );
    expect(r.method, equals('POST'));
    expect(
      r.url.toString(),
      equals('http://localhost:3000/api/auth/sign-up/email'),
    );
    expect(
      r.headers,
      equals(<String, String>{"content-type": "application/json"}),
    );
    expect(
      jsonDecode(r.body),
      equals(<String, String>{
        "name": "kit",
        "email": "kit@example.com",
        "password": "password123",
      }),
    );
    expect(r.encoding, equals(utf8));
  });

  test('build sign in post request', () {
    Request r = AuthRequestBuilder.signIn("kit@example.com", "password123");
    expect(r.method, equals('POST'));
    expect(
      r.url.toString(),
      equals('http://localhost:3000/api/auth/sign-in/email'),
    );
    expect(
      r.headers,
      equals(<String, String>{"content-type": "application/json"}),
    );
    expect(
      jsonDecode(r.body),
      equals(<String, String>{
        "email": "kit@example.com",
        "password": "password123",
      }),
    );
    expect(r.encoding, equals(utf8));
  });

  test('build sign out post request', () {
    Request r = AuthRequestBuilder.signOut();
    expect(r.method, equals('POST'));
    expect(r.url.toString(), equals('http://localhost:3000/api/auth/sign-out'));
    expect(r.headers, isEmpty);
    expect(r.body, isEmpty);
    expect(r.encoding, equals(utf8));
  });

  test('build session refresh get request', () {
    Request r = AuthRequestBuilder.sessionRefresh();
    expect(r.method, equals('GET'));
    expect(
      r.url.toString(),
      equals('http://localhost:3000/api/auth/get-session'),
    );
    expect(r.headers, isEmpty);
    expect(r.body, isEmpty);
    expect(r.encoding, equals(utf8));
  });
}
