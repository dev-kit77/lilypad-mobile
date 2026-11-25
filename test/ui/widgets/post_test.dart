import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' show runWithClient;
import 'package:lilypad/models/post.dart';
import 'package:lilypad/services/cache.dart';
import 'package:lilypad/services/user.dart';
import 'package:lilypad/ui/widgets/buttons.dart';
import 'package:lilypad/ui/widgets/post.dart';
import 'package:material_ui/material_ui.dart';

import '../../support/content_fixtures.dart';
import '../../support/http_stub.dart';
import '../../support/ui_test_helpers.dart';

Post buildPost() => Post.fromMap(
  postJson(
    id: 'post-1',
    content: 'hello lilypad',
    username: 'kit',
    upvotes: 1200,
    replyCount: 3,
  ),
);

void main() {
  setUp(() {
    CacheService.clear();
    UserService.clear();
  });

  testWidgets('displays the author, content and compact counts', (
    tester,
  ) async {
    await pumpThemed(tester, PostWidget(post: buildPost()));

    expect(find.text('kit'), findsWidgets);
    expect(find.text('hello lilypad'), findsOneWidget);
    expect(find.text('1.2K'), findsOneWidget);
    expect(find.text('3'), findsOneWidget);
    expect(find.textContaining('said...'), findsOneWidget);
  });

  testWidgets('marks edited posts and shows the supplied parent author', (
    tester,
  ) async {
    final Post parent = Post.fromMap(
      postJson(id: 'parent', username: 'ada', content: 'original'),
    );
    final Post reply = Post.fromMap(
      postJson(
        id: 'reply',
        username: 'kit',
        content: 'a reply',
        replyingTo: 'parent',
        updated: '2026-01-02T12:00:00.000Z',
      ),
    );

    await pumpThemed(
      tester,
      PostWidget(post: reply, replyingTo: parent),
    );

    expect(find.text('a reply'), findsOneWidget);
    expect(find.text(' replied to '), findsOneWidget);
    expect(find.text('ada'), findsOneWidget);
    expect(find.textContaining('Edited'), findsOneWidget);
  });

  testWidgets("hides the edit button for another user's post", (
    tester,
  ) async {
    await pumpThemed(tester, PostWidget(post: buildPost()));

    final Finder editButton = find.byWidgetPredicate(
      (Widget widget) => widget is AppButton && widget.text == null,
      skipOffstage: false,
    );
    expect(editButton, findsOneWidget);

    final Offstage offstage = find
        .ancestor(of: editButton, matching: find.byType(Offstage))
        .evaluate()
        .first
        .widget as Offstage;
    expect(offstage.offstage, isTrue);
  });

  testWidgets('upvoting updates the post and notifies onUpdate', (
    tester,
  ) async {
    final api = StubClient();
    api.queueJson(<String, Object?>{
      'post': postJson(
        id: 'post-1',
        content: 'hello lilypad',
        upvotes: 1201,
        upvoted: true,
        replyCount: 3,
      ),
    });

    Post? updated;
    await runWithClient(() async {
      await pumpThemed(
        tester,
        PostWidget(
          post: buildPost(),
          onUpdate: (Post p) => updated = p,
        ),
      );

      await tester.tap(find.text('1.2K'));
      await tester.pumpAndSettle();
    }, () => api);

    expect(
      api.requests.single.request.url.path,
      '/api/content/post/post-1/upvote',
    );
    expect(updated?.upvotes, 1201);
    expect(find.text('1.2K'), findsOneWidget);
  });
}
