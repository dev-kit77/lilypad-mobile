import 'package:material_ui/material_ui.dart';

/// Number formatting options used by the UI.
enum NumberFormatType { compact, decimal, percent, currency }

/// Formats a number for display in the UI.
String formatNumber(
  num? value, {
  NumberFormatType formatType = NumberFormatType.compact,
}) {
  final number = value ?? 0;
  switch (formatType) {
    case NumberFormatType.compact:
      return _compact(number);
    case NumberFormatType.percent:
      return '${_trim(number)}%';
    case NumberFormatType.currency:
      return '\$${_trim(number)}';
    case NumberFormatType.decimal:
      return _trim(number);
  }
}

String _compact(num number) {
  final absolute = number.abs();
  if (absolute >= 1000000000) return '${_trim(number / 1000000000)}B';
  if (absolute >= 1000000) return '${_trim(number / 1000000)}M';
  if (absolute >= 1000) return '${_trim(number / 1000)}K';
  return _trim(number);
}

String _trim(num number) {
  final text = number.toStringAsFixed(1);
  return text.endsWith('.0') ? text.substring(0, text.length - 2) : text;
}

/// Helpers for building widget lists.
extension WidgetListHelpers on List<Widget> {
  /// Inserts [separator] between each pair of widgets in this list.
  List<Widget> divide(Widget separator) {
    if (isEmpty) return <Widget>[];
    final divided = <Widget>[first];
    for (final widget in skip(1)) {
      divided.add(separator);
      divided.add(widget);
    }
    return divided;
  }

  /// Appends [widget] to this list.
  List<Widget> addToEnd(Widget widget) => [...this, widget];

  /// Wraps this list with [widget] at both ends.
  List<Widget> around(Widget widget) => [widget, ...this, widget];
}
