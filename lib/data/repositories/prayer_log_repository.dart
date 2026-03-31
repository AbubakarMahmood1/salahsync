import 'package:drift/drift.dart';

import '../../core/prayer_log/prayer_log_status.dart';
import '../../core/time/salah_prayer.dart';
import '../../core/utils/date_key.dart';
import '../db/app_database.dart';
import '../models/prayer_log_draft.dart';
import '../models/prayer_log_record.dart';

class PrayerLogRepository {
  PrayerLogRepository(this._db);

  final AppDatabase _db;

  Future<List<PrayerLogRecord>> listForDate(DateTime date) async {
    final rows =
        await (_db.select(_db.prayerLogEntries)
              ..where((table) => table.date.equals(formatDateKey(date)))
              ..orderBy([(table) => OrderingTerm(expression: table.prayer)]))
            .get();
    return rows.map(_toDomain).toList(growable: false);
  }

  Future<List<PrayerLogRecord>> listForRange(
    DateTime start,
    DateTime end,
  ) async {
    final rows =
        await (_db.select(_db.prayerLogEntries)..where(
              (table) => table.date.isBetweenValues(
                formatDateKey(start),
                formatDateKey(end),
              ),
            ))
            .get();
    return rows.map(_toDomain).toList(growable: false);
  }

  Stream<List<PrayerLogRecord>> watchForDate(DateTime date) {
    return (_db.select(_db.prayerLogEntries)
          ..where((table) => table.date.equals(formatDateKey(date)))
          ..orderBy([(table) => OrderingTerm(expression: table.prayer)]))
        .watch()
        .map((rows) => rows.map(_toDomain).toList(growable: false));
  }

  Future<void> save(PrayerLogDraft draft) async {
    final dateKey = formatDateKey(draft.date);
    final existing =
        await (_db.select(_db.prayerLogEntries)
              ..where((table) => table.date.equals(dateKey))
              ..where((table) => table.prayer.equals(draft.prayer.name)))
            .getSingleOrNull();

    final companion = PrayerLogEntriesCompanion(
      date: Value(dateKey),
      prayer: Value(draft.prayer.name),
      status: Value(draft.status.name),
      mosqueId: Value(draft.mosqueId),
      notes: Value(_nullIfBlank(draft.notes)),
      loggedAt: Value(DateTime.now().toUtc().toIso8601String()),
    );

    if (existing == null) {
      await _db.into(_db.prayerLogEntries).insert(companion);
      return;
    }

    await (_db.update(
      _db.prayerLogEntries,
    )..where((table) => table.id.equals(existing.id))).write(companion);
  }

  Future<void> clear({
    required DateTime date,
    required SalahPrayer prayer,
  }) async {
    await (_db.delete(_db.prayerLogEntries)
          ..where((table) => table.date.equals(formatDateKey(date)))
          ..where((table) => table.prayer.equals(prayer.name)))
        .go();
  }

  Future<void> resetAll() async {
    await (_db.delete(_db.prayerLogEntries)).go();
  }

  PrayerLogRecord _toDomain(PrayerLogEntry row) {
    return PrayerLogRecord(
      id: row.id,
      date: parseDateKey(row.date),
      prayer: _prayerFromStorage(row.prayer),
      status: _statusFromStorage(row.status),
      mosqueId: row.mosqueId,
      notes: row.notes,
      loggedAt: DateTime.parse(row.loggedAt).toLocal(),
    );
  }

  SalahPrayer _prayerFromStorage(String value) {
    return SalahPrayer.values.firstWhere(
      (candidate) => candidate.name == value,
      orElse: () => SalahPrayer.fajr,
    );
  }

  PrayerLogStatus _statusFromStorage(String value) {
    return PrayerLogStatus.values.firstWhere(
      (candidate) => candidate.name == value,
      orElse: () => PrayerLogStatus.alone,
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
