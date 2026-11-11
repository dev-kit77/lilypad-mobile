import 'dart:convert';

import 'package:http/http.dart';
import 'package:lilypad/services/api.dart';

class UserRequestBuilder {
  /// GET /api/user
  ///
  /// Body:  none
  /// Auth:     session
  static Request getUser() {
    //init request
    Request r = Request('GET', APIService.getUri(path: 'user'));

    //init header
    r.headers.clear();

    //set encoding
    r.encoding = utf8;

    return r;
  }

  /// GET /api/content
  ///
  /// Body:  none
  /// Auth:     session
  static Request getContent() {
    //init request
    Request r = Request('GET', APIService.getUri(path: 'content'));

    //init header
    r.headers.clear();

    //set encoding
    r.encoding = utf8;

    return r;
  }

  /// PUT /api/user
  ///
  /// Body:  { username?: string (1-100); status?: string (1-100);
  ///             bio?: string (1-100); settings?: { dark?: boolean; anon?: boolean } }
  ///           at least one field required.
  /// Auth:     session
  static Request updateUser({
    String? username,
    String? status,
    String? bio,
    bool? dark,
    bool? anon,
  }) {
    //init request
    Request r = Request('PUT', APIService.getUri(path: 'user'));

    //init header
    r.headers.clear();
    r.headers.addAll(<String, String>{"content-type": "application/json"});

    //set encoding
    r.encoding = utf8;

    //encode body
    r.body = jsonEncode(<String, Object?>{
      "username": ?username,
      "status": ?status,
      "bio": ?bio,
      if (dark != null || anon != null)
        "settings": <String, bool>{"dark": ?dark, "anon": ?anon},
    });

    return r;
  }

  /// DELETE /api/user
  ///
  /// Body:  none
  /// Auth:     session
  static Request deleteUser() {
    //init request
    Request r = Request('DELETE', APIService.getUri(path: 'user'));

    //init header
    r.headers.clear();

    //set encoding
    r.encoding = utf8;

    return r;
  }

  /// GET /api/user/gdpr-sar
  ///
  /// Body:  none
  /// Auth:     session
  static Request gdprSar() {
    //init request
    Request r = Request('GET', APIService.getUri(path: 'user/gdpr-sar'));

    //init header
    r.headers.clear();

    //set encoding
    r.encoding = utf8;

    return r;
  }
}
