import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz;

import 'package:salahsync/core/mosque/month_day.dart';
import 'package:salahsync/core/mosque/time_of_day_value.dart';
import 'package:salahsync/core/mosque/timing_rule.dart';
import 'package:salahsync/core/mosque/timing_rule_resolver.dart';
import 'package:salahsync/core/time/prayer_calculation_config.dart';
import 'package:salahsync/core/time/prayer_time_service.dart';
import 'package:salahsync/core/time/salah_prayer.dart';

void main() {
  setUpAll(() {
    tz.initializeTimeZones();
  });

  group('TimingRuleResolver', () {
    const resolver = TimingRuleResolver();
    const service = PrayerTimeService();
    final baseConfig = PrayerCalculationConfig.khanewalDefault();

    test('offset rules use the adjusted computed prayer start', () {
      final snapshot = service.calculateDay(
        date: DateTime(2026, 3, 21),
        config: baseConfig.copyWith(
          adjustments: const PrayerAdjustments(asr: -1),
        ),
      );

      final resolved = resolver.resolve(
        date: snapshot.date,
        prayer: SalahPrayer.asr,
        computedSnapshot: snapshot,
        rules: const [
          TimingRule.offset(id: 1, prayer: SalahPrayer.asr, offsetMinutes: 15),
        ],
      );

      expect(_hhmm(resolved.dateTime), '16:55');
      expect(resolved.fallbackUsed, isFalse);
    });

    test(
      'fixed and date-range-fixed rules remain anchored to wall-clock times',
      () {
        final snapshot = service.calculateDay(
          date: DateTime(2026, 3, 21),
          config: baseConfig.copyWith(
            adjustments: const PrayerAdjustments(dhuhr: 7),
          ),
        );

        final fixed = resolver.resolve(
          date: snapshot.date,
          prayer: SalahPrayer.dhuhr,
          computedSnapshot: snapshot,
          rules: const [
            TimingRule.fixed(
              id: 4,
              prayer: SalahPrayer.dhuhr,
              fixedTime: TimeOfDayValue(hour: 13, minute: 0),
            ),
          ],
        );

        final ranged = resolver.resolve(
          date: snapshot.date,
          prayer: SalahPrayer.isha,
          computedSnapshot: snapshot,
          rules: const [
            TimingRule.dateRangeFixed(
              id: 5,
              prayer: SalahPrayer.isha,
              fixedTime: TimeOfDayValue(hour: 20, minute: 30),
              rangeStart: MonthDay(month: 3, day: 1),
              rangeEnd: MonthDay(month: 4, day: 30),
            ),
          ],
        );

        expect(_hhmm(fixed.dateTime), '13:00');
        expect(_hhmm(ranged.dateTime), '20:30');
      },
    );

    test('date-range wrapping works across the year boundary', () {
      final novemberSnapshot = service.calculateDay(
        date: DateTime(2026, 11, 15),
        config: baseConfig,
      );
      final maySnapshot = service.calculateDay(
        date: DateTime(2026, 5, 15),
        config: baseConfig,
      );

      const rule = TimingRule.dateRangeFixed(
        id: 8,
        prayer: SalahPrayer.isha,
        fixedTime: TimeOfDayValue(hour: 19, minute: 30),
        rangeStart: MonthDay(month: 11, day: 1),
        rangeEnd: MonthDay(month: 2, day: 28),
      );

      final novemberResolved = resolver.resolve(
        date: novemberSnapshot.date,
        prayer: SalahPrayer.isha,
        computedSnapshot: novemberSnapshot,
        rules: const [rule],
      );

      final mayResolved = resolver.resolve(
        date: maySnapshot.date,
        prayer: SalahPrayer.isha,
        computedSnapshot: maySnapshot,
        rules: const [rule],
      );

      expect(_hhmm(novemberResolved.dateTime), '19:30');
      expect(mayResolved.fallbackUsed, isTrue);
    });

    test('falls back to computed dhuhr for jummah when no rule exists', () {
      final snapshot = service.calculateDay(
        date: DateTime(2026, 3, 20),
        config: baseConfig,
      );

      final resolved = resolver.resolve(
        date: snapshot.date,
        prayer: SalahPrayer.jummah,
        computedSnapshot: snapshot,
        rules: const [],
      );

      expect(resolved.fallbackUsed, isTrue);
      expect(resolved.dateTime, snapshot.timeOf(SalahPrayer.dhuhr));
    });

    test('tie-breaks equal priorities using the lower rule id', () {
      final snapshot = service.calculateDay(
        date: DateTime(2026, 3, 21),
        config: baseConfig,
      );

      final resolved = resolver.resolve(
        date: snapshot.date,
        prayer: SalahPrayer.dhuhr,
        computedSnapshot: snapshot,
        rules: const [
          TimingRule.fixed(
            id: 2,
            prayer: SalahPrayer.dhuhr,
            fixedTime: TimeOfDayValue(hour: 13, minute: 30),
            priority: 10,
          ),
          TimingRule.fixed(
            id: 1,
            prayer: SalahPrayer.dhuhr,
            fixedTime: TimeOfDayValue(hour: 13, minute: 0),
            priority: 10,
          ),
        ],
      );

      expect(_hhmm(resolved.dateTime), '13:00');
      expect(resolved.ruleId, 1);
    });

    test('detects overlapping date-range rules for the same prayer', () {
      final conflicts = resolver.findDateRangeConflicts(const [
        TimingRule.dateRangeFixed(
          id: 10,
          prayer: SalahPrayer.isha,
          fixedTime: TimeOfDayValue(hour: 20, minute: 30),
          rangeStart: MonthDay(month: 5, day: 1),
          rangeEnd: MonthDay(month: 8, day: 31),
        ),
        TimingRule.dateRangeFixed(
          id: 11,
          prayer: SalahPrayer.isha,
          fixedTime: TimeOfDayValue(hour: 20, minute: 0),
          rangeStart: MonthDay(month: 8, day: 15),
          rangeEnd: MonthDay(month: 10, day: 1),
        ),
      ]);

      expect(conflicts, hasLength(1));
      expect(conflicts.single.firstRuleId, 10);
      expect(conflicts.single.secondRuleId, 11);
    });

    test('rejects invalid date-range endpoints instead of looping forever', () {
      expect(
        () => resolver.findDateRangeConflicts(const [
          TimingRule.dateRangeFixed(
            id: 10,
            prayer: SalahPrayer.isha,
            fixedTime: TimeOfDayValue(hour: 20, minute: 30),
            rangeStart: MonthDay(month: 1, day: 1),
            rangeEnd: MonthDay(month: 2, day: 31),
          ),
          TimingRule.dateRangeFixed(
            id: 11,
            prayer: SalahPrayer.isha,
            fixedTime: TimeOfDayValue(hour: 20, minute: 0),
            rangeStart: MonthDay(month: 3, day: 1),
            rangeEnd: MonthDay(month: 4, day: 1),
          ),
        ]),
        throwsA(isA<FormatException>()),
      );
    });
  });
}

String _hhmm(DateTime value) {
  final hour = value.hour.toString().padLeft(2, '0');
  final minute = value.minute.toString().padLeft(2, '0');
  return '$hour:$minute';
}
