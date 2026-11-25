import 'package:flutter_test/flutter_test.dart';
import 'package:lilypad/ui/pages/new_post.dart';
import 'package:wiggly_loaders/wiggly_loaders.dart';

import '../../support/ui_test_helpers.dart';

void main() {
  testWidgets('empty content puts the post button in an error state', (
    tester,
  ) async {
    await pumpThemed(tester, const NewPostWidget());

    expect(find.text('Post'), findsOneWidget);

    await tester.tap(find.text('Post'));
    await tester.pump();

    final WigglyProgressButton button = tester.widget<WigglyProgressButton>(
      find.byType(WigglyProgressButton),
    );
    expect(button.state, WigglyButtonState.error);

    // The button resets to idle after a two-second hold.
    await tester.pump(const Duration(seconds: 2));
    expect(
      tester.widget<WigglyProgressButton>(find.byType(WigglyProgressButton)).state,
      WigglyButtonState.idle,
    );
  });
}
