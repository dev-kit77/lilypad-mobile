import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:lilypad/ui/theme/theme.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final theme = AppTheme.of(FakeBuildContext());

  test('override preserves theme properties when base font omits them', () {
    // Google Fonts styles specify a typeface but leave fontSize, colour, etc.
    // unset, so the theme values must be kept as fallbacks.
    final baseFont = TextStyle(fontFamily: 'Playfair Display');

    final style = theme.bodyMedium.override(font: baseFont);

    expect(style.fontFamily, 'Playfair Display');
    expect(style.fontSize, theme.bodyMedium.fontSize);
    expect(style.color, theme.bodyMedium.color);
    expect(style.fontWeight, theme.bodyMedium.fontWeight);
    expect(style.fontStyle, theme.bodyMedium.fontStyle);
    expect(style.letterSpacing, theme.bodyMedium.letterSpacing);
    expect(style.height, theme.bodyMedium.height);
  });

  test('explicit overrides take precedence over theme values', () {
    final style = theme.headlineLarge.override(
      font: const TextStyle(fontFamily: 'Asset'),
      fontSize: 42,
      color: theme.primary,
      fontWeight: FontWeight.w400,
      fontStyle: FontStyle.italic,
      letterSpacing: 1.5,
      lineHeight: 2,
    );

    expect(style.fontSize, 42);
    expect(style.color, theme.primary);
    expect(style.fontWeight, FontWeight.w400);
    expect(style.fontStyle, FontStyle.italic);
    expect(style.letterSpacing, 1.5);
    expect(style.height, 2);
  });
}

// AppTheme.of ignores its context, so any object satisfies the signature.
class FakeBuildContext implements BuildContext {
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}
