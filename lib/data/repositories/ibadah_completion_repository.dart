import 'package:drift/drift.dart';

import '../../core/utils/date_key.dart';
import '../db/app_database.dart';
import '../models/ibadah_completion_record.dart';

class IbadahCompletionRepository {
  IbadahCompletionRepository(this._db);

  final AppDatabase _db;

  Future<List<IbadahCompletionRecord>> listForDate(DateTime date) async {
    final rows = await (_db.select(
      _db.ibadahCompletionEntries,
    )..where((table) => table.date.equals(formatDateKey(date)))).get();
    return rows.map(_toDomain).toList(growable: false);
  }

  Stream<List<IbadahCompletionRecord>> watchForDate(DateTime date) {
    return (_db.select(_db.ibadahCompletionEntries)
          ..where((table) => table.date.equals(formatDateKey(date))))
        .watch()
        .map((rows) => rows.map(_toDomain).toList(growable: false));
  }

  Future<List<IbadahCompletionRecord>> listForTaskIds(
    Iterable<int> taskIds,
  ) async {
    final ids = taskIds.toList(growable: false);
    if (ids.isEmpty) {
      return const <IbadahCompletionRecord>[];
    }

    final rows = await (_db.select(
      _db.ibadahCompletionEntries,
    )..where((table) => table.taskId.isIn(ids))).get();
    return rows.map(_toDomain).toList(growable: false);
  }

  Future<int> upsert({
    required int taskId,
    required DateTime date,
    String? prayerInstance,
    int countDone = 0,
    bool completed = false,
    String? notes,
  }) async {
    final dateKey = formatDateKey(date);
    final existing =
        await (_db.select(_db.ibadahCompletionEntries)
              ..where((table) => table.taskId.equals(taskId))
              ..where((table) => table.date.equals(dateKey))
              ..where(
                (table) => prayerInstance == null
                    ? table.prayerInstance.isNull()
                    : table.prayerInstance.equals(prayerInstance),
              ))
            .getSingleOrNull();

    final companion = IbadahCompletionEntriesCompanion(
      taskId: Value(taskId),
      date: Value(dateKey),
      prayerInstance: Value(prayerInstance),
      countDone: Value(countDone),
      completed: Value(completed),
      notes: Value(_nullIfBlank(notes)),
    );

    if (existing == null) {
      return _db.into(_db.ibadahCompletionEntries).insert(companion);
    }

    await (_db.update(
      _db.ibadahCompletionEntries,
    )..where((table) => table.id.equals(existing.id))).write(companion);
    return existing.id;
  }

  Future<void> clear({
    required int taskId,
    required DateTime date,
    String? prayerInstance,
  }) async {
    await (_db.delete(_db.ibadahCompletionEntries)
          ..where((table) => table.taskId.equals(taskId))
          ..where((table) => table.date.equals(formatDateKey(date)))
          ..where(
            (table) => prayerInstance == null
                ? table.prayerInstance.isNull()
                : table.prayerInstance.equals(prayerInstance),
          ))
        .go();
  }

  Future<void> resetAll() async {
    await (_db.delete(_db.ibadahCompletionEntries)).go();
  }

  IbadahCompletionRecord _toDomain(IbadahCompletionEntry row) {
    return IbadahCompletionRecord(
      id: row.id,
      taskId: row.taskId,
      date: parseDateKey(row.date),
      prayerInstance: row.prayerInstance,
      countDone: row.countDone,
      completed: row.completed,
      notes: row.notes,
    );
  }

  String? _nullIfBlank(String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) {
      return null;
    }
    return trimmed;
  }
}
