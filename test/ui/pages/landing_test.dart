import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' show runWithClient;
import 'package:lilypad/ui/pages/landing.dart';
import 'package:material_ui/material_ui.dart';
import 'package:wiggly_loaders/wiggly_loaders.dart';

import '../../support/http_stub.dart';
import '../../support/ui_test_helpers.dart';

void main() {
  testWidgets('sign in validates email and password before logging in', (
    tester,
  ) async {
    final api = StubClient();
    api.queueJson(<String, Object?>{'token': null});

    await runWithClient(() async {
      await pumpThemed(tester, const LandingWidget());

      await tester.tap(
        find.descendant(
          of: find.byType(WigglyProgressButton).first,
          matching: find.text('Sign In'),
        ),
      );
      await tester.pump();

      expect(find.text('Email Required.'), findsWidgets);
      expect(find.text('Password Required.'), findsWidgets);

      // Let the error state's reset timer finish before the test ends.
      await tester.pump(const Duration(seconds: 2));
    }, () => api);
  });

  testWidgets('sign up validates username, email and password', (
    tester,
  ) async {
    final api = StubClient();
    api.queueJson(<String, Object?>{'token': null});

    await runWithClient(() async {
      await pumpThemed(tester, const LandingWidget());

      await tester.tap(find.widgetWithText(Tab, 'Sign Up'));
      // The tab view needs a few frames to build the sign-up form.
      for (int i = 0; i < 5; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      await tester.tap(
        find.descendant(
          of: find.byType(WigglyProgressButton),
          matching: find.text('Sign Up'),
        ),
      );
      await tester.pump();

      expect(find.text('Username Required.'), findsWidgets);
      expect(find.text('Email Required.'), findsWidgets);
      expect(find.text('Password Required.'), findsWidgets);

      await tester.pump(const Duration(seconds: 2));
    }, () => api);
  });
}
