import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:lilypad/models/user.dart';
import 'package:lilypad/ui/theme/theme.dart';
import 'package:lilypad/ui/widgets/user.dart';

import '../../support/ui_test_helpers.dart';

void main() {
  testWidgets('shows default status and bio when the user omits them', (
    tester,
  ) async {
    await pumpThemed(
      tester,
      UserWidget(user: User(uuid: 'user-1', username: 'kit')),
    );

    expect(find.text('kit'), findsOneWidget);
    expect(find.text('I am on lilypad'), findsOneWidget);
    expect(find.text('lilypad User'), findsOneWidget);

    final Card card = tester.widget<Card>(find.byType(Card));
    expect(card.color, AppTheme.light().secondaryBackground);
  });

  testWidgets('shows the supplied status and bio', (tester) async {
    await pumpThemed(
      tester,
      UserWidget(
        user: User(
          uuid: 'user-2',
          username: 'ada',
          status: 'building things',
          bio: 'hello there',
        ),
      ),
    );

    expect(find.text('ada'), findsOneWidget);
    expect(find.text('building things'), findsOneWidget);
    expect(find.text('hello there'), findsOneWidget);
    expect(find.text('I am on lilypad'), findsNothing);
    expect(find.text('lilypad User'), findsNothing);
  });
}
