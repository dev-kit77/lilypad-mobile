import 'dart:convert';

import 'package:http/http.dart';
import 'package:lilypad/builders/auth.dart';
import 'package:lilypad/builders/user.dart';
import 'package:lilypad/models/user.dart';
import 'package:lilypad/services/api.dart';
import 'package:lilypad/services/cache.dart';

class UserService {
  static CurrentUser? _user;

  UserService._();

  /// Creates a new account and signs the user in.
  ///
  /// POST /api/auth/sign-up/email
  ///
  /// Request:  { name: string; email: string; password: string }
  ///           name <= 100 chars, valid email, password >= 8 chars.
  /// Auth:     none
  ///
  /// Expected 200: Better Auth session payload, e.g.
  ///   { token: string; user: { id, name, email, emailVerified, image, ... } }
  /// Expected 400: { code: "VALIDATION" } (thrown by the before-hook)
  /// Expected 422: Better Auth error for duplicate email / weak password.
  static Future<bool> createAccount(
    String username,
    String email,
    String password,
  ) async {
    //build request
    Request req = AuthRequestBuilder.signUp(username, email, password);

    //init response var
    final Response res;

    //get response from the api
    try {
      res = await APIService.send(req);
    } on Exception {
      //rethrow error up to ui caller
      rethrow;
    }

    //return status based on if token recieved
    return jsonDecode(res.body)['token'] != null ? true : false;
  }

  /// Signs an existing user in.
  ///
  /// POST /api/auth/sign-in/email
  ///
  /// Request:  { email: string; password: string }
  /// Auth:     none
  ///
  /// Expected 200: Better Auth session payload + `Set-Cookie` session cookie.
  ///   { token: string; user: { id, name, email, ... } }
  /// Expected 401: invalid credentials.
  static Future<bool> login(String email, String password) async {
    //build request
    Request req = AuthRequestBuilder.signIn(email, password);

    //init response var
    final Response res;

    //get response from the api
    try {
      res = await APIService.send(req);
    } on Exception {
      //rethrow error up to ui caller
      rethrow;
    }

    //return status based on if token recieved
    return jsonDecode(res.body)['token'] != null ? true : false;
  }

  /// Checks for an existing authenticated session.
  ///
  /// GET /api/auth/get-session
  ///
  /// Request:  none (session cookie)
  /// Auth:     session
  ///
  /// Expected 200: {
  ///   session: { id, token, userId, expiresAt, ... },
  ///   user: { id, name, email, emailVerified, image, role, ... }
  /// }
  /// Expected 200 (no session): null
  static Future<bool> fetchSession() async {
    //build request
    Request req = AuthRequestBuilder.sessionRefresh();

    //init response var
    final Response res;

    //get response from the api
    try {
      res = await APIService.send(req);
    } on Exception {
      //rethrow error up to ui caller
      rethrow;
    }

    //return status based on if session recieved
    return jsonDecode(res.body)['session'] != null ? true : false;
  }

  /// Retrieves the current user's profile and settings.
  ///
  /// GET /api/user
  ///
  /// Request:  none
  /// Auth:     session
  ///
  /// Expected 200: { user: UserData }
  ///   e.g. { user: { userId, username, status?, bio?,
  ///                  settings: { dark, anon } } }
  /// Expected 401: no session / unknown session user.
  /// Expected 403: { error: "USER_BANNED" } (active ban).
  /// Expected 404: { error: "INVALID_USER" }.
  static Future<CurrentUser> fetch({bool? noCache = false}) async {
    if (_user != null) {
      //fetch any cached post
      CurrentUser? cachedPost = CacheService.fetch(_user!.uuid) as CurrentUser?;

      //check if cached post found
      if (cachedPost != null && noCache == false) {
        return cachedPost;
      }
    }

    //build request
    Request req = UserRequestBuilder.getUser();

    //init response var
    final Response res;

    //get response from the api
    try {
      res = await APIService.send(req);
    } on Exception {
      //rethrow error up to ui caller
      rethrow;
    }

    //get user json to create user objects
    Map<String, dynamic> jsonMap = jsonDecode(res.body)['user'];

    //create new user
    CurrentUser newUser = CurrentUser.fromMap(jsonMap);

    //cache new user
    CacheService.store(o: newUser);

    //update current user
    _user = CurrentUser.fromMap(jsonMap);

    return newUser;
  }

