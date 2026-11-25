import 'package:material_ui/material_ui.dart';
import 'package:wiggly_loaders/wiggly_loaders.dart' show WigglyButtonState;

///Notifier for changes to the active app theme
final ValueNotifier<ThemeMode> appThemeMode = ValueNotifier<ThemeMode>(
  ThemeMode.system,
);

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

  ///getter for state amplitude. Stops the button moving when idle
  double wiggleAmplitudeFor(WigglyButtonState state) =>
      state == WigglyButtonState.idle ? idleWiggleAmplitude : wiggleAmplitude;
}

///Text styles
TextStyle _headline(Color color) => TextStyle(
  fontFamily: 'Asset',
  fontSize: 32,
  fontWeight: FontWeight.w600,
  color: color,
);

TextStyle _header(Color color) => TextStyle(
  fontFamily: 'Playfair Display',
  fontSize: 36,
  fontWeight: FontWeight.w400,
  color: color,
);

TextStyle _titleLarge(Color color) => TextStyle(
  fontFamily: 'Playfair Display',
  fontSize: 22,
  fontWeight: FontWeight.w600,
  color: color,
);

TextStyle _title(Color color) => TextStyle(
  fontFamily: 'Playfair Display',
  fontSize: 20,
  fontWeight: FontWeight.w600,
  color: color,
);

TextStyle _bodyLarge(Color color) => TextStyle(
  fontFamily: 'Playfair Display',
  fontSize: 18,
  fontWeight: FontWeight.w400,
  color: color,
);

TextStyle _bodyMedium(Color color) => TextStyle(
  fontFamily: 'Playfair Display',
  fontSize: 16,
  fontWeight: FontWeight.w400,
  color: color,
);

TextStyle _bodySmall(Color color) => TextStyle(
  fontFamily: 'Playfair Display',
  fontSize: 14,
  fontWeight: FontWeight.w400,
  color: color,
);

TextStyle _labelLarge(Color color) => TextStyle(
  fontFamily: 'Playfair Display',
  fontSize: 18,
  fontWeight: FontWeight.w500,
  color: color,
);

TextStyle _labelMedium(Color color) => TextStyle(
  fontFamily: 'Playfair Display',
  fontSize: 16,
  fontWeight: FontWeight.w500,
  color: color,
);

TextStyle _labelSmall(Color color) => TextStyle(
  fontFamily: 'Playfair Display',
  fontSize: 14,
  fontWeight: FontWeight.w500,
  color: color,
);

///ThemeExtention to hold the light and dark themes for the ui.
class AppTheme extends ThemeExtension<AppTheme> {
  // Const palette values so shared options can reference them.
  static const Color primaryColor = Color(0xFF82B349);
  static const Color infoColor = Colors.white;
  static const Color errorColor = Color(0xFFf23333);
  static const Color _lightBackground = Color(0xFFEDECEC);
  static const Color _darkBackground = Color(0xFF1c2024);
  static const Color _lightSurface = Color(0xFFfefefe);
  static const Color _darkSurface = Color(0xFF23292e);
  static const Color _lightAlternate = Color(0xFFE0E3E7);
  static const Color _darkAlternate = Color(0xFF14181B);
  static const Color _lightPrimaryText = Color(0xFF14181B);
  static const Color _darkPrimaryText = Color(0xFFE0E3E7);
  static const Color _lightSecondaryText = Color(0xFF57636C);
  static const Color _darkSecondaryText = Color(0xffd1d1d1);

  AppTheme._({
    required this.isDark,
    required this.primaryBackground,
    required this.secondaryBackground,
    required this.primary,
    required this.alternate,
    required this.primaryText,
    required this.secondaryText,
    required this.error,
    required this.info,
    required this.headline,
    required this.header,
    required this.titleLarge,
    required this.title,
    required this.bodyLarge,
    required this.bodyMedium,
    required this.bodySmall,
    required this.labelLarge,
    required this.labelMedium,
    required this.labelSmall,
    this.wigglyButtonOptions = const AppWigglyButtonOptions(),
  });

