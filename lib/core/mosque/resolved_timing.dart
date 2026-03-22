import '../time/salah_prayer.dart';

enum ResolvedTimingSource {
  computedFallback,
  offsetRule,
  fixedRule,
  dateRangeRule,
}

class ResolvedTiming {
  const ResolvedTiming({
    required this.prayer,
    required this.dateTime,
    required this.source,
    required this.fallbackUsed,
    this.ruleId,
  });

  final SalahPrayer prayer;
  final DateTime dateTime;
  final ResolvedTimingSource source;
  final bool fallbackUsed;
  final int? ruleId;
}

class TimingRuleConflict {
  const TimingRuleConflict({
    required this.firstRuleId,
    required this.secondRuleId,
  });

  final int? firstRuleId;
  final int? secondRuleId;
}
