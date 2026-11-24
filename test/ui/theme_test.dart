import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'package:lilypad/ui/theme/theme.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final light = AppTheme.light();
  final dark = AppTheme.dark();

  test('override preserves theme properties when base font omits them', () {
    // Google Fonts styles specify a typeface but leave fontSize, colour, etc.
    // unset, so the theme values must be kept as fallbacks.
    final baseFont = TextStyle(fontFamily: 'Playfair Display');

    final style = light.bodyMedium.override(font: baseFont);

    expect(style.fontFamily, 'Playfair Display');
    expect(style.fontSize, light.bodyMedium.fontSize);
    expect(style.color, light.bodyMedium.color);
    expect(style.fontWeight, light.bodyMedium.fontWeight);
    expect(style.fontStyle, light.bodyMedium.fontStyle);
    expect(style.letterSpacing, light.bodyMedium.letterSpacing);
    expect(style.height, light.bodyMedium.height);
  });

  test('explicit overrides take precedence over theme values', () {
    final style = light.headline.override(
      font: const TextStyle(fontFamily: 'Asset'),
      fontSize: 42,
      color: light.primary,
      fontWeight: FontWeight.w400,
      fontStyle: FontStyle.italic,
      letterSpacing: 1.5,
      lineHeight: 2,
    );

    expect(style.fontSize, 42);
    expect(style.color, light.primary);
    expect(style.fontWeight, FontWeight.w400);
    expect(style.fontStyle, FontStyle.italic);
    expect(style.letterSpacing, 1.5);
    expect(style.height, 2);
  });

  test('dark variant swaps surfaces and text colours', () {
    expect(light.isDark, isFalse);
    expect(dark.isDark, isTrue);

    expect(dark.primaryBackground, const Color(0xFF1C2024));
    expect(dark.primaryText, isNot(light.primaryText));
    expect(dark.headline.color, dark.primaryText);
    expect(dark.labelLarge.color, dark.secondaryText);
  });

  test('user preference updates the active theme mode', () {
    AppTheme.applyUserPreference(true);
    expect(appThemeMode.value, ThemeMode.dark);

    AppTheme.applyUserPreference(false);
    expect(appThemeMode.value, ThemeMode.light);

    AppTheme.resetToSystem();
    expect(appThemeMode.value, ThemeMode.system);
  });

  testWidgets('of(context) resolves the active theme extension', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: light.themeData,
        darkTheme: dark.themeData,
        themeMode: ThemeMode.dark,
        home: Builder(
          builder: (context) => Text(
            'theme',
            style: TextStyle(color: AppTheme.of(context).primaryBackground),
          ),
        ),
      ),
    );

    expect(
      tester.widget<Text>(find.text('theme')).style?.color,
      dark.primaryBackground,
    );
  });
}
