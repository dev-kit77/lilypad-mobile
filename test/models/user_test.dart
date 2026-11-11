import 'package:test/test.dart';
import 'package:lilypad/models/user.dart';

void main() {
  test('init anonymous user', () {
    User usr = User(username: "Anonymous");
    expect(usr.toString(), equals('{"username":"Anonymous"}'));
  });

  test('init other user', () {
    User usr = User(
      uuid: "this is a uuid",
      username: "oli",
      status: "my body is ready",
      bio: "this is oli",
    );
    expect(
      usr.toString(),
      equals(
        '{"username":"oli","status":"my body is ready","bio":"this is oli"}',
      ),
    );
  });

  test('init current user', () {
    User usr = CurrentUser(
      uuid: "this is a uuid",
      username: "kit",
      status: "my body is ready",
      bio: "this is kit",
      dark: false,
      anon: false,
    );
    expect(
      usr.toString(),
      equals(
        '{"username":"kit","status":"my body is ready","bio":"this is kit","settings":{"dark":false,"anon":false}}',
      ),
    );
  });

  test('init anonymous user from json', () {
    User usr = User.fromJson(<String, Object?>{"username": "Anonymous"});
    expect(usr.toString(), equals('{"username":"Anonymous"}'));
  });

  test('init other user from json', () {
    User usr = User.fromJson(<String, Object?>{
      "userId": "this is a uuid",
      "username": "aiden",
      "status": "i am eating a sandwiches",
      "bio": "xbox nerd",
    });
    expect(
      usr.toString(),
      equals(
        '{"username":"aiden","status":"i am eating a sandwiches","bio":"xbox nerd"}',
      ),
    );
  });

  test('init current user from json', () {
    User usr = CurrentUser.fromJson(<String, Object?>{
      "userId": "this is a uuid",
      "username": "ewan",
      "status": "i am NOT eating a sandwiches",
      "bio": "general crazed lunatic",
      "settings": '{ "dark": "false", "anon": "true" }',
    });
    expect(
      usr.toString(),
      equals(
        '{"username":"ewan","status":"i am NOT eating a sandwiches","bio":"general crazed lunatic","settings":{"dark":false,"anon":true}}',
      ),
    );
  });
}
