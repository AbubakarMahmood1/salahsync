import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz;

import 'package:salahsync/core/time/salah_prayer.dart';
import 'package:salahsync/data/db/app_database.dart';
import 'package:salahsync/data/models/mosque_draft.dart';
import 'package:salahsync/data/repositories/mosque_repository.dart';
import 'package:salahsync/data/repositories/settings_repository.dart';
import 'package:salahsync/data/repositories/timing_rule_repository.dart';
import 'package:salahsync/data/seeding/app_seed_service.dart';
import 'package:salahsync/data/services/mosque_schedule_read_service.dart';

void main() {
  late AppDatabase database;
  late MosqueRepository mosqueRepository;
  late TimingRuleRepository timingRuleRepository;
  late SettingsRepository settingsRepository;
  late AppSeedService seedService;

  setUpAll(() {
    tz.initializeTimeZones();
  });

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    mosqueRepository = MosqueRepository(database);
    timingRuleRepository = TimingRuleRepository(database);
    settingsRepository = SettingsRepository(database);
    seedService = AppSeedService(
      mosqueRepository: mosqueRepository,
      timingRuleRepository: timingRuleRepository,
      settingsRepository: settingsRepository,
    );
  });

  tearDown(() async {
    await database.close();
  });

  test(
    'seedIfEmpty inserts one primary mosque and its example timing rules',
    () async {
      await seedService.seedIfEmpty();

      final mosques = await mosqueRepository.getAll();
      final rules = await timingRuleRepository.listForMosque(mosques.single.id);

      expect(mosques, hasLength(1));
      expect(mosques.single.isPrimary, isTrue);
      expect(rules, hasLength(10));

      await seedService.seedIfEmpty();
      expect(await mosqueRepository.getAll(), hasLength(1));
    },
  );

  test(
    'resetAndReseed restores the example mosque and settings defaults',
    () async {
      await seedService.seedIfEmpty();

      await mosqueRepository.save(
        const MosqueDraft(name: 'Masjid Extra', isPrimary: true),
      );
      await settingsRepository.put('theme_mode', 'dark');

      await seedService.resetAndReseed();

      final mosques = await mosqueRepository.getAll();
      final settings = await settingsRepository.getAll();

      expect(mosques, hasLength(1));
      expect(mosques.single.name, 'Masjid Al-Noor');
      expect(settings['theme_mode'], 'system');
    },
  );

  test(
    'buildHomeSchedule uses Jummah on Friday and seeded rule data',
    () async {
      await seedService.seedIfEmpty();

      final config = await settingsRepository.loadPrayerCalculationConfig();
      final primaryMosque = (await mosqueRepository.getPrimary())!;
      final rules = await timingRuleRepository.listDomainForMosque(
        primaryMosque.id,
      );

      final readModel = const MosqueScheduleReadService().buildHomeSchedule(
        date: DateTime(2026, 3, 20),
        config: config,
        primaryMosque: primaryMosque,
        rules: rules,
      );

      expect(readModel.displayPrayers, contains(SalahPrayer.jummah));
      expect(readModel.displayPrayers, isNot(contains(SalahPrayer.dhuhr)));
      expect(
        _hhmm(readModel.resolvedJamaatTimes[SalahPrayer.jummah]!.dateTime),
        '13:30',
      );
    },
  );
}

String _hhmm(DateTime value) {
  final hour = value.hour.toString().padLeft(2, '0');
  final minute = value.minute.toString().padLeft(2, '0');
  return '$hour:$minute';
}
