import 'package:drift/drift.dart';

import '../../../core/mosque/month_day.dart';

class MonthDayConverter extends TypeConverter<MonthDay, String> {
  const MonthDayConverter();

  @override
  MonthDay fromSql(String fromDb) {
    return MonthDay.parse(fromDb);
  }

  @override
  String toSql(MonthDay value) {
    return value.toString();
  }
}
