import '../time/salah_prayer.dart';
import 'month_day.dart';
import 'time_of_day_value.dart';

enum TimingRuleMode { offset, fixed, dateRangeFixed }

class TimingRule {
  const TimingRule.offset({
    this.id,
    required this.prayer,
    required this.offsetMinutes,
    this.priority = 0,
  }) : mode = TimingRuleMode.offset,
       fixedTime = null,
       rangeStart = null,
       rangeEnd = null;

  const TimingRule.fixed({
    this.id,
    required this.prayer,
    required this.fixedTime,
    this.priority = 0,
  }) : mode = TimingRuleMode.fixed,
       offsetMinutes = null,
       rangeStart = null,
       rangeEnd = null;

  const TimingRule.dateRangeFixed({
    this.id,
    required this.prayer,
    required this.fixedTime,
    required this.rangeStart,
    required this.rangeEnd,
    this.priority = 0,
  }) : mode = TimingRuleMode.dateRangeFixed,
       offsetMinutes = null;

  final int? id;
  final SalahPrayer prayer;
  final TimingRuleMode mode;
  final int? offsetMinutes;
  final TimeOfDayValue? fixedTime;
  final MonthDay? rangeStart;
  final MonthDay? rangeEnd;
  final int priority;

  bool matches(DateTime date) {
    return switch (mode) {
      TimingRuleMode.offset || TimingRuleMode.fixed => true,
      TimingRuleMode.dateRangeFixed => rangeStart!.isWithinInclusiveRange(
        date: date,
        end: rangeEnd!,
      ),
    };
  }
}
