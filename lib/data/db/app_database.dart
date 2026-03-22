import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../core/mosque/month_day.dart';
import '../../core/mosque/time_of_day_value.dart';
import '../../core/mosque/timing_rule.dart';
import '../../core/time/salah_prayer.dart';
import 'converters/month_day_converter.dart';
import 'converters/time_of_day_value_converter.dart';
import 'tables/app_settings_entries.dart';
import 'tables/ibadah_completion_entries.dart';
import 'tables/ibadah_task_entries.dart';
import 'tables/mosques.dart';
import 'tables/prayer_log_entries.dart';
import 'tables/timing_rule_entries.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    AppSettingsEntries,
    IbadahCompletionEntries,
    IbadahTaskEntries,
    Mosques,
    PrayerLogEntries,
    TimingRuleEntries,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.executor);

  AppDatabase.local() : super(_openConnection());

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
    },
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await _migrateAppSettingsTable(m);
      }

      await _createMissingTables(m);
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
      await _ensureSupplementalIndexes();
    },
  );

  Future<void> _migrateAppSettingsTable(Migrator m) async {
    if (!await _tableExists('app_settings_entries')) {
      await m.createTable(appSettingsEntries);
      return;
    }

    if (!await _columnExists('app_settings_entries', 'updated_at')) {
      return;
    }

    await customStatement(
      'ALTER TABLE app_settings_entries RENAME TO app_settings_entries_v1',
    );
    await m.createTable(appSettingsEntries);
    await customStatement(
      'INSERT INTO app_settings_entries (key, value) '
      'SELECT key, value FROM app_settings_entries_v1',
    );
    await customStatement('DROP TABLE app_settings_entries_v1');
  }

  Future<void> _createMissingTables(Migrator m) async {
    if (!await _tableExists('app_settings_entries')) {
      await m.createTable(appSettingsEntries);
    }
    if (!await _tableExists('ibadah_completion_entries')) {
      await m.createTable(ibadahCompletionEntries);
    }
    if (!await _tableExists('ibadah_task_entries')) {
      await m.createTable(ibadahTaskEntries);
    }
    if (!await _tableExists('mosques')) {
      await m.createTable(mosques);
    }
    if (!await _tableExists('prayer_log_entries')) {
      await m.createTable(prayerLogEntries);
    }
    if (!await _tableExists('timing_rule_entries')) {
      await m.createTable(timingRuleEntries);
    }
  }

  Future<void> _ensureSupplementalIndexes() async {
    await customStatement(
      'CREATE UNIQUE INDEX IF NOT EXISTS '
      'uq_ibadah_completion_entries_task_date_prayer_instance '
      'ON ibadah_completion_entries '
      "(task_id, date, ifnull(prayer_instance, ''))",
    );
  }

  Future<bool> _tableExists(String tableName) async {
    final rows = await customSelect(
      'SELECT name FROM sqlite_master WHERE type = ? AND name = ?',
      variables: [const Variable<String>('table'), Variable<String>(tableName)],
    ).get();
    return rows.isNotEmpty;
  }

  Future<bool> _columnExists(String tableName, String columnName) async {
    final rows = await customSelect('PRAGMA table_info($tableName)').get();
    return rows.any((row) => row.read<String>('name') == columnName);
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final directory = await getApplicationSupportDirectory();
    final file = File(p.join(directory.path, 'salahsync.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
