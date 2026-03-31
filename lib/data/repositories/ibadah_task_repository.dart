import 'dart:convert';

import 'package:drift/drift.dart';

import '../../core/ibadah/ibadah_task_prayer_link.dart';
import '../../core/ibadah/ibadah_task_repeat_type.dart';
import '../../core/ibadah/ibadah_task_timing.dart';
import '../db/app_database.dart';
import '../models/ibadah_task.dart';
import '../models/ibadah_task_draft.dart';

class IbadahTaskRepository {
  IbadahTaskRepository(this._db);

  final AppDatabase _db;

  Future<List<IbadahTask>> getAll({bool activeOnly = false}) async {
    final query = _db.select(_db.ibadahTaskEntries)
      ..orderBy([
        (table) => OrderingTerm(expression: table.sortOrder),
        (table) => OrderingTerm(expression: table.id),
      ]);
    if (activeOnly) {
      query.where((table) => table.isActive.equals(true));
    }

    final rows = await query.get();
    return rows.map(_toDomain).toList(growable: false);
  }

  Stream<List<IbadahTask>> watchAll({bool activeOnly = false}) {
    final query = _db.select(_db.ibadahTaskEntries)
      ..orderBy([
        (table) => OrderingTerm(expression: table.sortOrder),
        (table) => OrderingTerm(expression: table.id),
      ]);
    if (activeOnly) {
      query.where((table) => table.isActive.equals(true));
    }

    return query.watch().map(
      (rows) => rows.map(_toDomain).toList(growable: false),
    );
  }

  Future<IbadahTask?> getById(int id) async {
    final row = await (_db.select(
      _db.ibadahTaskEntries,
    )..where((table) => table.id.equals(id))).getSingleOrNull();
    if (row == null) {
      return null;
    }
    return _toDomain(row);
  }

  Future<int> save(IbadahTaskDraft draft) async {
    _validateDraft(draft);
    final repeatDays = draft.repeatDays.toList()..sort();
    final companion = IbadahTaskEntriesCompanion(
      title: Value(draft.title.trim()),
      description: Value(_nullIfBlank(draft.description)),
      prayerLink: Value(draft.prayerLink.storageValue),
      timing: Value(draft.timing.name),
      repeatType: Value(draft.repeatType.name),
      repeatDays: Value(repeatDays.isEmpty ? null : jsonEncode(repeatDays)),
      countTarget: Value(
        draft.countTarget != null && draft.countTarget! > 0
            ? draft.countTarget
            : null,
      ),
      isActive: Value(draft.isActive),
      sortOrder: Value(draft.sortOrder),
    );

    if (draft.id == null) {
      return _db.into(_db.ibadahTaskEntries).insert(companion);
    }

    await (_db.update(
      _db.ibadahTaskEntries,
    )..where((table) => table.id.equals(draft.id!))).write(companion);
    return draft.id!;
  }

  Future<void> delete(int id) async {
    await (_db.delete(
      _db.ibadahTaskEntries,
    )..where((table) => table.id.equals(id))).go();
  }

  Future<void> resetAll() async {
    await (_db.delete(_db.ibadahTaskEntries)).go();
  }

  IbadahTask _toDomain(IbadahTaskEntry row) {
    return IbadahTask(
      id: row.id,
      title: row.title,
      description: row.description,
      prayerLink: prayerLinkFromStorage(row.prayerLink),
      timing: _timingFromStorage(row.timing),
      repeatType: _repeatTypeFromStorage(row.repeatType),
      repeatDays: _parseRepeatDays(row.repeatDays),
      countTarget: row.countTarget,
      isActive: row.isActive,
      sortOrder: row.sortOrder,
    );
  }

  void _validateDraft(IbadahTaskDraft draft) {
    if (draft.title.trim().isEmpty) {
      throw IbadahTaskValidationException('Title is required.');
    }
    if (draft.countTarget != null && draft.countTarget! < 1) {
      throw IbadahTaskValidationException('Count target must be at least 1.');
    }
    if (draft.repeatType.requiresDaySelection && draft.repeatDays.isEmpty) {
      throw IbadahTaskValidationException(
        'Select at least one weekday for this repeat pattern.',
      );
    }
    if (draft.repeatType == IbadahTaskRepeatType.weekly &&
        draft.repeatDays.length != 1) {
      throw IbadahTaskValidationException(
        'Weekly tasks must select exactly one weekday.',
      );
    }
  }

  IbadahTaskTiming _timingFromStorage(String value) {
    return switch (value) {
      'before' => IbadahTaskTiming.before,
      _ => IbadahTaskTiming.after,
    };
  }

  IbadahTaskRepeatType _repeatTypeFromStorage(String value) {
    return switch (value) {
      'weekly' => IbadahTaskRepeatType.weekly,
      'specificDays' => IbadahTaskRepeatType.specificDays,
      'afterEveryPrayer' => IbadahTaskRepeatType.afterEveryPrayer,
      'oneTime' => IbadahTaskRepeatType.oneTime,
      _ => IbadahTaskRepeatType.daily,
    };
  }

  Set<int> _parseRepeatDays(String? value) {
    if (value == null || value.isEmpty) {
      return const <int>{};
    }

    try {
      final decoded = jsonDecode(value);
      if (decoded is List) {
        return decoded
            .map((item) => int.tryParse(item.toString()))
            .whereType<int>()
            .where(
              (value) => value >= DateTime.monday && value <= DateTime.sunday,
            )
            .toSet();
      }
    } on FormatException {
      return const <int>{};
    }

    return const <int>{};
  }

  String? _nullIfBlank(String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) {
      return null;
    }
    return trimmed;
  }
}

class IbadahTaskValidationException implements Exception {
  IbadahTaskValidationException(this.message);

  final String message;

  @override
  String toString() => 'IbadahTaskValidationException: $message';
}
