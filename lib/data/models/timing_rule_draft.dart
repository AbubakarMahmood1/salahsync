import '../../core/mosque/month_day.dart';
import '../../core/mosque/time_of_day_value.dart';
import '../../core/mosque/timing_rule.dart';
import '../../core/time/salah_prayer.dart';

class TimingRuleDraft {
  const TimingRuleDraft({
    this.id,
    required this.mosqueId,
    required this.prayer,
    required this.mode,
    this.offsetMinutes,
    this.fixedTime,
    this.rangeStart,
    this.rangeEnd,
    this.priority = 0,
  });

  final int? id;
  final int mosqueId;
  final SalahPrayer prayer;
  final TimingRuleMode mode;
  final int? offsetMinutes;
  final TimeOfDayValue? fixedTime;
  final MonthDay? rangeStart;
  final MonthDay? rangeEnd;
  final int priority;
}
