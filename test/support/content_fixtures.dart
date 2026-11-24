import 'package:lilypad/models/post.dart';
import 'package:lilypad/models/user.dart';

///simulates a user as the server returns it.
Map<String, Object?> postJson({
  required String id,
  String content = 'hello world',
  String? userID = 'user-1',
  String username = 'kit',
  String time = '2026-01-01T12:00:00.000Z',
  String? updated,
  int upvotes = 0,
  bool upvoted = false,
  String? replyingTo,
  int replyCount = 0,
  double distanceKm = 0.0,
}) => <String, Object?>{
  'id': id,
  'content': content,
  'userID': ?userID,
  'username': username,
  'time': time,
  'updated': ?updated,
  'upvotes': upvotes,
  'upvoted': upvoted,
  'replyingTo': ?replyingTo,
  'replyCount': replyCount,
  'distanceKm': distanceKm,
};

///simulates a user as the server returns it.
Map<String, Object?> userJson({
  required String id,
  String username = 'kit',
  String? status,
  String? bio,
}) => <String, Object?>{
  'userId': id,
  'username': username,
  'status': ?status,
  'bio': ?bio,
};

///test post stored in the cache before a test runs.
Post cachedPost({String uuid = 'post-1', String content = 'cached content'}) =>
    Post(
      uuid: uuid,
      content: content,
      user: User(uuid: 'user-1', username: 'kit'),
      created: DateTime.utc(2026, 1, 1),
    );
