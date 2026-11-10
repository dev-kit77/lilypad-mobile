import 'package:test/test.dart';
import 'package:lilypad/models/post.dart';
import 'package:lilypad/models/user.dart';

void main() {
  test('init post', () {
    Post post = Post(
      uuid: "this is a uuid",
      content: "hello world",
      user: User(username: "Anonymous"),
      created: DateTime.parse("2026-01-01T12:00:00.000Z"),
    );
    expect(post.uuid, equals("this is a uuid"));
    expect(post.content, equals("hello world"));
    expect(post.user.toString(), equals('{"username":"Anonymous"}'));
    expect(post.created, equals(DateTime.parse("2026-01-01T12:00:00.000Z")));
    expect(post.updated, isNull);
    expect(post.upvotes, equals(0));
    expect(post.replies, isEmpty);
    expect(post.replying, isNull);
    expect(post.noReplies, equals(0));
    expect(post.distance, equals(0));
  });

  test('init post with details', () {
    Post post = Post(
      uuid: "this is a uuid",
      content: "my body is ready",
      user: User(uuid: "this is a user uuid", username: "oli"),
      created: DateTime.parse("2026-01-01T12:00:00.000Z"),
      updated: DateTime.parse("2026-01-02T12:00:00.000Z"),
      upvotes: 5,
      replying: "this is another uuid",
      noReplies: 2,
      distance: 1.5,
    );
    expect(post.uuid, equals("this is a uuid"));
    expect(post.content, equals("my body is ready"));
    expect(post.user.username, equals("oli"));
    expect(post.created, equals(DateTime.parse("2026-01-01T12:00:00.000Z")));
    expect(post.updated, equals(DateTime.parse("2026-01-02T12:00:00.000Z")));
    expect(post.upvotes, equals(5));
    expect(post.replying, equals("this is another uuid"));
    expect(post.noReplies, equals(2));
    expect(post.distance, equals(1.5));
  });

  test('init post from json + detail', () {
    Post post = Post.fromJson(<String, Object?>{
      "id": "this is a uuid",
      "content": "i am eating a sandwiches",
      "userID": "this is a user uuid",
      "username": "aiden",
      "time": "2026-01-01T12:00:00.000Z",
      "updated": "2026-01-02T12:00:00.000Z",
      "upvotes": 3,
      "replyingTo": "this is another uuid",
      "replyCount": 2,
      "distanceKm": 1.5,
    });
    expect(post.uuid, equals("this is a uuid"));
    expect(post.content, equals("i am eating a sandwiches"));
    expect(post.user.uuid, equals("this is a user uuid"));
    expect(post.user.username, equals("aiden"));
    expect(post.created, equals(DateTime.parse("2026-01-01T12:00:00.000Z")));
    expect(post.updated, equals(DateTime.parse("2026-01-02T12:00:00.000Z")));
    expect(post.upvotes, equals(3));
    expect(post.replying, equals("this is another uuid"));
    expect(post.noReplies, equals(2));
    expect(post.distance, equals(1.5));
  });

  test('init post from json', () {
    Post post = Post.fromJson(<String, Object?>{
      "id": "this is a uuid",
      "content": "hello world",
      "username": "Anonymous",
      "time": "2026-01-01T12:00:00.000Z",
      "upvotes": 0,
      "replyCount": 0,
      "distanceKm": 0.0,
    });
    expect(post.uuid, equals("this is a uuid"));
    expect(post.content, equals("hello world"));
    expect(post.user.toString(), equals('{"username":"Anonymous"}'));
    expect(post.created, equals(DateTime.parse("2026-01-01T12:00:00.000Z")));
    expect(post.updated, isNull);
    expect(post.upvotes, equals(0));
    expect(post.replies, isEmpty);
    expect(post.replying, isNull);
    expect(post.noReplies, equals(0));
    expect(post.distance, equals(0));
  });

  test('refresh post from json', () {
    Post post = Post(
      uuid: "this is a uuid",
      content: "hello world",
      user: User(username: "Anonymous"),
      created: DateTime.parse("2026-01-01T12:00:00.000Z"),
    );
    post.refreshFromJson(<String, Object?>{
      "id": "this is a uuid",
      "content": "i am NOT eating a sandwiches",
      "userID": "this is a user uuid",
      "username": "ewan",
      "time": "2026-01-03T12:00:00.000Z",
      "updated": "2026-01-04T12:00:00.000Z",
      "upvotes": 7,
      "replyCount": 4,
      "distanceKm": 2.5,
    });
    expect(post.content, equals("i am NOT eating a sandwiches"));
    expect(post.user.uuid, equals("this is a user uuid"));
    expect(post.user.username, equals("ewan"));
    expect(post.created, equals(DateTime.parse("2026-01-03T12:00:00.000Z")));
    expect(post.updated, equals(DateTime.parse("2026-01-04T12:00:00.000Z")));
    expect(post.upvotes, equals(7));
    expect(post.noReplies, equals(4));
    expect(post.distance, equals(2.5));
  });

  test('add reply to post', () {
    Post post = Post(
      uuid: "this is a uuid",
      content: "hello world",
      user: User(username: "Anonymous"),
      created: DateTime.parse("2026-01-01T12:00:00.000Z"),
    );
    Post reply = Post(
      uuid: "this is a reply uuid",
      content: "hello back",
      user: User(username: "oli"),
      created: DateTime.parse("2026-01-01T12:01:00.000Z"),
      replying: "this is a uuid",
    );
    post.linkReply(reply);
    expect(post.replies, hasLength(1));
    expect(post.replies.first.uuid, equals("this is a reply uuid"));
    expect(post.replies.first.replying, equals("this is a uuid"));
  });

  test('compare posts by distance', () {
    Post near = Post(
      uuid: "this is a uuid",
      content: "hello world",
      user: User(username: "Anonymous"),
      created: DateTime.parse("2026-01-01T12:00:00.000Z"),
      distance: 1,
    );
    Post far = Post(
      uuid: "this is another uuid",
      content: "hello world",
      user: User(username: "Anonymous"),
      created: DateTime.parse("2026-01-01T12:00:00.000Z"),
      distance: 2,
    );
    Post same = Post(
      uuid: "this is a third uuid",
      content: "hello world",
      user: User(username: "Anonymous"),
      created: DateTime.parse("2026-01-01T12:00:00.000Z"),
      distance: 1,
    );
    expect(near < far, isTrue);
    expect(near <= far, isTrue);
    expect(near <= same, isTrue);
    expect(far > near, isTrue);
    expect(far >= near, isTrue);
    expect(near >= same, isTrue);
    expect(far < near, isFalse);
    expect(near > far, isFalse);
  });
}
