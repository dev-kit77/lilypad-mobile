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

  ///getter for newestFeed. returns a new list containing all items from the feed sorted by updated if exists or creation
  static List<Post> get newestFeed {
    //no sorting needed if empty
    if (_feed.isEmpty) return <Post>[];

    //create sorted list from feed
    final List<Post> sorted = List.from(_feed);
    sorted.sort((Post a, Post b) {
      final DateTime aDate = a.updated ?? a.created;
      final DateTime bDate = b.updated ?? b.created;
      return bDate.compareTo(aDate);
    });

    return sorted;
  }

  //helper to update the post tree
  static void _upsertToRoot(Post p) {
    if (p.replying != null) {
      Post? parent = CacheService.fetch(p.replying!) as Post?;
      Post newParent;

      if (parent == null) {
        return;
      } else {
        //create list to append
        List<Post> appended = List.from(parent.replies);

        //remove old reply
        appended.removeWhere((o) => p.uuid == o.uuid);

        //append new reply
        appended.add(p);

        //create new parent
        newParent = parent.copyWith(replies: appended);

        //overwrite old post reply data
        CacheService.store(o: newParent);
      }

      //update parent ref up chain
      _upsertToRoot(newParent);
    } else {
      return;
    }
  }

  //helper to update the post tree
  static void _deleteToRoot(Post p) {
    //delete from parents
    if (p.replying != null) {
      Post? parent = CacheService.fetch(p.replying!) as Post?;
      Post newParent;

      if (parent == null) {
        return;
      } else {
        //create list to append
        List<Post> removal = List.from(parent.replies);

        //check if reply is being removed
        final bool hasChild = removal.any((o) => o.uuid == p.uuid);

        if (hasChild) {
          //remove old reply if there
          removal.removeWhere((o) => p.uuid == o.uuid);
        }

        //create new parent
        newParent = parent.copyWith(
          replies: removal,
          noReplies: hasChild && parent.noReplies > 0
              ? parent.noReplies - 1
              : parent.noReplies,
        );

        //overwrite old post reply data
        CacheService.store(o: newParent);
      }

      //update parent ref up chain
      _upsertToRoot(newParent);
    } else {
      return;
    }
  }

  //method to refresh the feed from cache can include a new post
  //include adds that post into the returned feed cache
  //ignore ignores the missing post id provided to it and removes it from the feed cache
  static bool refreshFromCache({Post? include, String? ignore}) {
    //init success
    bool success = true;

    //get current location
    final Map<String, double?> currLocation = GeolocationService.location;

    //check location ready
    if (currLocation.values.contains(null)) {
      LogService.err('Location Service not ready.', src: 'Content Service');
    } else {
      final feedUrl = ContentRequestBuilder.feedSpatial(
        currLocation['lat']!,
        currLocation['lon']!,
      ).url.toString();

      //retrieve feed cache if any
      final List<String>? feedCache =
          CacheService.fetch(feedUrl) as List<String>?;

      //check feed cache to see if we have a pre-prepared feed
      if (feedCache != null) {
        //init check val
        bool feedValid = true;

        //init post holder
        final List<Post> cacheFeed = include != null && include.replying == null
            ? <Post>[include]
            : <Post>[];

        //init list of uuid
        final List<String> postList =
            include != null && include.replying == null
            ? <String>[include.uuid]
            : <String>[];

        for (String id in feedCache) {
          //get post in feed from cache
          Post? cachedPost = CacheService.fetch(id) as Post?;

          //add post to feed if found
          if (cachedPost != null) {
            //add post
            cacheFeed.add(cachedPost);
            postList.add(id);
          } else if (id != ignore) {
            feedValid = false;
            break;
          }
        }

        if (feedValid) {
          //store list of post uuid
          CacheService.store(o: postList, key: feedUrl);

          //update feed var in case of updated posts in cache
          _feed = cacheFeed;
        } else {
          success = feedValid;
        }
      }
    }

    //build request
    String usrContentUrl = UserRequestBuilder.getContent().url.toString();

    //retrieve feed cache if any
    List<String>? userCache =
        CacheService.fetch(usrContentUrl) as List<String>?;

    //check feed cache to see if we have a pre-prepared feed
    if (userCache != null) {
      bool userValid = true;
      final List<Post> cachePosts = <Post>[];
      final List<Post> cacheReplies = <Post>[];

      //init list of uuid
      final List<String> postList = <String>[];

      for (String id in userCache) {
        //get post in feed from cache
        final Post? cachePost = CacheService.fetch(id) as Post?;

        //add post to feed if found
        if (cachePost != null) {
          //add to cache
          if (cachePost.replying == null) {
            cachePosts.add(cachePost);
          } else {
            cacheReplies.add(cachePost);
          }

          //add to updated post list
          postList.add(id);
        } else if (id != ignore) {
          userValid = false;
        }
      }
      if (userValid == true) {
        //add include to user posts
        if (include != null) {
          if (include.replying == null) {
            cachePosts.add(include);
          } else {
            cacheReplies.add(include);
          }

          //add to updated post list
          postList.add(include.uuid);
        }

        //store list of post uuid
        CacheService.store(o: postList, key: usrContentUrl);

        //update feed var in case of updated posts in cache
        _userPosts = cachePosts;
        _userReplies = cacheReplies;
      } else {
        success = userValid;
      }
    }

    //refresh success
    return success;
  }

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
    final Map<String, double?> currLocation = GeolocationService.location;

    //check location ready
    if (currLocation.values.contains(null)) {
      LogService.err('Location Service not ready.', src: 'Content Service');
      throw Exception('Location Not Available');
    }

    //build request with location
    final Request req = ContentRequestBuilder.feedSpatial(
      currLocation['lat']!,
      currLocation['lon']!,
    );

    //retrieve feed cache if any
    final List<String>? feedCache =
        CacheService.fetch(req.url.toString()) as List<String>?;

    //check feed cache to see if we have a pre-prepared feed
    if (feedCache != null && noCache == false) {
      final List<Post> cacheFeed = <Post>[];

      for (String id in feedCache) {
        //get post in feed from cache
        final Post? cachedPost = CacheService.fetch(id) as Post?;

        //add post to feed if found
        if (cachedPost != null) {
          cacheFeed.add(cachedPost);
        }
      }

      //update feed var in case of updated posts in cache
      _feed = cacheFeed;

      //return cached feed
      return List.from(_feed);
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
    final List<Post> newFeed = _parseFeed(res)['posts']!;

    //init list of uuid
    final List<String> postList = <String>[];

    //add all uuids to list
    for (Post p in newFeed) {
      postList.add(p.uuid);
    }

    //store list of post uuid
    CacheService.store(o: postList, key: req.url.toString());

    //init feed variable
    _feed = newFeed;

    //return new feed separate from one stored in cache
    return List.from(_feed);
  }

  static Map<String, List<Post>> _parseFeed(Response r) {
    //decode json and convert to lists of posts and replies
    List<Post> posts = List.from(
      jsonDecode(r.body)['posts'].map((p) => Post.fromMap(p)),
    );
    List<Post> replies = List.from(
      jsonDecode(r.body)['replies'].map((r) => Post.fromMap(r)),
    );

    //create a union indexing all posts for adding replies to all posts including sub-replys
    Map<String, Post> allByID = <String, Post>{
      for (Post post in posts) post.uuid: post,
      for (Post reply in replies) reply.uuid: reply,
    };

    //index each reply by its parent, ignoring orphaned replies
    Map<String, List<Post>> childrenByParent = <String, List<Post>>{};
    for (Post reply in replies) {
      String? parentID = reply.replying;
      if (parentID != null && allByID.containsKey(parentID)) {
        childrenByParent.putIfAbsent(parentID, () => <Post>[]).add(reply);
      }
    }

    //posts are immutable, so build linked copies bottom-up and memoize them
    Map<String, Post> linkedByID = <String, Post>{};

    Post link(String id, Set<String> visiting) {
      //guard if post is already linked
      Post? linked = linkedByID[id];
      if (linked != null) return linked;

      //get post from id map
      Post post = allByID[id]!;

      //guard against malformed reply chains that point back to an already added ancestor
      if (!visiting.add(id)) return post;

      //recursively link childrens replies
      List<Post> children = (childrenByParent[id] ?? const <Post>[])
          .map((Post child) => link(child.uuid, visiting))
          .toList();

      //remove id from
      visiting.remove(id);

      //linked to new copy with replies
      linked = post.copyWith(replies: children);

      //replace in list
      linkedByID[id] = linked;

      //return back up the chain
      return linked;
    }

    //link all posts to each other
    List<Post> linkedPosts = posts
        .map((Post p) => link(p.uuid, <String>{}))
        .toList();
    List<Post> linkedReplies = replies
        .map((Post r) => link(r.uuid, <String>{}))
        .toList();

    //cache the fully linked posts so cached post retain their reply trees
    linkedByID.forEach((key, val) => CacheService.store(o: val, key: key));

    //return posts list as stem of tree and replies so user replies can be separated as these may not have accompaning post
    //replies could contain orphaned replies but these should be discarded in main feed
    return {'posts': linkedPosts, 'replies': linkedReplies};
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
    Post fetchedPost = Post.fromMap(jsonDecode(res.body)['post']);

    //fetch previous copy for cached replies
    Post? oldPost = CacheService.fetch(fetchedPost.uuid) as Post?;

    //create new post with cached replies
    Post newPost = fetchedPost.copyWith(replies: oldPost?.replies ?? <Post>[]);

    //propagate updates back to root post
    _upsertToRoot(newPost);

    //cache our new post data
    CacheService.store(o: newPost);

    //update post in feed
    refreshFromCache();

    //return new feed separate from one stored in cache
    return newPost;
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
    Post fetchedPost = Post.fromMap(jsonDecode(res.body)['post']);

    //cache our new post data
    CacheService.store(o: fetchedPost);

    //update post in feed
    refreshFromCache(include: fetchedPost);

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
    Post fetchedPost = Post.fromMap(jsonDecode(res.body)['post']);

    //cache our new post data
    CacheService.store(o: fetchedPost);

    //fetch previous copy for cached replies
    Post? oldPost = CacheService.fetch(postId) as Post?;

    //if in cache
    if (oldPost != null) {
      //create list to append
      List<Post> appended = List.from(oldPost.replies);

      //remove old reply
      appended.removeWhere((o) => fetchedPost.uuid == o.uuid);

      final bool alreadyLinked = oldPost.replies.any(
        (r) => r.uuid == fetchedPost.uuid,
      );

      //append new reply
      appended.add(fetchedPost);

      //create new parent
      final Post newParent = oldPost.copyWith(
        replies: appended,
        noReplies: oldPost.noReplies + (alreadyLinked ? 0 : 1),
      );

      //overwrite old post reply data
      CacheService.store(o: newParent);

      //update post tree
      _upsertToRoot(newParent);
    }

    //update post in feed
    refreshFromCache(include: fetchedPost);

    //return new reply
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
    Post fetchedPost = Post.fromMap(jsonDecode(res.body)['post']);

    //fetch previous copy for cached replies
    Post? oldPost = CacheService.fetch(fetchedPost.uuid) as Post?;

    //create post with cached replies
    Post newPost = fetchedPost.copyWith(replies: oldPost?.replies ?? <Post>[]);

    //update post tree
    _upsertToRoot(newPost);

    //cache our new post data
    CacheService.store(o: newPost);

    //update post in feed

    refreshFromCache();

    //return new feed separate from one stored in cache
    return newPost;
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

    if (status) {
      //get deleted post
      Post? oldPost = CacheService.fetch(postId) as Post?;

      //check recieved
      if (oldPost != null) {
        _deleteToRoot(oldPost);
      }

      //cache our new feed data
      CacheService.free(postId);

      //update feed
      refreshFromCache(ignore: postId);
    }

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
    Post fetchedPost = Post.fromMap(jsonDecode(res.body)['post']);

    //fetch previous copy for cached replies
    Post? oldPost = CacheService.fetch(fetchedPost.uuid) as Post?;

    Post newPost = fetchedPost.copyWith(replies: oldPost?.replies ?? <Post>[]);

    //cache our new post data
    CacheService.store(o: newPost);

    _upsertToRoot(newPost);

    //update post in feed
    refreshFromCache();

    //return new feed separate from one stored in cache
    return newPost;
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
    final List<String>? replyCache =
        CacheService.fetch(req.url.toString()) as List<String>?;

    //check feed cache to see if we have a pre-prepared feed
    if (replyCache != null && noCache == false) {
      final List<Post> cacheFeed = <Post>[];

      for (String id in replyCache) {
        //get post in feed from cache
        final Post? cachedPost = CacheService.fetch(id) as Post?;

        //add post to feed if found
        if (cachedPost != null) {
          cacheFeed.add(cachedPost);
        }
      }

      //return cached feed
      return cacheFeed;
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
      jsonDecode(res.body)['replies'].map((p) => Post.fromMap(p)),
    );

    //init list of uuid
    final List<String> postList = <String>[];
    final List<Post> newReplies = <Post>[];

    //add all replies to cache and uuids to list
    for (Post r in replies) {
      //fetch previous copy for cached replies
      Post? oldPost = CacheService.fetch(r.uuid) as Post?;

      //create new post with cached replies
      Post newPost = r.copyWith(replies: oldPost?.replies ?? <Post>[]);

      //propagate updates back to root post
      _upsertToRoot(newPost);

      //cache our new post data
      CacheService.store(o: newPost);

      //append to new post
      newReplies.add(newPost);

      //add uuid to list
      postList.add(r.uuid);
    }

    //store list of post uuid
    CacheService.store(o: postList, key: req.url.toString());

    //return new feed separate from one stored in cache
    return newReplies;
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
    User fetchedUser = User.fromMap(jsonDecode(res.body)['user']);

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
    List<String>? userCache =
        CacheService.fetch(req.url.toString()) as List<String>?;

    //check feed cache to see if we have a pre-prepared feed
    if (userCache != null && noCache == false) {
      final List<Post> cachePosts = <Post>[];
      final List<Post> cacheReplies = <Post>[];

      for (String id in userCache) {
        //get post in feed from cache
        final Post? cachePost = CacheService.fetch(id) as Post?;

        //add post to feed if found
        if (cachePost != null) {
          if (cachePost.replying == null) {
            cachePosts.add(cachePost);
          } else {
            cacheReplies.add(cachePost);
          }
        }
      }

      //update feed var in case of updated posts in cache
      _userPosts = cachePosts;
      _userReplies = cacheReplies;

      //return cached feed
      return {
        'posts': List.from(_userPosts),
        'replies': List.from(_userReplies),
      };
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
    Map<String, List<Post>> feed = _parseFeed(res);

    //get lists of posts and replies
    List<Post> newUserPosts = feed['posts']!;
    List<Post> newUserReplies = feed['replies']!;

    //init list of uuid
    final List<String> postList = <String>[];

    //add all uuids to list
    for (List list in [newUserPosts, newUserReplies]) {
      for (Post p in list) {
        postList.add(p.uuid);
      }
    }

    //store list of posts in cache
    CacheService.store(o: postList, key: req.url.toString());

    //init feed variable
    _userPosts = newUserPosts;
    _userReplies = newUserReplies;

    //return new feed separate from one stored in cache
    return {'posts': List.from(_userPosts), 'replies': List.from(_userReplies)};
  }

  static DateTime? get latest {
    if (_feed.isNotEmpty) {
      final latestPost = newestFeed.first;
      return latestPost.updated ?? latestPost.created;
    } else {
      return null;
    }
  }

  static void clear() {
    _feed.clear();
    _userPosts.clear();
    _userReplies.clear();
  }
}
