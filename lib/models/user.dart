// Full JSON struct as defined in server models
// userId: t.String(),
// username: t.String(),
// status: t.Optional(t.String()),
// bio: t.Optional(t.String()),
// settings: t.Object({
//   dark: t.Boolean(),
//   anon: t.Boolean(),
// }),
import 'dart:convert';

class User {
  final String? uuid;
  String username;
  String? status;
  String? bio;

  User({this.uuid, required this.username, this.status, this.bio});

  factory User.fromJson(Map<String, Object?> json) {
    return User(
      uuid: json['userId'] as String?,
      username: json['username'] as String,
      status: json['status'] as String?,
      bio: json['bio'] as String?
    );
  }

  @override
  Map<String, Object?> toJson() {
    return <String, Object?> {
            "username": "$username",
            if (status != null) "status" : "$status",
            if (bio != null) "bio": "$bio"
          };
  }

  @override
  String toString() {
    return jsonEncode(this);
  }
}

class CurrentUser extends User {
  bool dark;
  bool anon;

  CurrentUser({required uuid, required username, status, bio, this.dark = false, this.anon = false}) : super(uuid: uuid, username: username, status: status, bio: bio);

  factory CurrentUser.fromJson(Map<String, Object?> json) {
    Map<String, Object?> settings = jsonDecode('${json['settings']}');

    return CurrentUser(
      uuid: json['userId'] as String,
      username: json['username'] as String,
      status: json['status'] as String?,
      bio: json['bio'] as String?,
      dark: (settings['dark'].toString().toLowerCase() == 'true'),
      anon: (settings['anon'].toString().toLowerCase() == 'true'),
    );
  }

  @override
  Map<String, Object?> toJson() {
    Map<String, Object?> settings = <String, Object?> {"dark": dark, "anon": anon};

    return <String, Object?> {
            "username": "$username",
            if (status != null) "status" : "$status",
            if (bio != null) "bio": "$bio",
            "settings": settings
          };
  }
}
