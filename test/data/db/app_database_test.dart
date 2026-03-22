import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
// ignore: depend_on_referenced_packages
import 'package:sqlite3/sqlite3.dart';

import 'package:salahsync/data/db/app_database.dart';

void main() {
  group('AppDatabase', () {
    test('migrates v1 app settings rows without losing values', () async {
      final directory = await Directory.systemTemp.createTemp(
        'salahsync_migration_test_',
      );
      final file = File('${directory.path}${Platform.pathSeparator}app.sqlite');

      final legacyDb = sqlite3.open(file.path);
      legacyDb.execute('PRAGMA user_version = 1;');
      legacyDb.execute(
        'CREATE TABLE app_settings_entries ('
        'key TEXT NOT NULL PRIMARY KEY, '
        'value TEXT NOT NULL, '
        'updated_at TEXT NOT NULL'
        ')',
      );
      legacyDb.execute(
        "INSERT INTO app_settings_entries (key, value, updated_at) "
        "VALUES ('theme_mode', 'dark', '2026-03-22T00:00:00Z')",
      );
      legacyDb.close();

      final database = AppDatabase(NativeDatabase(file));
      addTearDown(() async {
        await database.close();
        await directory.delete(recursive: true);
      });

      final settings = await database.select(database.appSettingsEntries).get();
      final columns = await database
          .customSelect('PRAGMA table_info(app_settings_entries)')
          .get();
      final tables = await database
          .customSelect("SELECT name FROM sqlite_master WHERE type = 'table'")
          .get();

      expect(settings, hasLength(1));
      expect(settings.single.key, 'theme_mode');
      expect(settings.single.value, 'dark');
      expect(
        columns.map((row) => row.read<String>('name')),
        isNot(contains('updated_at')),
      );
      expect(
        tables.map((row) => row.read<String>('name')),
        containsAll([
          'app_settings_entries',
          'mosques',
          'timing_rule_entries',
          'ibadah_task_entries',
          'ibadah_completion_entries',
          'prayer_log_entries',
        ]),
      );
    });

    test(
      'ibadah completion uniqueness treats null prayer_instance as one logical slot',
      () async {
        final database = AppDatabase(NativeDatabase.memory());
        addTearDown(database.close);

        final taskId = await database
            .into(database.ibadahTaskEntries)
            .insert(
              IbadahTaskEntriesCompanion.insert(
                title: 'Ayat al-Kursi',
                repeatType: 'daily',
              ),
            );

        await database
            .into(database.ibadahCompletionEntries)
            .insert(
              IbadahCompletionEntriesCompanion.insert(
                taskId: taskId,
                date: '2026-03-22',
              ),
            );

        expect(
          () => database
              .into(database.ibadahCompletionEntries)
              .insert(
                IbadahCompletionEntriesCompanion.insert(
                  taskId: taskId,
                  date: '2026-03-22',
                ),
              ),
          throwsA(isA<SqliteException>()),
        );
      },
    );

    test('prayer log enforces one row per date and prayer', () async {
      final database = AppDatabase(NativeDatabase.memory());
      addTearDown(database.close);

      await database
          .into(database.prayerLogEntries)
          .insert(
            PrayerLogEntriesCompanion.insert(
              date: '2026-03-22',
              prayer: 'fajr',
              status: 'alone',
              loggedAt: '2026-03-22T00:00:00Z',
            ),
          );

      expect(
        () => database
            .into(database.prayerLogEntries)
            .insert(
              PrayerLogEntriesCompanion.insert(
                date: '2026-03-22',
                prayer: 'fajr',
                status: 'jamaat',
                loggedAt: '2026-03-22T00:10:00Z',
              ),
            ),
        throwsA(isA<SqliteException>()),
      );
    });
  });
}
