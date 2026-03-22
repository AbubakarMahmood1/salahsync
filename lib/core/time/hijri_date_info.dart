class HijriDateInfo {
  const HijriDateInfo({
    required this.year,
    required this.month,
    required this.day,
    required this.monthName,
    required this.weekdayName,
    required this.adjustmentDays,
  });

  final int year;
  final int month;
  final int day;
  final String monthName;
  final String weekdayName;
  final int adjustmentDays;

  bool get isRamadan => month == 9;

  String get shortLabel => '$day $monthName $year AH';
}
