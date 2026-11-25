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

///apps representation of a post.
class Post {
  static const Object _unset = Object();

  final String uuid;
  final String content;
  final User user;
  final DateTime created;
  final DateTime? updated;
  final int upvotes;
  final bool upvoted;
  final List<Post> replies;
  final String? replying;
  final int noReplies;
  final double? distance;

  Post({
    required this.uuid,
    required this.content,
    required this.user,
    required this.created,
    this.updated,
    this.upvotes = 0,
    this.upvoted = false,
    List<Post>? replies,
    this.replying,
    this.noReplies = 0,
    this.distance,
  }) : replies = List<Post>.unmodifiable(
         List<Post>.from(replies ?? const <Post>[]),
       );

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
      upvoted: postMap['upvoted'] as bool? ?? false,
      replying: postMap['replyingTo'] as String?,
      noReplies: postMap['replyCount'] as int,
      distance: num.tryParse(postMap['distanceKm'].toString())?.toDouble(),
    );
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
      upvoted: postMap['upvoted'] as bool? ?? false,
      replying: postMap['replyingTo'] as String?,
      noReplies: postMap['replyCount'] as int,
      distance: num.tryParse(postMap['distanceKm'].toString())?.toDouble(),
    );
  }

  /// Returns a new post with the supplied fields replaced.
  Post copyWith({
    String? uuid,
    String? content,
    User? user,
    DateTime? created,
    Object? updated = _unset,
    int? upvotes,
    bool? upvoted,
    List<Post>? replies,
    Object? replying = _unset,
    int? noReplies,
    Object? distance = _unset,
  }) {
    return Post(
      uuid: uuid ?? this.uuid,
      content: content ?? this.content,
      user: user ?? this.user,
      created: created ?? this.created,
      updated: identical(updated, _unset) ? this.updated : updated as DateTime?,
      upvotes: upvotes ?? this.upvotes,
      upvoted: upvoted ?? this.upvoted,
      replies: replies ?? this.replies,
      replying: identical(replying, _unset)
          ? this.replying
          : replying as String?,
      noReplies: noReplies ?? this.noReplies,
      distance: identical(distance, _unset)
          ? this.distance
          : distance as double?,
    );
  }

  /// Returns a new post with [reply] appended to its replies.
  Post withReply(Post reply) => copyWith(replies: <Post>[...replies, reply]);

  /// Returns a new post with its fields refreshed from [json].
  ///
  /// Fields absent from the JSON keep their current values.
  Post refreshFromJson(String json) {
    Map<String, Object?> postMap = jsonDecode(json);

    return copyWith(
      content: postMap['content'] as String,
      user: User(
        uuid: postMap['userID'] as String?,
        username: postMap['username'] as String,
      ),
      created: DateTime.parse(postMap['time'] as String),
      updated: DateTime.tryParse(postMap['updated'].toString()),
      upvotes: postMap['upvotes'] as int,
      upvoted: postMap['upvoted'] as bool? ?? upvoted,
      noReplies: postMap['replyCount'] as int,
      distance: num.tryParse(postMap['distanceKm'].toString())?.toDouble(),
    );
  }
}
