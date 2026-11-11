import 'dart:convert';

import 'package:http/http.dart';
import 'package:lilypad/builders/content.dart';
import 'package:test/test.dart';

void main() {
  test('build create post post request', () {
    Request r = ContentRequestBuilder.createPost(
      "hello world",
      55.9533,
      -3.1883,
    );
    expect(r.method, equals('POST'));
    expect(r.url.toString(), equals('http://localhost:3000/api/content/post'));
    expect(
      r.headers,
      equals(<String, String>{"content-type": "application/json"}),
    );
    expect(
      jsonDecode(r.body),
      equals(<String, Object>{
        "content": "hello world",
        "locality": <String, double>{"lat": 55.9533, "lon": -3.1883},
      }),
    );
    expect(r.encoding, equals(utf8));
  });

  test('build get post get request', () {
    Request r = ContentRequestBuilder.getPost("clxh0mfq200003b6rmd6lz3hr");
    expect(r.method, equals('GET'));
    expect(
      r.url.toString(),
      equals(
        'http://localhost:3000/api/content/post/clxh0mfq200003b6rmd6lz3hr',
      ),
    );
    expect(r.headers, isEmpty);
    expect(r.body, isEmpty);
    expect(r.encoding, equals(utf8));
  });

  test('build update post put request', () {
    Request r = ContentRequestBuilder.updatePost(
      "clxh0mfq200003b6rmd6lz3hr",
      "hello world, edited",
    );
    expect(r.method, equals('PUT'));
    expect(
      r.url.toString(),
      equals(
        'http://localhost:3000/api/content/post/clxh0mfq200003b6rmd6lz3hr',
      ),
    );
    expect(
      r.headers,
      equals(<String, String>{"content-type": "application/json"}),
    );
    expect(
      jsonDecode(r.body),
      equals(<String, String>{"content": "hello world, edited"}),
    );
    expect(r.encoding, equals(utf8));
  });

  test('build delete post delete request', () {
    Request r = ContentRequestBuilder.deletePost("clxh0mfq200003b6rmd6lz3hr");
    expect(r.method, equals('DELETE'));
    expect(
      r.url.toString(),
      equals(
        'http://localhost:3000/api/content/post/clxh0mfq200003b6rmd6lz3hr',
      ),
    );
    expect(r.headers, isEmpty);
    expect(r.body, isEmpty);
    expect(r.encoding, equals(utf8));
  });

  test('build upvote post put request', () {
    Request r = ContentRequestBuilder.upvotePost("clxh0mfq200003b6rmd6lz3hr");
    expect(r.method, equals('PUT'));
    expect(
      r.url.toString(),
      equals(
        'http://localhost:3000/api/content/post/clxh0mfq200003b6rmd6lz3hr/upvote',
      ),
    );
    expect(r.headers, isEmpty);
    expect(r.body, isEmpty);
    expect(r.encoding, equals(utf8));
  });

  test('build create reply post request', () {
    Request r = ContentRequestBuilder.createReply(
      "clxh0mfq200003b6rmd6lz3hr",
      "hello back",
    );
    expect(r.method, equals('POST'));
    expect(
      r.url.toString(),
      equals(
        'http://localhost:3000/api/content/post/clxh0mfq200003b6rmd6lz3hr/reply',
      ),
    );
    expect(
      r.headers,
      equals(<String, String>{"content-type": "application/json"}),
    );
    expect(
      jsonDecode(r.body),
      equals(<String, String>{"content": "hello back"}),
    );
    expect(r.encoding, equals(utf8));
  });

  test('build get replies get request', () {
    Request r = ContentRequestBuilder.getReplies("clxh0mfq200003b6rmd6lz3hr");
    expect(r.method, equals('GET'));
    expect(
      r.url.toString(),
      equals(
        'http://localhost:3000/api/content/post/clxh0mfq200003b6rmd6lz3hr/reply',
      ),
    );
    expect(r.headers, isEmpty);
    expect(r.body, isEmpty);
    expect(r.encoding, equals(utf8));
  });

  test('build feed spatial get request', () {
    Request r = ContentRequestBuilder.feedSpatial(51.5074, -0.1278);
    expect(r.method, equals('GET'));
    expect(
      r.url.toString(),
      equals('http://localhost:3000/api/feed-spatial?lat=51.5074&lon=-0.1278'),
    );
    expect(r.headers, isEmpty);
    expect(r.body, isEmpty);
    expect(r.encoding, equals(utf8));
  });

  test('build get user by id get request', () {
    Request r = ContentRequestBuilder.getUserById("clxh0n3x400013b7hth2xq9jk");
    expect(r.method, equals('GET'));
    expect(
      r.url.toString(),
      equals('http://localhost:3000/api/user/clxh0n3x400013b7hth2xq9jk'),
    );
    expect(r.headers, isEmpty);
    expect(r.body, isEmpty);
    expect(r.encoding, equals(utf8));
  });
}
