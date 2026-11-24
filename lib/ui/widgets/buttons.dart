import 'package:material_ui/material_ui.dart';

/// Styling options for [AppButton].
class AppButtonOptions {
  const AppButtonOptions({
    this.width,
    this.height,
    this.padding = const EdgeInsets.symmetric(horizontal: 16),
    this.iconPadding,
    this.iconAlignment = IconAlignment.start,
    this.color,
    this.textStyle,
    this.elevation = 0,
    this.borderSide,
    this.borderRadius,
  });

  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? iconPadding;
  final IconAlignment iconAlignment;
  final Color? color;
  final TextStyle? textStyle;
  final double? elevation;
  final BorderSide? borderSide;
  final BorderRadius? borderRadius;
}

/// A simple button used throughout the UI.
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    this.onPressed,
    this.text,
    this.icon,
    this.options = const AppButtonOptions(),
    this.showLoadingIndicator = false,
  });

  final VoidCallback? onPressed;
  final String? text;
  final Widget? icon;
  final AppButtonOptions options;
  final bool showLoadingIndicator;

  @override
  Widget build(BuildContext context) {
    final content = <Widget>[];

    if (icon != null) {
      content.add(
        Padding(padding: options.iconPadding ?? EdgeInsets.zero, child: icon),
      );
    }

    if (text != null && text!.isNotEmpty) {
      content.add(Text(text!, style: options.textStyle));
    }

    final children = options.iconAlignment == IconAlignment.end
        ? content.reversed.toList()
        : content;

    return SizedBox(
      width: options.width,
      height: options.height,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: options.color,
          foregroundColor: options.textStyle?.color,
          elevation: options.elevation,
          padding: options.padding,
          shape: RoundedRectangleBorder(
            borderRadius: options.borderRadius ?? BorderRadius.zero,
            side: options.borderSide ?? BorderSide.none,
          ),
        ),
        onPressed: onPressed,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 5,
          children: children,
        ),
      ),
    );
  }
}
