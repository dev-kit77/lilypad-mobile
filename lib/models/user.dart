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
  final String? _uuid;
  final String _username;
  final String? _status;
  final String? _bio;

  User({this._uuid, required this._username, this._status, this._bio});

  factory User.fromJson(Map<String, Object?> json) {
    return User(
      uuid: json['userId'] as String?,
      username: json['username'] as String,
      status: json['status'] as String?,
      bio: json['bio'] as String?,
    );
  }

  Map<String, Object?> toJson() {
    return <String, Object?>{
      "username": _username,
      if (_status != null) "status": _status,
      if (_bio != null) "bio": _bio,
    };
  }

  @override
  String toString() {
    return jsonEncode(this);
  }

  String? get uuid => _uuid;
  String get username => _username;
  String? get status => _status;
  String? get bio => _bio;
}

class CurrentUser extends User {
  bool _dark;
  bool _anon;

  CurrentUser({
    required super.uuid,
    required super.username,
    super.status,
    super.bio,
    this._dark = false,
    this._anon = false,
  });

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
    Map<String, Object?> settings = <String, Object?>{
      "dark": _dark,
      "anon": _anon,
    };

    return <String, Object?>{
      "username": _username,
      if (_status != null) "status": _status,
      if (_bio != null) "bio": _bio,
      "settings": settings,
    };
  }

  @override
  String get uuid => _uuid!;
  bool get dark => _dark;
  bool get anon => _anon;
}
