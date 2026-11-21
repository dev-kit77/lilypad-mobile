import 'dart:convert';

import 'package:http/http.dart';
import 'package:lilypad/builders/content.dart';
import 'package:lilypad/builders/user.dart';
import 'package:lilypad/services/api.dart';
import 'package:lilypad/services/cache.dart';
import 'package:lilypad/services/geolocation.dart';
import 'package:lilypad/models/post.dart';
import 'package:lilypad/models/user.dart';
import 'package:lilypad/services/log.dart';

class ContentService {
  static List<Post> _feed = <Post>[];
  static List<Post> _userPosts = <Post>[];
  static List<Post> _userReplies = <Post>[];

  ContentService._();

  /// Retrieves the nearby content feed for the current location.
  ///
  /// GET /api/feed-spatial?lat=&lon=
  ///
  /// Expected 200: { posts: SpatialPostItem[]
  ///   replies: SpatialPostItem[] }
  ///   Root posts within 1 km, sorted ascending by distanceKm, hidden excluded.
  ///   distanceKm is rounded to 2 decimals.
  /// Expected 400: { error: "INVALID_FIELD" } (missing/invalid coords).
  /// Expected 401: no session.
  /// Expected 500: { error: "INTERNAL_SERVER" }.
  static Future<List<Post>> fetchFeed({bool noCache = false}) async {
    //get current location
    Map<String, double?> currLocation = GeolocationService.location;

    //check location ready
    if (currLocation.values.contains(null)) {
      LogService.err('Location Service not ready.', src: 'Content Service');
      throw Exception('Location Not Available');
    }

    //build request with location
    Request req = ContentRequestBuilder.feedSpatial(
      currLocation['lat']!,
      currLocation['lon']!,
    );

    //retrieve feed cache if any
    List<Post>? feedCache =
        CacheService.fetch(req.url.toString()) as List<Post>?;

    //check feed cache to see if we have a pre-prepared feed
    if (feedCache != null && noCache == false) {
      return feedCache;
    }

    //init response var
    final Response res;

    //get response from the api
    try {
      res = await APIService.send(req);
    } on Exception {
      //rethrow error up to ui caller
      rethrow;
    }

    //parse the response from the api
    List<Post> newFeed = _parseFeed(res)['posts']!;

    //cache our new feed data
    CacheService.store(o: newFeed, key: req.url.toString());

    //init feed variable
    _feed = List.from(newFeed);

    //return new feed separate from one stored in cache
    return List.from(_feed);
  }

  static Map<String, List<Post>> _parseFeed(Response r) {
    //decode json and convert to lists of posts and replies
    List<Post> posts = List.from(
      jsonDecode(r.body)['posts'].map((p) => Post.fromJson(p)),
    );
    List<Post> replies = List.from(
      jsonDecode(r.body)['replies'].map((r) => Post.fromJson(r)),
    );

    //create a union indexing all posts for adding replies to all posts including sub-replys
    Map<String, Post> allByID = <String, Post>{
      for (Post post in posts) post.uuid: post,
      for (Post reply in replies) reply.uuid: reply,
    };

    //cache each post as we have a nice collection of all the data we need
    allByID.forEach((key, val) => CacheService.store(o: val, key: key));

    //loop for all replies and link to bound posts
    for (Post reply in replies) {
      allByID[reply.replying]?.linkReply(reply);
    }

    //return posts list as stem of tree and replies so user replies can be separated as these may not have accompaning post
    //replies could contain orphaned replies but these should be discarded in main feed
    return {'posts': posts, 'replies': replies};
  }

  /// Retrieves a single post by its ID.
  ///
  /// GET /api/content/post/:postId
  ///
  /// Expected 200: { post: PostItem }
  /// Expected 401: no session.
  /// Expected 403: { error: "INVALID_USER" } (post is hidden).
  /// Expected 404: { error: "INVALID_ID" }.
  static Future<Post> fetchPost(String postId, {bool noCache = false}) async {
    //fetch any cached post
    Post? cachedPost = CacheService.fetch(postId) as Post?;

    //check if cached post found
    if (cachedPost != null && noCache == false) {
      return cachedPost;
    }

    //build request
    Request req = ContentRequestBuilder.getPost(postId);

    //init response var
    final Response res;

    //get response from the api
    try {
      res = await APIService.send(req);
    } on Exception {
      //rethrow error up to ui caller
      rethrow;
    }

    //parse the response from the api
    Post fetchedPost = Post.fromJson(jsonDecode(res.body)['post']);

    //cache our new feed data
    CacheService.store(o: fetchedPost);

    //return new feed separate from one stored in cache
    return fetchedPost;
  }

