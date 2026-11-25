import 'package:flutter_test/flutter_test.dart';
import 'package:lilypad/ui/widgets/buttons.dart';
import 'package:material_ui/material_ui.dart';

import '../../support/ui_test_helpers.dart';

void main() {
  testWidgets('renders text and calls onPressed when tapped', (tester) async {
    int taps = 0;
    await pumpThemed(
      tester,
      AppButton(text: 'Continue', onPressed: () => taps++),
    );

    expect(find.text('Continue'), findsOneWidget);

    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();

    expect(taps, 1);
  });

  testWidgets('null onPressed disables the button', (tester) async {
    await pumpThemed(tester, const AppButton(text: 'Disabled'));

    final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
    expect(button.onPressed, isNull);
  });

  testWidgets('places the icon before or after the text as configured', (
    tester,
  ) async {
    await pumpThemed(
      tester,
      const AppButton(
        text: 'Upvote',
        icon: Icon(Icons.arrow_upward),
        options: AppButtonOptions(iconAlignment: IconAlignment.start),
      ),
    );

    Row row = tester.widget<Row>(
      find.descendant(
        of: find.byType(ElevatedButton),
        matching: find.byType(Row),
      ),
    );
    expect(row.children.first, isA<Padding>());
    expect((row.children.first as Padding).child, isA<Icon>());
    expect(row.children.last, isA<Text>());

    await pumpThemed(
      tester,
      const AppButton(
        text: 'Upvote',
        icon: Icon(Icons.arrow_upward),
        options: AppButtonOptions(iconAlignment: IconAlignment.end),
      ),
    );

    row = tester.widget<Row>(
      find.descendant(
        of: find.byType(ElevatedButton),
        matching: find.byType(Row),
      ),
    );
    expect(row.children.first, isA<Text>());
    expect((row.children.last as Padding).child, isA<Icon>());
  });

  testWidgets('omits empty text and applies button options', (tester) async {
    await pumpThemed(
      tester,
      const AppButton(
        text: '',
        options: AppButtonOptions(
          width: 200,
          height: 48,
          color: Color(0xFF123456),
          elevation: 3,
          padding: EdgeInsets.all(7),
        ),
      ),
    );

    expect(find.text(''), findsNothing);

    final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
    expect(
      button.style?.backgroundColor?.resolve(<WidgetState>{}),
      const Color(0xFF123456),
    );
    expect(button.style?.elevation?.resolve(<WidgetState>{}), 3);
    expect(button.style?.padding?.resolve(<WidgetState>{}), const EdgeInsets.all(7));

    final SizedBox sizedBox = tester.widget<SizedBox>(
      find.ancestor(
        of: find.byType(ElevatedButton),
        matching: find.byType(SizedBox),
      ),
    );
    expect(sizedBox.width, 200);
    expect(sizedBox.height, 48);
  });
}
