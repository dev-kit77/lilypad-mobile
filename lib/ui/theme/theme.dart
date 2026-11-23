import 'package:material_ui/material_ui.dart';
import 'package:wiggly_loaders/wiggly_loaders.dart' show WigglyButtonState;

///Shared layout, animation and colour options for the wiggly progress buttons.
class AppWigglyButtonOptions {
  const AppWigglyButtonOptions({
    this.width = 120,
    this.height = 60,
    this.borderRadius = 40,
    this.progressColor = AppTheme.primaryColor,
    this.foregroundColor = AppTheme.infoColor,
    this.successColor = AppTheme.primaryColor,
    this.errorColor = AppTheme.errorColor,
    this.wiggleAmplitude = 1.8,
    this.idleWiggleAmplitude = 0,
    this.wiggleCount = 12,
    this.wiggleDuration = const Duration(milliseconds: 1600),
    this.morphDuration = const Duration(milliseconds: 360),
  });

  final double width;
  final double height;
  final double borderRadius;
  final Color progressColor;
  final Color foregroundColor;
  final Color successColor;
  final Color errorColor;
  final double wiggleAmplitude;

  /// Amplitude used while the button is idle. Defaults to zero so the button
  /// stays perfectly still until it is pressed.
  final double idleWiggleAmplitude;

  final int wiggleCount;
  final Duration wiggleDuration;
  final Duration morphDuration;

  AppWigglyButtonOptions copyWith({
    double? width,
    double? height,
    double? borderRadius,
    Color? progressColor,
    Color? foregroundColor,
    Color? successColor,
    Color? errorColor,
    double? wiggleAmplitude,
    double? idleWiggleAmplitude,
    int? wiggleCount,
    Duration? wiggleDuration,
    Duration? morphDuration,
  }) {
    return AppWigglyButtonOptions(
      width: width ?? this.width,
      height: height ?? this.height,
      borderRadius: borderRadius ?? this.borderRadius,
      progressColor: progressColor ?? this.progressColor,
      foregroundColor: foregroundColor ?? this.foregroundColor,
      successColor: successColor ?? this.successColor,
      errorColor: errorColor ?? this.errorColor,
      wiggleAmplitude: wiggleAmplitude ?? this.wiggleAmplitude,
      idleWiggleAmplitude: idleWiggleAmplitude ?? this.idleWiggleAmplitude,
      wiggleCount: wiggleCount ?? this.wiggleCount,
      wiggleDuration: wiggleDuration ?? this.wiggleDuration,
      morphDuration: morphDuration ?? this.morphDuration,
    );
  }

  /// Amplitude for [state] — idle stays still, active states wiggle.
  double wiggleAmplitudeFor(WigglyButtonState state) =>
      state == WigglyButtonState.idle ? idleWiggleAmplitude : wiggleAmplitude;
}

/// Holds the colours and text styles shared by the Lilypad UI.
class AppTheme {
  // Const palette values so shared options can reference them.
  static const Color primaryColor = Color(0xFF82B349);
  static const Color infoColor = Colors.white;
  static const Color errorColor = Colors.redAccent;

  AppTheme._();

  static final AppTheme _instance = AppTheme._();

  /// Returns the shared theme for [context].
  static AppTheme of(BuildContext context) => _instance;

  // Colours.
  final Color primaryBackground = const Color(0xFFF7F8F7);
  final Color secondaryBackground = Colors.white;
  final Color primary = primaryColor;
  final Color alternate = const Color(0xFFE0E3E7);
  final Color primaryText = const Color(0xFF14181B);
  final Color secondaryText = const Color(0xFF57636C);
  final Color error = errorColor;
  final Color info = infoColor;

  /// Shared options for the app's progress buttons.
  final AppWigglyButtonOptions wigglyButtonOptions =
      const AppWigglyButtonOptions();

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
      height: lineHeight ?? height,
    );
  }
}
