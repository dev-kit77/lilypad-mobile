import 'package:flutter_test/flutter_test.dart';
import 'package:lilypad/models/post.dart';
import 'package:lilypad/ui/pages/new_reply.dart';
import 'package:wiggly_loaders/wiggly_loaders.dart';

import '../../support/content_fixtures.dart';
import '../../support/ui_test_helpers.dart';

void main() {
  testWidgets('empty content puts the reply button in an error state', (
    tester,
  ) async {
    final Post parent = Post.fromMap(
      postJson(id: 'post-1', content: 'parent'),
    );

    await pumpThemed(tester, NewReplyWidget(replyingTo: parent));

    await tester.tap(find.text('Post'));
    await tester.pump();

    final WigglyProgressButton button = tester.widget<WigglyProgressButton>(
      find.byType(WigglyProgressButton),
    );
    expect(button.state, WigglyButtonState.error);

    await tester.pump(const Duration(seconds: 2));
    expect(
      tester.widget<WigglyProgressButton>(find.byType(WigglyProgressButton)).state,
      WigglyButtonState.idle,
    );
  });
}
