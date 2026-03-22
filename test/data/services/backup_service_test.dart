import 'dart:convert';

import 'package:drift/drift.dart' show Value, driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz;

import 'package:salahsync/core/notifications/notification_preferences.dart';
import 'package:salahsync/core/settings/app_theme_mode.dart';
import 'package:salahsync/core/time/timezone_name.dart';
import 'package:salahsync/data/db/app_database.dart';
import 'package:salahsync/data/models/mosque_draft.dart';
import 'package:salahsync/data/repositories/mosque_repository.dart';
import 'package:salahsync/data/repositories/settings_repository.dart';
import 'package:salahsync/data/repositories/timing_rule_repository.dart';
import 'package:salahsync/data/seeding/app_seed_service.dart';
import 'package:salahsync/data/services/backup_service.dart';

void main() {
  late AppDatabase sourceDatabase;
  late AppDatabase destinationDatabase;
  late BackupService sourceBackupService;
  late BackupService destinationBackupService;
  late SettingsRepository sourceSettingsRepository;
  late MosqueRepository sourceMosqueRepository;
  late TimingRuleRepository sourceTimingRuleRepository;
  late AppSeedService seedService;

  setUpAll(() {
    tz.initializeTimeZones();
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  });

  tearDownAll(() {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = false;
  });

  setUp(() {
    sourceDatabase = AppDatabase(NativeDatabase.memory());
    destinationDatabase = AppDatabase(NativeDatabase.memory());
    sourceBackupService = BackupService(sourceDatabase);
    destinationBackupService = BackupService(destinationDatabase);
    sourceSettingsRepository = SettingsRepository(sourceDatabase);
    sourceMosqueRepository = MosqueRepository(sourceDatabase);
    sourceTimingRuleRepository = TimingRuleRepository(sourceDatabase);
    seedService = AppSeedService(
      mosqueRepository: sourceMosqueRepository,
      timingRuleRepository: sourceTimingRuleRepository,
      settingsRepository: sourceSettingsRepository,
    );
  });

  tearDown(() async {
    await sourceDatabase.close();
    await destinationDatabase.close();
  });

  test('exportToJson and importFromJson round-trip the drift schema', () async {
    await seedService.seedIfEmpty();
    await sourceSettingsRepository.saveThemeMode(AppThemeMode.dark);
    await sourceSettingsRepository.saveNotificationPreferences(
      NotificationPreferences.defaults().copyWith(
        sehriEnabled: true,
        iftarEnabled: true,
      ),
    );

    final primaryMosque = (await sourceMosqueRepository.getPrimary())!;
    await sourceMosqueRepository.save(
      MosqueDraft(
        id: primaryMosque.id,
        name: primaryMosque.name,
        area: primaryMosque.area,
        latitude: primaryMosque.latitude,
        longitude: primaryMosque.longitude,
        isPrimary: primaryMosque.isPrimary,
        isActive: primaryMosque.isActive,
        notes: 'سلام backup test',
      ),
    );

    final taskId = await sourceDatabase
        .into(sourceDatabase.ibadahTaskEntries)
        .insert(
          const IbadahTaskEntriesCompanion(
            title: Value('Morning Adhkar'),
            description: Value('Read after Fajr'),
            prayerLink: Value('fajr'),
            timing: Value('after'),
            repeatType: Value('daily'),
            repeatDays: Value('["mon","thu"]'),
            countTarget: Value(100),
            isActive: Value(true),
            sortOrder: Value(1),
          ),
        );
    await sourceDatabase
        .into(sourceDatabase.ibadahCompletionEntries)
        .insert(
          IbadahCompletionEntriesCompanion(
            taskId: Value(taskId),
            date: const Value('2026-03-22'),
            prayerInstance: const Value('fajr'),
            countDone: const Value(67),
            completed: const Value(false),
            notes: const Value('Half way'),
          ),
        );
    await sourceDatabase
        .into(sourceDatabase.prayerLogEntries)
        .insert(
          PrayerLogEntriesCompanion(
            date: const Value('2026-03-22'),
            prayer: const Value('fajr'),
            status: const Value('jamaat'),
            mosqueId: Value(primaryMosque.id),
            notes: const Value('On time'),
            loggedAt: const Value('2026-03-22T05:20:00Z'),
          ),
        );

    final json = await sourceBackupService.exportToJson(pretty: true);
    final preview = sourceBackupService.previewJson(json);
    final importResult = await destinationBackupService.importFromJson(json);

    final importedSettings = await SettingsRepository(
      destinationDatabase,
    ).getAll();
    final importedThemeMode = await SettingsRepository(
      destinationDatabase,
    ).loadThemeMode();
    final importedMosques = await MosqueRepository(
      destinationDatabase,
    ).getAll();
    final importedRules = await TimingRuleRepository(
      destinationDatabase,
    ).listForMosque(importedMosques.single.id);
    final importedTasks = await destinationDatabase
        .select(destinationDatabase.ibadahTaskEntries)
        .get();
    final importedCompletions = await destinationDatabase
        .select(destinationDatabase.ibadahCompletionEntries)
        .get();
    final importedPrayerLogs = await destinationDatabase
        .select(destinationDatabase.prayerLogEntries)
        .get();

    expect(preview.backupSchemaVersion, kBackupSchemaVersion);
    expect(preview.summary.mosqueCount, 1);
    expect(importResult.summary.timingRuleCount, 10);
    expect(importedThemeMode, AppThemeMode.dark);
    expect(importedSettings['notification_prefs'], isNotNull);
    expect(importedMosques.single.notes, 'سلام backup test');
    expect(importedRules, hasLength(10));
    expect(importedTasks.single.title, 'Morning Adhkar');
    expect(importedCompletions.single.countDone, 67);
    expect(importedPrayerLogs.single.status, 'jamaat');
  });

  test('previewJson rejects unsupported backup schema versions', () async {
    final payload = jsonEncode({
      'backupSchemaVersion': 99,
      'databaseSchemaVersion': 2,
      'exportedAt': '2026-03-22T00:00:00Z',
      'data': {
        'appSettingsEntries': <Object>[],
        'mosques': <Object>[],
        'timingRuleEntries': <Object>[],
        'ibadahTaskEntries': <Object>[],
        'ibadahCompletionEntries': <Object>[],
        'prayerLogEntries': <Object>[],
      },
    });

    expect(
      () => sourceBackupService.previewJson(payload),
      throwsA(isA<BackupFormatException>()),
    );
  });

  test('previewJson rejects oversized payloads', () {
    final payload = jsonEncode({
      'backupSchemaVersion': 1,
      'databaseSchemaVersion': 2,
      'exportedAt': '2026-03-22T00:00:00Z',
      'padding': 'a' * kMaxBackupCharacters,
      'data': {
        'appSettingsEntries': <Object>[],
        'mosques': <Object>[],
        'timingRuleEntries': <Object>[],
        'ibadahTaskEntries': <Object>[],
        'ibadahCompletionEntries': <Object>[],
        'prayerLogEntries': <Object>[],
      },
    });

    expect(
      () => sourceBackupService.previewJson(payload),
      throwsA(isA<BackupFormatException>()),
    );
  });

  test(
    'imported backups with invalid timezone values fall back safely',
    () async {
      await seedService.seedIfEmpty();

      final decoded =
          jsonDecode(await sourceBackupService.exportToJson())
              as Map<String, dynamic>;
      final data = decoded['data'] as Map<String, dynamic>;
      final settingsRows = (data['appSettingsEntries'] as List<dynamic>)
          .cast<Map<String, dynamic>>();
      final coordinatesRow = settingsRows.firstWhere(
        (row) => row['key'] == 'default_coordinates',
      );
      final coordinatesPayload =
          jsonDecode(coordinatesRow['value'] as String) as Map<String, dynamic>;
      coordinatesPayload['timezoneName'] = 'Mars/Olympus';
      coordinatesRow['value'] = jsonEncode(coordinatesPayload);

      await destinationBackupService.importFromJson(jsonEncode(decoded));
      final loadedConfig = await SettingsRepository(
        destinationDatabase,
      ).loadPrayerCalculationConfig();

      expect(loadedConfig.timezoneName, kDefaultTimezoneName);
    },
  );
}
