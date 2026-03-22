import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:salahsync/data/db/app_database.dart';
import 'package:salahsync/data/models/mosque_draft.dart';
import 'package:salahsync/data/repositories/mosque_repository.dart';

void main() {
  late AppDatabase database;
  late MosqueRepository repository;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    repository = MosqueRepository(database);
  });

  tearDown(() async {
    await database.close();
  });

  test(
    'first saved mosque becomes primary even if draft is not primary',
    () async {
      final id = await repository.save(const MosqueDraft(name: 'Masjid A'));
      final primary = await repository.getPrimary();

      expect(primary, isNotNull);
      expect(primary!.id, id);
      expect(primary.isPrimary, isTrue);
    },
  );

  test('saving a new primary mosque demotes the previous primary', () async {
    final firstId = await repository.save(
      const MosqueDraft(name: 'Masjid A', isPrimary: true),
    );
    final secondId = await repository.save(
      const MosqueDraft(name: 'Masjid B', isPrimary: true),
    );

    final mosques = await repository.getAll();
    final first = mosques.firstWhere((mosque) => mosque.id == firstId);
    final second = mosques.firstWhere((mosque) => mosque.id == secondId);

    expect(first.isPrimary, isFalse);
    expect(second.isPrimary, isTrue);
  });

  test('deleting the primary mosque promotes another active mosque', () async {
    final firstId = await repository.save(
      const MosqueDraft(name: 'Masjid A', isPrimary: true),
    );
    final secondId = await repository.save(const MosqueDraft(name: 'Masjid B'));

    await repository.delete(firstId);
    final primary = await repository.getPrimary();

    expect(primary, isNotNull);
    expect(primary!.id, secondId);
  });
}
