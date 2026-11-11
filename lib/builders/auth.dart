import 'dart:convert';

import 'package:http/http.dart';
import 'package:lilypad/services/api.dart';

class AuthRequestBuilder {
  /// POST /api/auth/sign-up/email
  ///
  /// Request:  { name: string; email: string; password: string }
  ///           name <= 100 chars, valid email, password >= 8 chars.
  /// Auth:     none
  static Request signUp(String username, String email, String password) {
    //init request
    Request r = Request('post', APIService.getUri(path: 'auth/sign-up/email'));

    //init header
    r.headers.clear();
    r.headers.addAll(<String, String>{"content-type": "application/json"});

    //set encoding
    r.encoding = utf8;

    //encode body
    r.body = jsonEncode(<String, String>{
      "name": username,
      "email": email,
      "password": password,
    });

    return r;
  }

  /// POST /api/auth/sign-in/email
  ///
  /// Request:  { email: string; password: string }
  /// Auth:     none
  static Request signIn(String email, String password) {
    //init request
    Request r = Request('post', APIService.getUri(path: 'auth/sign-in/email'));

    //init header
    r.headers.clear();
    r.headers.addAll(<String, String>{"content-type": "application/json"});

    //set encoding
    r.encoding = utf8;

    //encode body
    r.body = jsonEncode(<String, String>{"email": email, "password": password});

    return r;
  }

  /// POST /api/auth/sign-out
  ///
  /// Request:  none
  /// Auth:     session
  static Request signOut() {
    //init request
    Request r = Request('post', APIService.getUri(path: 'auth/sign-out'));

    //init header
    r.headers.clear();

    //set encoding
    r.encoding = utf8;

    return r;
  }

  /// GET /api/auth/get-session
  ///
  /// Request:  none
  /// Auth:     session
  static Request sessionRefresh() {
    //init request
    Request r = Request('post', APIService.getUri(path: 'auth/get-session'));

    //init header
    r.headers.clear();

    //set encoding
    r.encoding = utf8;

    return r;
  }
}
