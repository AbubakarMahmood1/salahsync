import 'package:flutter_test/flutter_test.dart';

import 'package:salahsync/core/mosque/month_day.dart';

void main() {
  group('MonthDay', () {
    test('parse accepts valid calendar dates', () {
      expect(MonthDay.parse('02-29').toString(), '02-29');
      expect(MonthDay.parse('04-30').toString(), '04-30');
    });

    test('parse rejects impossible calendar dates', () {
      expect(() => MonthDay.parse('02-31'), throwsA(isA<FormatException>()));
      expect(() => MonthDay.parse('04-31'), throwsA(isA<FormatException>()));
      expect(() => MonthDay.parse('13-01'), throwsA(isA<FormatException>()));
    });
  });
}
