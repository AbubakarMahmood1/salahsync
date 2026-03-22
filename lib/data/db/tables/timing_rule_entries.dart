import 'package:drift/drift.dart';

import '../../../core/mosque/timing_rule.dart';
import '../../../core/time/salah_prayer.dart';
import '../converters/month_day_converter.dart';
import '../converters/time_of_day_value_converter.dart';
import 'mosques.dart';

class TimingRuleEntries extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get mosqueId =>
      integer().references(Mosques, #id, onDelete: KeyAction.cascade)();

  TextColumn get prayer => textEnum<SalahPrayer>()();

  TextColumn get mode => textEnum<TimingRuleMode>()();

  IntColumn get offsetMinutes => integer().nullable()();

  TextColumn get fixedTime =>
      text().map(const TimeOfDayValueConverter()).nullable()();

  TextColumn get rangeStart =>
      text().map(const MonthDayConverter()).nullable()();

  TextColumn get rangeEnd => text().map(const MonthDayConverter()).nullable()();

  IntColumn get priority => integer().withDefault(const Constant(0))();

  TextColumn get createdAt => text()();
}
