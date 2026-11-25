import 'package:flutter_test/flutter_test.dart';
import 'package:lilypad/ui/pages/feed.dart' show FeedWidget;
import 'package:lilypad/ui/pages/profile.dart' show ProfileWidget;
import 'package:lilypad/ui/pages/settings.dart' show SettingsWidget;
import 'package:lilypad/ui/theme/theme.dart';
import 'package:lilypad/ui/widgets/navbar.dart';
import 'package:material_ui/material_ui.dart';

import '../../support/ui_test_helpers.dart';

Widget navbarWith(int selectedIndex) => Stack(
  children: <Widget>[NavBarWidget(selectedIndex: selectedIndex)],
);

void main() {
  testWidgets('shows all tabs and highlights the selected one', (
    tester,
  ) async {
    await pumpThemed(tester, navbarWith(1));

    expect(find.text('Profile'), findsOneWidget);
    expect(find.text('Posts'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);

    final theme = AppTheme.light();
    expect(
      tester.widget<Text>(find.text('Posts')).style?.color,
      theme.primary,
    );
    expect(
      tester.widget<Text>(find.text('Profile')).style?.color,
      theme.secondaryText,
    );
    expect(
      tester.widget<Text>(find.text('Settings')).style?.color,
      theme.secondaryText,
    );
  });

  testWidgets('tapping the active tab does not navigate', (tester) async {
    final recorder = await pumpThemed(
      tester,
      navbarWith(1),
      recordRoutes: true,
    );

    await tester.tap(find.text('Posts'));

    expect(recorder.pushed, isEmpty);
    expect(recorder.replaced, isEmpty);
  });

  for (final MapEntry<int, String> tab in <int, String>{
    0: ProfileWidget.routePath,
    1: FeedWidget.routePath,
    2: SettingsWidget.routePath,
  }.entries) {
    testWidgets('tapping tab ${tab.key} replaces the current route', (
      tester,
    ) async {
      final selected = tab.key == 1 ? 2 : 1;
      final recorder = await pumpThemed(
        tester,
        navbarWith(selected),
        recordRoutes: true,
      );

      await tester.tap(
        find.text(<String>['Profile', 'Posts', 'Settings'][tab.key]),
      );

      expect(recorder.replaced, hasLength(1));
      expect(recorder.replaced.single.settings.name, tab.value);
    });
  }
}
