import '../time/prayer_times_snapshot.dart';
import '../time/salah_prayer.dart';
import 'month_day.dart';
import 'resolved_timing.dart';
import 'timing_rule.dart';

class TimingRuleResolver {
  const TimingRuleResolver();

  ResolvedTiming resolve({
    required DateTime date,
    required SalahPrayer prayer,
    required PrayerTimesSnapshot computedSnapshot,
    required List<TimingRule> rules,
  }) {
    final applicable =
        rules
            .where((rule) => rule.prayer == prayer && rule.matches(date))
            .toList()
          ..sort((left, right) {
            final priorityCompare = right.priority.compareTo(left.priority);
            if (priorityCompare != 0) {
              return priorityCompare;
            }

            final specificityCompare = _modeSpecificity(
              right.mode,
            ).compareTo(_modeSpecificity(left.mode));
            if (specificityCompare != 0) {
              return specificityCompare;
            }

            final leftId = left.id ?? 1 << 30;
            final rightId = right.id ?? 1 << 30;
            return leftId.compareTo(rightId);
          });

    if (applicable.isEmpty) {
      return _computedFallback(
        prayer: prayer,
        computedSnapshot: computedSnapshot,
      );
    }

    final rule = applicable.first;
    return switch (rule.mode) {
      TimingRuleMode.offset => ResolvedTiming(
        prayer: prayer,
        dateTime: computedSnapshot
            .timeOf(_fallbackPrayerFor(prayer))
            .add(Duration(minutes: rule.offsetMinutes!)),
        source: ResolvedTimingSource.offsetRule,
        fallbackUsed: false,
        ruleId: rule.id,
      ),
      TimingRuleMode.fixed => ResolvedTiming(
        prayer: prayer,
        dateTime: rule.fixedTime!.onDate(date),
        source: ResolvedTimingSource.fixedRule,
        fallbackUsed: false,
        ruleId: rule.id,
      ),
      TimingRuleMode.dateRangeFixed => ResolvedTiming(
        prayer: prayer,
        dateTime: rule.fixedTime!.onDate(date),
        source: ResolvedTimingSource.dateRangeRule,
        fallbackUsed: false,
        ruleId: rule.id,
      ),
    };
  }

  List<TimingRuleConflict> findDateRangeConflicts(List<TimingRule> rules) {
    final dateRangeRules = rules
        .where((rule) => rule.mode == TimingRuleMode.dateRangeFixed)
        .toList();
    final conflicts = <TimingRuleConflict>[];

    for (var i = 0; i < dateRangeRules.length; i++) {
      for (var j = i + 1; j < dateRangeRules.length; j++) {
        final left = dateRangeRules[i];
        final right = dateRangeRules[j];
        if (left.prayer != right.prayer) {
          continue;
        }

        if (_rangesOverlap(
          left.rangeStart!,
          left.rangeEnd!,
          right.rangeStart!,
          right.rangeEnd!,
        )) {
          conflicts.add(
            TimingRuleConflict(firstRuleId: left.id, secondRuleId: right.id),
          );
        }
      }
    }

    return conflicts;
  }

  ResolvedTiming _computedFallback({
    required SalahPrayer prayer,
    required PrayerTimesSnapshot computedSnapshot,
  }) {
    final fallbackPrayer = _fallbackPrayerFor(prayer);
    return ResolvedTiming(
      prayer: prayer,
      dateTime: computedSnapshot.timeOf(fallbackPrayer),
      source: ResolvedTimingSource.computedFallback,
      fallbackUsed: true,
    );
  }

  SalahPrayer _fallbackPrayerFor(SalahPrayer prayer) {
    if (prayer == SalahPrayer.jummah) {
      return SalahPrayer.dhuhr;
    }

    return prayer;
  }

  bool _rangesOverlap(
    MonthDay leftStart,
    MonthDay leftEnd,
    MonthDay rightStart,
    MonthDay rightEnd,
  ) {
    final leftKeys = _rangeKeys(leftStart, leftEnd).toSet();
    final rightKeys = _rangeKeys(rightStart, rightEnd);
    return rightKeys.any(leftKeys.contains);
  }

  Iterable<String> _rangeKeys(MonthDay start, MonthDay end) sync* {
    var cursor = DateTime(2024, start.month, start.day);
    final target = DateTime(
      start.compareTo(end) <= 0 ? 2024 : 2025,
      end.month,
      end.day,
    );

    while (!cursor.isAfter(target)) {
      final month = cursor.month.toString().padLeft(2, '0');
      final day = cursor.day.toString().padLeft(2, '0');
      yield '$month-$day';
      cursor = cursor.add(const Duration(days: 1));
    }
  }

  int _modeSpecificity(TimingRuleMode mode) {
    return switch (mode) {
      TimingRuleMode.offset => 1,
      TimingRuleMode.fixed => 2,
      TimingRuleMode.dateRangeFixed => 3,
    };
  }
}
