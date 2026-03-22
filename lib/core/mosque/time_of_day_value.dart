import 'package:timezone/timezone.dart' as tz;

class TimeOfDayValue {
  const TimeOfDayValue({required this.hour, required this.minute});

  factory TimeOfDayValue.parse(String value) {
    final parts = value.split(':');
    if (parts.length != 2) {
      throw FormatException('Expected HH:MM but received $value');
    }

    return TimeOfDayValue(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );
  }

  final int hour;
  final int minute;

  DateTime onDate(DateTime date) {
    if (date is tz.TZDateTime) {
      return tz.TZDateTime(
        date.location,
        date.year,
        date.month,
        date.day,
        hour,
        minute,
      );
    }

    return DateTime(date.year, date.month, date.day, hour, minute);
  }

  @override
  String toString() {
    final hourText = hour.toString().padLeft(2, '0');
    final minuteText = minute.toString().padLeft(2, '0');
    return '$hourText:$minuteText';
  }
}
