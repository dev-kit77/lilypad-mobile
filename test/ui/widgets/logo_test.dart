import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:lilypad/ui/theme/theme.dart';
import 'package:lilypad/ui/widgets/logo.dart';

import '../../support/ui_test_helpers.dart';

void main() {
  testWidgets('renders the wordmark and an accent-coloured dot', (tester) async {
    await pumpThemed(tester, const LogoWidget());

    expect(find.text('lilypad'), findsOneWidget);
    expect(find.text('.'), findsOneWidget);

    final Text dot = tester.widget<Text>(find.text('.'));
    expect(dot.style?.color, AppTheme.light().primary);
  });
}
