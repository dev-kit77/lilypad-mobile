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
  double distance;

  Post({
    required this.uuid,
    required this.content,
    required this.user,
    required this.created,
    this.updated,
    this.upvotes = 0,
    this.replying,
    this.noReplies = 0,
    this.distance = 0,
  });

  factory Post.fromJson(Map<String, Object?> json) {
    return Post(
      uuid: json['id'] as String,
      content: json['content'] as String,
      user: User(
        uuid: json['userID'] as String?,
        username: json['username'] as String,
      ),
      created: DateTime.parse(json['time'] as String),
      updated: DateTime.tryParse(json['updated'].toString()),
      upvotes: json['upvotes'] as int,
      replying: json['replyingTo'] as String?,
      noReplies: json['replyCount'] as int,
      distance: json['distanceKm'] as double,
    );
  }

  Post refreshFromJson(Map<String, Object?> json) {
    content = json['content'] as String;
    user = User(
      uuid: json['userID'] as String?,
      username: json['username'] as String,
    );
    created = DateTime.parse(json['time'] as String);
    updated = DateTime.parse(json['updated'] as String);
    upvotes = json['upvotes'] as int;
    noReplies = json['replyCount'] as int;
    distance = json['distanceKm'] as double;

    return this;
  }

  void linkReply(Post reply) {
    replies.add(reply);
  }

  bool operator <(Post other) {
    //TODO: Implement ranking score
    return distance < other.distance;
  }

  bool operator >(Post other) {
    //TODO: Implement ranking score
    return distance > other.distance;
  }

  bool operator <=(Post other) {
    //TODO: Implement ranking score
    return distance <= other.distance;
  }

  bool operator >=(Post other) {
    //TODO: Implement ranking score
    return distance >= other.distance;
  }
}
