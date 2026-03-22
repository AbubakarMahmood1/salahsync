import 'package:drift/drift.dart';

import '../db/app_database.dart';
import '../models/mosque_draft.dart';

class MosqueRepository {
  MosqueRepository(this._db);

  final AppDatabase _db;

  Future<List<Mosque>> getAll({bool activeOnly = false}) {
    final query = _db.select(_db.mosques)
      ..orderBy([
        (table) =>
            OrderingTerm(expression: table.isPrimary, mode: OrderingMode.desc),
        (table) => OrderingTerm(expression: table.name),
      ]);

    if (activeOnly) {
      query.where((table) => table.isActive.equals(true));
    }

    return query.get();
  }

  Stream<List<Mosque>> watchAll({bool activeOnly = false}) {
    final query = _db.select(_db.mosques)
      ..orderBy([
        (table) =>
            OrderingTerm(expression: table.isPrimary, mode: OrderingMode.desc),
        (table) => OrderingTerm(expression: table.name),
      ]);

    if (activeOnly) {
      query.where((table) => table.isActive.equals(true));
    }

    return query.watch();
  }

  Future<Mosque?> getPrimary() {
    return (_db.select(_db.mosques)
          ..where((table) => table.isPrimary.equals(true))
          ..limit(1))
        .getSingleOrNull();
  }

  Stream<Mosque?> watchPrimary() {
    return (_db.select(_db.mosques)
          ..where((table) => table.isPrimary.equals(true))
          ..limit(1))
        .watchSingleOrNull();
  }

  Future<Mosque?> getById(int id) {
    return (_db.select(
      _db.mosques,
    )..where((table) => table.id.equals(id))).getSingleOrNull();
  }

  Future<int> save(MosqueDraft draft) async {
    return _db.transaction(() async {
      final now = _nowIso();

      if (draft.isPrimary) {
        await _clearPrimary(exceptId: draft.id);
      }

      final companion = MosquesCompanion(
        name: Value(draft.name),
        area: Value(draft.area),
        latitude: Value(draft.latitude),
        longitude: Value(draft.longitude),
        isPrimary: Value(draft.isPrimary),
        isActive: Value(draft.isActive),
        notes: Value(draft.notes),
        updatedAt: Value(now),
      );

      int id;
      if (draft.id == null) {
        id = await _db
            .into(_db.mosques)
            .insert(companion.copyWith(createdAt: Value(now)));
      } else {
        final update = _db.update(_db.mosques)
          ..where((table) => table.id.equals(draft.id!));
        await update.write(companion);
        id = draft.id!;
      }

      await _ensureSingleActivePrimary();
      return id;
    });
  }

  Future<void> setPrimary(int mosqueId) async {
    await _db.transaction(() async {
      await _clearPrimary();
      await (_db.update(
        _db.mosques,
      )..where((table) => table.id.equals(mosqueId))).write(
        MosquesCompanion(
          isPrimary: const Value(true),
          updatedAt: Value(_nowIso()),
        ),
      );
      await _ensureSingleActivePrimary();
    });
  }

  Future<void> delete(int mosqueId) async {
    await _db.transaction(() async {
      await (_db.delete(
        _db.mosques,
      )..where((table) => table.id.equals(mosqueId))).go();
      await _ensureSingleActivePrimary();
    });
  }

  Future<void> resetAll() async {
    await (_db.delete(_db.mosques)).go();
  }

  Future<void> _clearPrimary({int? exceptId}) async {
    final update = _db.update(_db.mosques);
    if (exceptId != null) {
      update.where((table) => table.id.isNotValue(exceptId));
    }
    await update.write(const MosquesCompanion(isPrimary: Value(false)));
  }

  Future<void> _ensureSingleActivePrimary() async {
    final activeMosques = await getAll(activeOnly: true);
    if (activeMosques.isEmpty) {
      return;
    }

    final activePrimary = activeMosques
        .where((mosque) => mosque.isPrimary)
        .toList();
    if (activePrimary.length == 1) {
      return;
    }

    final primaryId = activePrimary.isNotEmpty
        ? activePrimary.first.id
        : activeMosques.first.id;

    await _clearPrimary();
    await (_db.update(
      _db.mosques,
    )..where((table) => table.id.equals(primaryId))).write(
      MosquesCompanion(
        isPrimary: const Value(true),
        updatedAt: Value(_nowIso()),
      ),
    );
  }

  String _nowIso() => DateTime.now().toUtc().toIso8601String();
}
