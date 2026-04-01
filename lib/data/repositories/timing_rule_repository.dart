import 'package:drift/drift.dart';

import '../db/app_database.dart';
import '../models/timing_rule_draft.dart';
import '../../core/mosque/timing_rule.dart';
import '../../core/mosque/timing_rule_resolver.dart';

class TimingRuleRepository {
  TimingRuleRepository(this._db);

  final AppDatabase _db;
  final TimingRuleResolver _resolver = const TimingRuleResolver();

  Future<List<TimingRuleEntry>> listForMosque(int mosqueId) {
    return (_db.select(_db.timingRuleEntries)
          ..where((table) => table.mosqueId.equals(mosqueId))
          ..orderBy([
            (table) => OrderingTerm(expression: table.prayer),
            (table) => OrderingTerm(
              expression: table.priority,
              mode: OrderingMode.desc,
            ),
            (table) => OrderingTerm(expression: table.id),
          ]))
        .get();
  }

  Future<List<TimingRuleEntry>> listForMosques(Iterable<int> mosqueIds) {
    if (mosqueIds.isEmpty) {
      return Future.value(const <TimingRuleEntry>[]);
    }

    return (_db.select(
      _db.timingRuleEntries,
    )..where((table) => table.mosqueId.isIn(mosqueIds.toList()))).get();
  }

  Future<List<TimingRule>> listDomainForMosque(int mosqueId) async {
    final rows = await listForMosque(mosqueId);
    return rows.map(_toDomain).toList();
  }

  Future<Map<int, List<TimingRule>>> listDomainForMosques(
    Iterable<int> mosqueIds,
  ) async {
    final ids = mosqueIds.toList(growable: false);
    if (ids.isEmpty) {
      return const <int, List<TimingRule>>{};
    }

    final rows = await listForMosques(ids);
    final grouped = <int, List<TimingRule>>{
      for (final mosqueId in ids) mosqueId: <TimingRule>[],
    };
    for (final row in rows) {
      grouped
          .putIfAbsent(row.mosqueId, () => <TimingRule>[])
          .add(_toDomain(row));
    }
    return grouped;
  }

  Future<int> save(TimingRuleDraft draft) async {
    return _db.transaction(() async {
      _validateDraft(draft);
      await _validateNoOverlap(draft);

      if (draft.id == null) {
        return _db
            .into(_db.timingRuleEntries)
            .insert(
              TimingRuleEntriesCompanion(
                mosqueId: Value(draft.mosqueId),
                prayer: Value(draft.prayer),
                mode: Value(draft.mode),
                offsetMinutes: Value(draft.offsetMinutes),
                fixedTime: Value(draft.fixedTime),
                rangeStart: Value(draft.rangeStart),
                rangeEnd: Value(draft.rangeEnd),
                priority: Value(draft.priority),
                createdAt: Value(_nowIso()),
              ),
            );
      }

      final existing = await (_db.select(
        _db.timingRuleEntries,
      )..where((table) => table.id.equals(draft.id!))).getSingleOrNull();
      if (existing == null) {
        throw TimingRuleValidationException(
          'Cannot update missing timing rule ${draft.id}',
        );
      }

      await (_db.update(
        _db.timingRuleEntries,
      )..where((table) => table.id.equals(draft.id!))).write(
        TimingRuleEntriesCompanion(
          mosqueId: Value(draft.mosqueId),
          prayer: Value(draft.prayer),
          mode: Value(draft.mode),
          offsetMinutes: Value(draft.offsetMinutes),
          fixedTime: Value(draft.fixedTime),
          rangeStart: Value(draft.rangeStart),
          rangeEnd: Value(draft.rangeEnd),
          priority: Value(draft.priority),
          createdAt: Value(existing.createdAt),
        ),
      );
      return draft.id!;
    });
  }

  Future<void> delete(int ruleId) async {
    await (_db.delete(
      _db.timingRuleEntries,
    )..where((table) => table.id.equals(ruleId))).go();
  }

  Future<void> resetAll() async {
    await (_db.delete(_db.timingRuleEntries)).go();
  }

  Future<void> _validateNoOverlap(TimingRuleDraft draft) async {
    if (draft.mode != TimingRuleMode.dateRangeFixed) {
      return;
    }

    try {
      final existing = (await listForMosque(draft.mosqueId))
          .where(
            (rule) =>
                rule.id != draft.id &&
                rule.prayer == draft.prayer &&
                rule.mode == TimingRuleMode.dateRangeFixed,
          )
          .map(_toDomain)
          .toList();

      final candidate = TimingRule.dateRangeFixed(
        id: draft.id,
        prayer: draft.prayer,
        fixedTime: draft.fixedTime!,
        rangeStart: draft.rangeStart!,
        rangeEnd: draft.rangeEnd!,
        priority: draft.priority,
      );

      final conflicts = _resolver.findDateRangeConflicts([
        ...existing,
        candidate,
      ]);
      if (conflicts.isNotEmpty) {
        throw TimingRuleValidationException(
          'Overlapping date-range rule for ${draft.prayer.name}',
        );
      }
    } on FormatException catch (_) {
      throw TimingRuleValidationException(
        'Date-range rules must use real calendar dates in MM-DD format',
      );
    } on StateError catch (_) {
      throw TimingRuleValidationException(
        'Date-range rules must use real calendar dates in MM-DD format',
      );
    }
  }

  void _validateDraft(TimingRuleDraft draft) {
    switch (draft.mode) {
      case TimingRuleMode.offset:
        if (draft.offsetMinutes == null) {
          throw TimingRuleValidationException(
            'Offset rules require offsetMinutes',
          );
        }
        return;
      case TimingRuleMode.fixed:
        if (draft.fixedTime == null) {
          throw TimingRuleValidationException('Fixed rules require fixedTime');
        }
        return;
      case TimingRuleMode.dateRangeFixed:
        if (draft.fixedTime == null ||
            draft.rangeStart == null ||
            draft.rangeEnd == null) {
          throw TimingRuleValidationException(
            'Date-range rules require fixedTime, rangeStart, and rangeEnd',
          );
        }
        try {
          draft.rangeStart!.validate();
          draft.rangeEnd!.validate();
        } on FormatException catch (_) {
          throw TimingRuleValidationException(
            'Date-range rules must use real calendar dates in MM-DD format',
          );
        }
        return;
    }
  }

  TimingRule _toDomain(TimingRuleEntry row) {
    return switch (row.mode) {
      TimingRuleMode.offset => TimingRule.offset(
        id: row.id,
        prayer: row.prayer,
        offsetMinutes: row.offsetMinutes ?? 0,
        priority: row.priority,
      ),
      TimingRuleMode.fixed => TimingRule.fixed(
        id: row.id,
        prayer: row.prayer,
        fixedTime: row.fixedTime!,
        priority: row.priority,
      ),
      TimingRuleMode.dateRangeFixed => TimingRule.dateRangeFixed(
        id: row.id,
        prayer: row.prayer,
        fixedTime: row.fixedTime!,
        rangeStart: row.rangeStart!,
        rangeEnd: row.rangeEnd!,
        priority: row.priority,
      ),
    };
  }

  String _nowIso() => DateTime.now().toUtc().toIso8601String();
}

class TimingRuleValidationException implements Exception {
  TimingRuleValidationException(this.message);

  final String message;

  @override
  String toString() => 'TimingRuleValidationException: $message';
}