  factory AppTheme.light() => AppTheme._(
    isDark: false,
    primaryBackground: _lightBackground,
    secondaryBackground: _lightSurface,
    primary: primaryColor,
    alternate: _lightAlternate,
    primaryText: _lightPrimaryText,
    secondaryText: _lightSecondaryText,
    error: errorColor,
    info: infoColor,
    headline: _headline(_lightPrimaryText),
    header: _header(_lightPrimaryText),
    titleLarge: _titleLarge(_lightPrimaryText),
    title: _title(_lightPrimaryText),
    bodyLarge: _bodyLarge(_lightPrimaryText),
    bodyMedium: _bodyMedium(_lightPrimaryText),
    bodySmall: _bodySmall(_lightPrimaryText),
    labelLarge: _labelLarge(_lightSecondaryText),
    labelMedium: _labelMedium(_lightSecondaryText),
    labelSmall: _labelSmall(_lightSecondaryText),
  );

  factory AppTheme.dark() => AppTheme._(
    isDark: true,
    primaryBackground: _darkBackground,
    secondaryBackground: _darkSurface,
    primary: primaryColor,
    alternate: _darkAlternate,
    primaryText: _darkPrimaryText,
    secondaryText: _darkSecondaryText,
    error: errorColor,
    info: infoColor,
    headline: _headline(_darkPrimaryText),
    header: _header(_darkPrimaryText),
    titleLarge: _titleLarge(_darkPrimaryText),
    title: _title(_darkPrimaryText),
    bodyLarge: _bodyLarge(_darkPrimaryText),
    bodyMedium: _bodyMedium(_darkPrimaryText),
    bodySmall: _bodySmall(_darkPrimaryText),
    labelLarge: _labelLarge(_darkSecondaryText),
    labelMedium: _labelMedium(_darkSecondaryText),
    labelSmall: _labelSmall(_darkSecondaryText),
  );

  /// Returns the theme variant active for [context].
  static AppTheme of(BuildContext context) =>
      Theme.of(context).extension<AppTheme>() ?? AppTheme.light();

  /// Applies a saved user preference, overriding platform brightness.
  static void applyUserPreference(bool dark) =>
      appThemeMode.value = dark ? ThemeMode.dark : ThemeMode.light;

  /// Returns theme selection to the platform brightness.
  static void resetToSystem() => appThemeMode.value = ThemeMode.system;

  final bool isDark;

  // Colours.
  final Color primaryBackground;
  final Color secondaryBackground;
  final Color primary;
  final Color alternate;
  final Color primaryText;
  final Color secondaryText;
  final Color error;
  final Color info;

  /// Shared options for the app's progress buttons.
  final AppWigglyButtonOptions wigglyButtonOptions;

  // Typography.
  final TextStyle headline;
  final TextStyle header;
  final TextStyle titleLarge;
  final TextStyle title;
  final TextStyle bodyLarge;
  final TextStyle bodyMedium;
  final TextStyle bodySmall;
  final TextStyle labelLarge;
  final TextStyle labelMedium;
  final TextStyle labelSmall;

  Brightness get brightness => isDark ? Brightness.dark : Brightness.light;

