import 'package:drift/drift.dart';

import 'mosques.dart';

class PrayerLogEntries extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get date => text()();

  TextColumn get prayer => text()();

  TextColumn get status => text()();

  IntColumn get mosqueId => integer().nullable().references(
    Mosques,
    #id,
    onDelete: KeyAction.setNull,
  )();

  TextColumn get notes => text().nullable()();

  TextColumn get loggedAt => text()();

  @override
  List<Set<Column<Object>>> get uniqueKeys => [
    {date, prayer},
  ];
}
