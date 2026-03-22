import 'package:drift/drift.dart';

class IbadahTaskEntries extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get title => text()();

  TextColumn get description => text().nullable()();

  TextColumn get prayerLink => text().nullable()();

  TextColumn get timing => text().withDefault(const Constant('after'))();

  TextColumn get repeatType => text()();

  TextColumn get repeatDays => text().nullable()();

  IntColumn get countTarget => integer().nullable()();

  BoolColumn get isActive => boolean().withDefault(const Constant(true))();

  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
}
