import 'package:drift/drift.dart';

import 'ibadah_task_entries.dart';

class IbadahCompletionEntries extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get taskId => integer().references(
    IbadahTaskEntries,
    #id,
    onDelete: KeyAction.cascade,
  )();

  TextColumn get date => text()();

  TextColumn get prayerInstance => text().nullable()();

  IntColumn get countDone => integer().withDefault(const Constant(0))();

  BoolColumn get completed => boolean().withDefault(const Constant(false))();

  TextColumn get notes => text().nullable()();

  @override
  List<Set<Column<Object>>> get uniqueKeys => [
    {taskId, date, prayerInstance},
  ];
}