  /// Updates the current user's profile and/or settings.
  ///
  /// PUT /api/user
  ///
  /// Request (at least one field):
  ///   { username?: string (1-100); status?: string (1-100);
  ///     bio?: string (1-100); settings?: { dark?: boolean; anon?: boolean } }
  /// Auth:     session
  ///
  /// Expected 200: { user: UserData } (updated values)
  /// Expected 400: { error: "INVALID_FIELD" } (empty body)
  /// Expected 401: no session.
  /// Expected 404: { error: "INVALID_USER" }.
  /// Expected 500: { error: "INTERNAL_SERVER" }.
  static Future<CurrentUser> update({
    String? username,
    String? status,
    String? bio,
    bool? dark,
    bool? anon,
  }) async {
    //build request
    Request req = UserRequestBuilder.updateUser(
      username: username,
      status: status,
      bio: bio,
      dark: dark,
      anon: anon,
    );

    //init response var
    final Response res;

    //get response from the api
    try {
      res = await APIService.send(req);
    } on Exception {
      //rethrow error up to ui caller
      rethrow;
    }

    //get user json to create user objects
    Map<String, dynamic> jsonMap = jsonDecode(res.body)['user'];

    //create new user
    CurrentUser newUser = CurrentUser.fromMap(jsonMap);

    //cache new user
    CacheService.store(o: newUser);

    //update current user
    _user = CurrentUser.fromMap(jsonMap);

    return newUser;
  }

  /// Deletes the current user's account and anonymises their data.
  ///
  /// DELETE /api/user
  ///
  /// Request:  none
  /// Auth:     session
  ///
  /// Behaviour: deletes sessions + accounts, anonymises name/email/image,
  ///            blanks profile, forces anon settings on. Authored posts remain.
  ///
  /// Expected 200: { status: "OK" }
  /// Expected 401: no session.
  /// Expected 404: { error: "INVALID_USER" }.
  /// Expected 500: { error: "INTERNAL_SERVER" }.
  static Future<bool> delete() async {
    //build request
    Request req = UserRequestBuilder.deleteUser();

    //init response var
    final Response res;

    //get response from the api
    try {
      res = await APIService.send(req);
    } on Exception {
      //rethrow error up to ui caller
      rethrow;
    }

    //return status based on if token recieved
    return jsonDecode(res.body)['status'] != null ? true : false;
  }

  /// Signs the current user out.
  ///
  /// POST /api/auth/sign-out
  ///
  /// Request:  none
  /// Auth:     session
  ///
  /// Expected 200: { success: true }
  /// Expected 401: no session.
  static Future<bool> logout() async {
    //build request
    Request req = AuthRequestBuilder.signOut();

    //init response var
    final Response res;

    //get response from the api
    try {
      res = await APIService.send(req);
    } on Exception {
      //rethrow error up to ui caller
      rethrow;
    }

    //return status based on if token recieved
    return jsonDecode(res.body)['success'] != null ? true : false;
  }

  /// Retrieves a GDPR Subject Access Request export of the current user's data.
  ///
  /// GET /api/user/gdpr-sar
  ///
  /// Request:  none
  /// Auth:     session
  ///
  /// Expected 200: downloadable JSON (Content-Disposition attachment) with:
  ///   {
  ///     generatedAt: string,
  ///     requestType: "GDPR_ARTICLE_15_SAR",
  ///     user: userData,
  ///     posts: [ post & { _count: { upvotes, postReplies } }]>,
  ///     reportsFiled: [report],
  ///     reportsAgainstUser: [report with reporter anonymised]
  ///   }
  /// Expected 401: no session.
  /// Expected 404: { error: "INVALID_USER" }.
  static Future<Map<String, Object?>> fetchGdprSar() async {
    //build request
    Request req = UserRequestBuilder.gdprSar();

    //init response var
    final Response res;

    //get response from the api
    try {
      res = await APIService.send(req);
    } on Exception {
      //rethrow error up to ui caller
      rethrow;
    }

    //return status based on if token recieved
    return jsonDecode(res.body);
  }
}
