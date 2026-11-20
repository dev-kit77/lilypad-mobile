import 'package:material_ui/material_ui.dart';

/// Holds the colours and text styles shared by the Lilypad UI.
class AppTheme {
  AppTheme._();

  static final AppTheme _instance = AppTheme._();

  /// Returns the shared theme for [context].
  static AppTheme of(BuildContext context) => _instance;

  // Colours.
  final Color primaryBackground = const Color(0xFFF7F8F7);
  final Color secondaryBackground = Colors.white;
  final Color primary = const Color(0xFF82B349);
  final Color alternate = const Color(0xFFE0E3E7);
  final Color primaryText = const Color(0xFF14181B);
  final Color secondaryText = const Color(0xFF57636C);
  final Color error = Colors.redAccent;
  final Color info = Colors.white;

  // Typography.
  final TextStyle headlineLarge = const TextStyle(
    fontFamily: 'Asset',
    fontSize: 32,
    fontWeight: FontWeight.w600,
    color: Color(0xFF14181B),
  );

  final TextStyle displaySmall = const TextStyle(
    fontFamily: 'Playfair Display',
    fontSize: 36,
    fontWeight: FontWeight.w400,
    color: Color(0xFF14181B),
  );

  final TextStyle titleLarge = const TextStyle(
    fontFamily: 'Playfair Display',
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: Color(0xFF14181B),
  );

  final TextStyle titleMedium = const TextStyle(
    fontFamily: 'Playfair Display',
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: Color(0xFF14181B),
  );

  final TextStyle bodyLarge = const TextStyle(
    fontFamily: 'Playfair Display',
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: Color(0xFF14181B),
  );

  final TextStyle bodyMedium = const TextStyle(
    fontFamily: 'Playfair Display',
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: Color(0xFF14181B),
  );

  final TextStyle bodySmall = const TextStyle(
    fontFamily: 'Playfair Display',
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: Color(0xFF14181B),
  );

  final TextStyle labelLarge = const TextStyle(
    fontFamily: 'Playfair Display',
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: Color(0xFF57636C),
  );

  final TextStyle labelMedium = const TextStyle(
    fontFamily: 'Playfair Display',
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: Color(0xFF57636C),
  );

  final TextStyle labelSmall = const TextStyle(
    fontFamily: 'Playfair Display',
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: Color(0xFF57636C),
  );

  /// A [ThemeData] generated from the values above, for use with
  /// [MaterialApp.theme].
  ThemeData get themeData => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(seedColor: primary),
    scaffoldBackgroundColor: primaryBackground,
    textTheme: TextTheme(
      displaySmall: displaySmall,
      headlineLarge: headlineLarge,
      titleLarge: titleLarge,
      titleMedium: titleMedium,
      bodyLarge: bodyLarge,
      bodyMedium: bodyMedium,
      bodySmall: bodySmall,
      labelMedium: labelMedium,
      labelLarge: labelLarge,
      labelSmall: labelSmall,
    ),
  );
}

/// Adds the `override` helper to [TextStyle].
///
/// `font` supplies a base style (for example a Google Fonts style); the other
/// arguments override properties on that base style.
extension AppTextStyleOverride on TextStyle {
  TextStyle override({
    TextStyle? font,
    Color? color,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    double? letterSpacing,
    double? lineHeight,
  }) {
    // `font` supplies the typeface (e.g. a Google Fonts variant). Any
    // property not explicitly overridden keeps its value from the theme
    // style — notably fontSize, which Google Fonts styles leave unset.
    final base = font ?? this;
    return base.copyWith(
      color: color ?? this.color,
      fontSize: fontSize ?? this.fontSize,
      fontWeight: fontWeight ?? this.fontWeight,
      fontStyle: fontStyle ?? this.fontStyle,
      letterSpacing: letterSpacing ?? this.letterSpacing,
      height: lineHeight ?? this.height,
    );
  }
}