  /// Creates a new root post at the current location.
  ///
  /// POST /api/content/post
  ///
  /// Expected 200: { post: PostItem }
  /// Expected 400: { error: "INVALID_FIELD" } (empty content / missing coords).
  /// Expected 401: no session.
  /// Expected 404: { error: "INVALID_ID" }.
  /// Expected 500: { error: "INTERNAL_SERVER" }.
  static Future<Post> newPost(String content) async {
    //get current location
    Map<String, double?> currLocation = GeolocationService.location;

    //check location ready
    if (currLocation.values.contains(null)) {
      LogService.err('Location Service not ready.', src: 'Content Service');
      throw Exception('Location Not Available');
    }

    //build request with location
    Request req = ContentRequestBuilder.createPost(
      content,
      currLocation['lat']!,
      currLocation['lon']!,
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

    //parse the response from the api
    Post fetchedPost = Post.fromJson(jsonDecode(res.body)['post']);

    //cache our new feed data
    CacheService.store(o: fetchedPost);

    //return new feed separate from one stored in cache
    return fetchedPost;
  }

  /// Creates a reply to the post identified by [postId].
  ///
  /// POST /api/content/post/:postId/reply
  ///
  /// Expected 200: { post: PostItem } (the created reply, with `replyingTo`)
  /// Expected 400: { error: "INVALID_FIELD" } (empty content).
  /// Expected 401: no session.
  /// Expected 404: { error: "INVALID_ID" } (parent missing or hidden).
  /// Expected 500: { error: "INTERNAL_SERVER" }.
  static Future<Post> newReply(String postId, String content) async {
    //build request
    Request req = ContentRequestBuilder.createReply(postId, content);

    //init response var
    final Response res;

    //get response from the api
    try {
      res = await APIService.send(req);
    } on Exception {
      //rethrow error up to ui caller
      rethrow;
    }

    //parse the response from the api
    Post fetchedPost = Post.fromJson(jsonDecode(res.body)['post']);

    //remove cache of original inaccurate post
    CacheService.free(postId);

    //cache our new post data
    CacheService.store(o: fetchedPost);

    //return new feed separate from one stored in cache
    return fetchedPost;
  }

  /// Updates the content of a post authored by the current user.
  ///
  /// PUT /api/content/post/:postId
  ///
  /// Expected 200: { post: PostItem } (with `updated` timestamp set)
  /// Expected 400: { error: "INVALID_FIELD" }.
  /// Expected 401: no session.
  /// Expected 403: { error: "INVALID_USER" } (not author).
  /// Expected 404: { error: "INVALID_ID" }.
  /// Expected 500: { error: "INTERNAL_SERVER" }.
  static Future<Post> modifyPost(String postId, String content) async {
    //build request
    Request req = ContentRequestBuilder.updatePost(postId, content);

    //init response var
    final Response res;

    //get response from the api
    try {
      res = await APIService.send(req);
    } on Exception {
      //rethrow error up to ui caller
      rethrow;
    }

    //parse the response from the api
    Post fetchedPost = Post.fromJson(jsonDecode(res.body)['post']);

    //cache our new feed data
    CacheService.store(o: fetchedPost);

    //return new feed separate from one stored in cache
    return fetchedPost;
  }

  /// Deletes a post authored by the current user.
  ///
  /// DELETE /api/content/post/:postId
  ///
  /// Expected 200: { status: "OK" }
  /// Expected 401: no session.
  /// Expected 403: { error: "INVALID_USER" } (not author).
  /// Expected 404: { error: "INVALID_ID" }.
  /// Expected 500: { error: "INVALID_FIELD" | "INTERNAL_SERVER" }.
  static Future<bool> removePost(String postId) async {
    //build request
    Request req = ContentRequestBuilder.deletePost(postId);

    //init response var
    final Response res;

    //get response from the api
    try {
      res = await APIService.send(req);
    } on Exception {
      //rethrow error up to ui caller
      rethrow;
    }

    //check status is ok
    bool status = jsonDecode(res.body)['status'] == 'OK';

    //cache our new feed data
    CacheService.free(postId);

    //return new feed separate from one stored in cache
    return status;
  }

  /// Toggles the current user's upvote on a post.
  ///
  /// PUT /api/content/post/:postId/upvote
  ///
  /// Expected 200: { post: PostItem } (with updated `upvotes` count)
  /// Expected 401: no session.
  /// Expected 404: { error: "INVALID_ID" }.
  /// Expected 500: { error: "INTERNAL_SERVER" }.
  static Future<Post> upvotePost(String postId, {bool noCache = false}) async {
    //build request
    Request req = ContentRequestBuilder.upvotePost(postId);

    //init response var
    final Response res;

    //get response from the api
    try {
      res = await APIService.send(req);
    } on Exception {
      //rethrow error up to ui caller
      rethrow;
    }

    //parse the response from the api
    Post fetchedPost = Post.fromJson(jsonDecode(res.body)['post']);

    //cache our new feed data
    CacheService.store(o: fetchedPost);

    //return new feed separate from one stored in cache
    return fetchedPost;
  }

  /// Retrieves replies to the post identified by [postId].
  ///
  /// GET /api/content/post/:postId/reply
  ///
  /// Expected 200: { replies: PostItem[] } (newest first, hidden excluded)
  /// Expected 401: no session.
  /// Expected 404: { error: "INVALID_ID" } (parent post missing).
  static Future<List<Post>> fetchReplies(
    String postId, {
    bool noCache = false,
  }) async {
    //build request
    Request req = ContentRequestBuilder.getReplies(postId);

    //retrieve feed cache if any
    List<Post>? replyCache =
        CacheService.fetch(req.url.toString()) as List<Post>?;

    //check cache to see if we have a pre-prepared post with replies
    if (replyCache != null && noCache == false) {
      return replyCache;
    }

    //init response var
    final Response res;

    //get response from the api
    try {
      res = await APIService.send(req);
    } on Exception {
      //rethrow error up to ui caller
      rethrow;
    }

    //parse the response from the api
    List<Post> replies = List.from(
      jsonDecode(res.body)['replies'].map((p) => Post.fromJson(p)),
    );

    //cache our new feed data
    CacheService.store(o: replies, key: req.url.toString());

    //return new feed separate from one stored in cache
    return List.from(replies);
  }

  /// Retrieves public profile data for the user identified by [userId].
  ///
  /// GET /api/user/:userId
  ///
  /// Expected 200: { user: userData }
  /// Expected 401: no session.
  /// Expected 404: { error: "INVALID_USER" }.
  static Future<User> fetchUser(String userId, {bool noCache = false}) async {
    //fetch any cached user
    User? cachedUser = CacheService.fetch(userId) as User?;

    //check if cached user found
    if (cachedUser != null && noCache == false) {
      return cachedUser;
    }

    //build request
    Request req = ContentRequestBuilder.getUserById(userId);

    //init response var
    final Response res;

    //get response from the api
    try {
      res = await APIService.send(req);
    } on Exception {
      //rethrow error up to ui caller
      rethrow;
    }

    //parse the response from the api
    User fetchedUser = User.fromJson(jsonDecode(res.body)['user']);

    //cache our new feed data
    CacheService.store(o: fetchedUser);

    //return new feed separate from one stored in cache
    return fetchedUser;
  }

  /// Retrieves the current user's own posts and replies.
  ///
  /// GET /api/content
  ///
  /// Expected 200: {
  ///   posts: PostItem[],     // current user's root posts
  ///   comments: PostItem[]   // current user's replies
  /// }
  /// Expected 401: no session.
  static Future<Map<String, List<Post>>> fetchUserContent({
    bool noCache = false,
  }) async {
    //build request
    Request req = UserRequestBuilder.getContent();

    //retrieve feed cache if any
    Map<String, List<Post>>? userCache =
        CacheService.fetch(req.url.toString()) as Map<String, List<Post>>?;

    //check feed cache to see if we have a pre-prepared feed
    if (userCache != null && noCache == false) {
      return userCache;
    }

    //init response var
    final Response res;

    //get response from the api
    try {
      res = await APIService.send(req);
    } on Exception {
      //rethrow error up to ui caller
      rethrow;
    }

    //parse the response from the api
    List<Post> newUserPosts = _parseFeed(res)['posts']!;
    List<Post> newUserReplies = _parseFeed(res)['replies']!;

    //cache our new feed data
    CacheService.store(
      o: {'posts': newUserPosts, 'replies': newUserReplies},
      key: req.url.toString(),
    );

    //init feed variable
    _userPosts = List.from(newUserPosts);
    _userReplies = List.from(newUserReplies);

    //return new feed separate from one stored in cache
    return {'posts': List.from(_userPosts), 'replies': List.from(_userReplies)};
  }

  static DateTime? get latest => _feed.first.updated ?? _feed.first.created;
}
