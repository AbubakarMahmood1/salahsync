String formatDateKey(DateTime value) {
  final date = DateTime(value.year, value.month, value.day);
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  return '${date.year}-$month-$day';
}

DateTime parseDateKey(String value) {
  final parts = value.split('-');
  if (parts.length != 3) {
    throw FormatException('Invalid date key', value);
  }

  return DateTime(
    int.parse(parts[0]),
    int.parse(parts[1]),
    int.parse(parts[2]),
  );
}

DateTime startOfDay(DateTime value) {
  return DateTime(value.year, value.month, value.day);
}

DateTime endOfDay(DateTime value) {
  return DateTime(value.year, value.month, value.day, 23, 59, 59, 999);
}

DateTime startOfWeek(DateTime value) {
  final date = startOfDay(value);
  return date.subtract(Duration(days: date.weekday - DateTime.monday));
}

DateTime endOfWeek(DateTime value) {
  return startOfWeek(value).add(const Duration(days: 6));
}

DateTime startOfMonth(DateTime value) {
  return DateTime(value.year, value.month);
}

DateTime endOfMonth(DateTime value) {
  return DateTime(value.year, value.month + 1, 0);
}
