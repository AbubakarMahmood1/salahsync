import 'package:drift/drift.dart';

import '../../../core/mosque/time_of_day_value.dart';

class TimeOfDayValueConverter extends TypeConverter<TimeOfDayValue, String> {
  const TimeOfDayValueConverter();

  @override
  TimeOfDayValue fromSql(String fromDb) {
    return TimeOfDayValue.parse(fromDb);
  }

  @override
  String toSql(TimeOfDayValue value) {
    return value.toString();
  }
}
