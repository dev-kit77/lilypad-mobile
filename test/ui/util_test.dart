import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:lilypad/util/ui.dart';

void main() {
  group('formatNumber', () {
    test('formats compact numbers with the expected suffixes', () {
      expect(formatNumber(0), '0');
      expect(formatNumber(999), '999');
      expect(formatNumber(1000), '1K');
      expect(formatNumber(1500), '1.5K');
      expect(formatNumber(2_500_000), '2.5M');
      expect(formatNumber(3_000_000_000), '3B');
    });

    test('formats negative and missing values', () {
      expect(formatNumber(null), '0');
      expect(formatNumber(-1500), '-1.5K');
      expect(formatNumber(-0.25), '-0.3');
    });

    test('supports decimal, percent and currency formats', () {
      expect(formatNumber(12.34, formatType: NumberFormatType.decimal), '12.3');
      expect(formatNumber(0.5, formatType: NumberFormatType.percent), '0.5%');
      expect(formatNumber(10, formatType: NumberFormatType.currency), r'$10');
    });
  });

  group('WidgetListHelpers', () {
    test('divide leaves an empty list empty', () {
      expect(<Widget>[].divide(const SizedBox(width: 8)), isEmpty);
    });

    test('divide inserts separators only between widgets', () {
      final List<Widget> divided = <Widget>[
        const Text('a'),
        const Text('b'),
        const Text('c'),
      ].divide(const SizedBox(width: 4));

      expect(divided.length, 5);
      expect(divided.first, isA<Text>());
      expect(divided.last, isA<Text>());
      expect(divided.whereType<SizedBox>(), hasLength(2));
    });

    test('addToEnd appends without mutating the original list', () {
      final List<Widget> original = <Widget>[const Text('a')];

      final List<Widget> extended = original.addToEnd(const Text('b'));

      expect(original, hasLength(1));
      expect(extended, hasLength(2));
      expect(extended.last, isA<Text>());
    });

    test('around wraps a list with the same widget on both ends', () {
      final List<Widget> wrapped = <Widget>[
        const Text('a'),
        const Text('b'),
      ].around(const Divider());

      expect(wrapped.length, 4);
      expect(wrapped.first, isA<Divider>());
      expect(wrapped.last, isA<Divider>());
    });
  });
}
