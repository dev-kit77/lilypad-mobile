// id: t.String(),
// content: t.String(),
// userID: t.Optional(t.String()),
// username: t.String(),
// time: t.Date(),
// updated: t.Optional(t.Date()),
// upvotes: t.Number(),
// replyingTo: t.Optional(t.String()),
// replyCount: t.Number(),
// distanceKm: t.Number(),
import 'dart:convert';

import 'user.dart';

class Post {
  final String uuid;
  String content;
  User user;
  DateTime created;
  DateTime? updated;
  int upvotes;
  List<Post> replies = <Post>[];
  String? replying;
  int noReplies;
  double? distance;

  Post({
    required this.uuid,
    required this.content,
    required this.user,
    required this.created,
    this.updated,
    this.upvotes = 0,
    this.replying,
    this.noReplies = 0,
    this.distance,
  });

  factory Post.fromJson(String json) {
    Map<String, Object?> postMap = jsonDecode(json);

    return Post(
      uuid: postMap['id'] as String,
      content: postMap['content'] as String,
      user: User(
        uuid: postMap['userID'] as String?,
        username: postMap['username'] as String,
      ),
      created: DateTime.parse(postMap['time'] as String),
      updated: DateTime.tryParse(postMap['updated'].toString()),
      upvotes: postMap['upvotes'] as int,
      replying: postMap['replyingTo'] as String?,
      noReplies: postMap['replyCount'] as int,
      distance: num.tryParse(postMap['distanceKm'].toString())?.toDouble(),
    );
  }

  Post refreshFromJson(String json) {
    Map<String, Object?> postMap = jsonDecode(json);

    content = postMap['content'] as String;
    user = User(
      uuid: postMap['userID'] as String?,
      username: postMap['username'] as String,
    );
    created = DateTime.parse(postMap['time'] as String);
    updated = DateTime.parse(postMap['updated'] as String);
    upvotes = postMap['upvotes'] as int;
    noReplies = postMap['replyCount'] as int;
    distance = num.tryParse(postMap['distanceKm'].toString())?.toDouble();

    return this;
  }

  factory Post.fromMap(Map<String, Object?> postMap) {
    return Post(
      uuid: postMap['id'] as String,
      content: postMap['content'] as String,
      user: User(
        uuid: postMap['userID'] as String?,
        username: postMap['username'] as String,
      ),
      created: DateTime.parse(postMap['time'] as String),
      updated: DateTime.tryParse(postMap['updated'].toString()),
      upvotes: postMap['upvotes'] as int,
      replying: postMap['replyingTo'] as String?,
      noReplies: postMap['replyCount'] as int,
      distance: num.tryParse(postMap['distanceKm'].toString())?.toDouble(),
    );
  }

  void linkReply(Post reply) {
    replies.add(reply);
  }

  //   bool operator <(Post other) {
  //     //TODO: Implement ranking score
  //     return distance < other.distance;
  //   }
  //
  //   bool operator >(Post other) {
  //     //TODO: Implement ranking score
  //     return distance > other.distance;
  //   }
  //
  //   bool operator <=(Post other) {
  //     //TODO: Implement ranking score
  //     return distance <= other.distance;
  //   }
  //
  //   bool operator >=(Post other) {
  //     //TODO: Implement ranking score
  //     return distance >= other.distance;
  //   }
}