  /// A [ThemeData] generated from this variant, for use with
  /// [MaterialApp.theme] / [MaterialApp.darkTheme].
  ThemeData get themeData => ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primary,
      brightness: brightness,
    ),
    scaffoldBackgroundColor: primaryBackground,
    textTheme: TextTheme(
      displaySmall: header,
      headlineLarge: headline,
      titleLarge: titleLarge,
      titleMedium: title,
      bodyLarge: bodyLarge,
      bodyMedium: bodyMedium,
      bodySmall: bodySmall,
      labelMedium: labelMedium,
      labelLarge: labelLarge,
      labelSmall: labelSmall,
    ),
    extensions: <ThemeExtension<dynamic>>{this},
  );

  @override
  AppTheme copyWith({
    bool? isDark,
    Color? primaryBackground,
    Color? secondaryBackground,
    Color? primary,
    Color? alternate,
    Color? primaryText,
    Color? secondaryText,
    Color? error,
    Color? info,
    AppWigglyButtonOptions? wigglyButtonOptions,
    TextStyle? headlineLarge,
    TextStyle? displaySmall,
    TextStyle? titleLarge,
    TextStyle? titleMedium,
    TextStyle? bodyLarge,
    TextStyle? bodyMedium,
    TextStyle? bodySmall,
    TextStyle? labelLarge,
    TextStyle? labelMedium,
    TextStyle? labelSmall,
  }) {
    return AppTheme._(
      isDark: isDark ?? this.isDark,
      primaryBackground: primaryBackground ?? this.primaryBackground,
      secondaryBackground: secondaryBackground ?? this.secondaryBackground,
      primary: primary ?? this.primary,
      alternate: alternate ?? this.alternate,
      primaryText: primaryText ?? this.primaryText,
      secondaryText: secondaryText ?? this.secondaryText,
      error: error ?? this.error,
      info: info ?? this.info,
      wigglyButtonOptions: wigglyButtonOptions ?? this.wigglyButtonOptions,
      headline: headlineLarge ?? headline,
      header: displaySmall ?? header,
      titleLarge: titleLarge ?? this.titleLarge,
      title: titleMedium ?? title,
      bodyLarge: bodyLarge ?? this.bodyLarge,
      bodyMedium: bodyMedium ?? this.bodyMedium,
      bodySmall: bodySmall ?? this.bodySmall,
      labelLarge: labelLarge ?? this.labelLarge,
      labelMedium: labelMedium ?? this.labelMedium,
      labelSmall: labelSmall ?? this.labelSmall,
    );
  }

  @override
  AppTheme lerp(covariant AppTheme? other, double t) {
    if (other == null || identical(this, other)) return this;

    return AppTheme._(
      isDark: t < 0.5 ? isDark : other.isDark,
      primaryBackground:
          Color.lerp(primaryBackground, other.primaryBackground, t) ??
          primaryBackground,
      secondaryBackground:
          Color.lerp(secondaryBackground, other.secondaryBackground, t) ??
          secondaryBackground,
      primary: Color.lerp(primary, other.primary, t) ?? primary,
      alternate: Color.lerp(alternate, other.alternate, t) ?? alternate,
      primaryText: Color.lerp(primaryText, other.primaryText, t) ?? primaryText,
      secondaryText:
          Color.lerp(secondaryText, other.secondaryText, t) ?? secondaryText,
      error: Color.lerp(error, other.error, t) ?? error,
      info: Color.lerp(info, other.info, t) ?? info,
      wigglyButtonOptions: t < 0.5
          ? wigglyButtonOptions
          : other.wigglyButtonOptions,
      headline: TextStyle.lerp(headline, other.headline, t) ?? headline,
      header: TextStyle.lerp(header, other.header, t) ?? header,
      titleLarge: TextStyle.lerp(titleLarge, other.titleLarge, t) ?? titleLarge,
      title: TextStyle.lerp(title, other.title, t) ?? title,
      bodyLarge: TextStyle.lerp(bodyLarge, other.bodyLarge, t) ?? bodyLarge,
      bodyMedium: TextStyle.lerp(bodyMedium, other.bodyMedium, t) ?? bodyMedium,
      bodySmall: TextStyle.lerp(bodySmall, other.bodySmall, t) ?? bodySmall,
      labelLarge: TextStyle.lerp(labelLarge, other.labelLarge, t) ?? labelLarge,
      labelMedium:
          TextStyle.lerp(labelMedium, other.labelMedium, t) ?? labelMedium,
      labelSmall: TextStyle.lerp(labelSmall, other.labelSmall, t) ?? labelSmall,
    );
  }
}

/// Adds the `override` helper to [TextStyle].
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
