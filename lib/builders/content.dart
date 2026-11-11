import 'dart:convert';

import 'package:http/http.dart';
import 'package:lilypad/services/api.dart';

class ContentRequestBuilder {
  /// POST /api/content/post
  ///
  /// Body:  { content: string (1-255);
  ///             locality: { lat: number (-90..90); lon: number (-180..180) } }
  /// Auth:     session
  static Request createPost(String content, double lat, double lon) {
    //init request
    Request r = Request('POST', APIService.getUri(path: 'content/post'));

    //init header
    r.headers.clear();
    r.headers.addAll(<String, String>{"content-type": "application/json"});

    //set encoding
    r.encoding = utf8;

    //encode body
    r.body = jsonEncode(<String, Object>{
      "content": content,
      "locality": <String, double>{"lat": lat, "lon": lon},
    });

    return r;
  }

  /// GET /api/content/post/:postId
  ///
  /// Body:  path param `postId` (CUID)
  /// Auth:     session
  static Request getPost(String postId) {
    //init request
    Request r = Request('GET', APIService.getUri(path: 'content/post/$postId'));

    //init header
    r.headers.clear();

    //set encoding
    r.encoding = utf8;

    return r;
  }

  /// PUT /api/content/post/:postId
  ///
  /// Body:  path `postId`; body { content: string (min 1) }
  /// Auth:     session (must be the post author)
  static Request updatePost(String postId, String content) {
    //init request
    Request r = Request('PUT', APIService.getUri(path: 'content/post/$postId'));

    //init header
    r.headers.clear();
    r.headers.addAll(<String, String>{"content-type": "application/json"});

    //set encoding
    r.encoding = utf8;

    //encode body
    r.body = jsonEncode(<String, String>{"content": content});

    return r;
  }

  /// DELETE /api/content/post/:postId
  ///
  /// Body:  path param `postId`
  /// Auth:     session (must be the post author)
  static Request deletePost(String postId) {
    //init request
    Request r = Request(
      'DELETE',
      APIService.getUri(path: 'content/post/$postId'),
    );

    //init header
    r.headers.clear();

    //set encoding
    r.encoding = utf8;

    return r;
  }

  /// PUT /api/content/post/:postId/upvote
  ///
  /// Body:  path param `postId` (no body)
  /// Auth:     session
  static Request upvotePost(String postId) {
    //init request
    Request r = Request(
      'PUT',
      APIService.getUri(path: 'content/post/$postId/upvote'),
    );

    //init header
    r.headers.clear();

    //set encoding
    r.encoding = utf8;

    return r;
  }

  /// POST /api/content/post/:postId/reply
  ///
  /// Body:  path `postId`; body { content: string (min 1) }
  /// Auth:     session
  static Request createReply(String postId, String content) {
    //init request
    Request r = Request(
      'POST',
      APIService.getUri(path: 'content/post/$postId/reply'),
    );

    //init header
    r.headers.clear();
    r.headers.addAll(<String, String>{"content-type": "application/json"});

    //set encoding
    r.encoding = utf8;

    //encode body
    r.body = jsonEncode(<String, String>{"content": content});

    return r;
  }

  /// GET /api/content/post/:postId/reply
  ///
  /// Body:  path param `postId`
  /// Auth:     session
  static Request getReplies(String postId) {
    //init request
    Request r = Request(
      'GET',
      APIService.getUri(path: 'content/post/$postId/reply'),
    );

    //init header
    r.headers.clear();

    //set encoding
    r.encoding = utf8;

    return r;
  }

  /// GET /api/feed-spatial?lat=&lon=
  ///
  /// Body:  query { lat: number (-90..90); lon: number (-180..180) }
  /// Auth:     session
  static Request feedSpatial(double lat, double lon) {
    //init request
    Request r = Request(
      'GET',
      APIService.getUri(path: 'feed-spatial').replace(
        queryParameters: <String, String>{
          "lat": lat.toString(),
          "lon": lon.toString(),
        },
      ),
    );

    //init header
    r.headers.clear();

    //set encoding
    r.encoding = utf8;

    return r;
  }

  /// GET /api/user/:userId
  ///
  /// Body:  path param `userId`
  /// Auth:     session
  static Request getUserById(String userId) {
    //init request
    Request r = Request('GET', APIService.getUri(path: 'user/$userId'));

    //init header
    r.headers.clear();

    //set encoding
    r.encoding = utf8;

    return r;
  }
}
