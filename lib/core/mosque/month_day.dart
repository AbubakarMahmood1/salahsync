class MonthDay {
  const MonthDay({required this.month, required this.day});

  factory MonthDay.parse(String value) {
    final parts = value.split('-');
    if (parts.length != 2) {
      throw FormatException('Expected MM-DD but received $value');
    }

    return MonthDay(month: int.parse(parts[0]), day: int.parse(parts[1]));
  }

  final int month;
  final int day;

  int compareTo(MonthDay other) {
    if (month != other.month) {
      return month.compareTo(other.month);
    }
    return day.compareTo(other.day);
  }

  bool isWithinInclusiveRange({required DateTime date, required MonthDay end}) {
    final candidate = MonthDay(month: date.month, day: date.day);

    if (compareTo(end) <= 0) {
      return compareTo(candidate) <= 0 && candidate.compareTo(end) <= 0;
    }

    return compareTo(candidate) <= 0 || candidate.compareTo(end) <= 0;
  }

  @override
  String toString() {
    final monthText = month.toString().padLeft(2, '0');
    final dayText = day.toString().padLeft(2, '0');
    return '$monthText-$dayText';
  }
}
