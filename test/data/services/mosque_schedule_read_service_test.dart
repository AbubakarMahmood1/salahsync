import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz;

import 'package:salahsync/core/mosque/time_of_day_value.dart';
import 'package:salahsync/core/mosque/timing_rule.dart';
import 'package:salahsync/core/time/prayer_calculation_config.dart';
import 'package:salahsync/core/time/prayer_time_service.dart';
import 'package:salahsync/core/time/salah_prayer.dart';
import 'package:salahsync/data/db/app_database.dart';
import 'package:salahsync/data/models/mosque_draft.dart';
import 'package:salahsync/data/models/timing_rule_draft.dart';
import 'package:salahsync/data/repositories/mosque_repository.dart';
import 'package:salahsync/data/repositories/timing_rule_repository.dart';
import 'package:salahsync/data/services/mosque_schedule_read_service.dart';

void main() {
  late AppDatabase database;
  late MosqueRepository mosqueRepository;
  late TimingRuleRepository timingRuleRepository;
  late MosqueScheduleReadService service;

  setUpAll(() {
    tz.initializeTimeZones();
  });

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    mosqueRepository = MosqueRepository(database);
    timingRuleRepository = TimingRuleRepository(database);
    service = const MosqueScheduleReadService();
  });

  tearDown(() async {
    await database.close();
  });

  test(
    'comparison schedules include active mosques only and use each mosque rules',
    () async {
      final firstMosqueId = await mosqueRepository.save(
        const MosqueDraft(name: 'Masjid A', isPrimary: true),
      );
      final secondMosqueId = await mosqueRepository.save(
        const MosqueDraft(name: 'Masjid B'),
      );
      final inactiveMosqueId = await mosqueRepository.save(
        const MosqueDraft(name: 'Masjid C', isActive: false),
      );

      await timingRuleRepository.save(
        TimingRuleDraft(
          mosqueId: firstMosqueId,
          prayer: SalahPrayer.fajr,
          mode: TimingRuleMode.offset,
          offsetMinutes: 10,
        ),
      );
      await timingRuleRepository.save(
        TimingRuleDraft(
          mosqueId: secondMosqueId,
          prayer: SalahPrayer.fajr,
          mode: TimingRuleMode.fixed,
          fixedTime: const TimeOfDayValue(hour: 5, minute: 45),
        ),
      );
      await timingRuleRepository.save(
        TimingRuleDraft(
          mosqueId: inactiveMosqueId,
          prayer: SalahPrayer.fajr,
          mode: TimingRuleMode.fixed,
          fixedTime: const TimeOfDayValue(hour: 5, minute: 55),
        ),
      );

      final mosques = await mosqueRepository.getAll();
      final rulesByMosque = <int, List<TimingRule>>{
        for (final mosque in mosques)
          mosque.id: await timingRuleRepository.listDomainForMosque(mosque.id),
      };

      final config = PrayerCalculationConfig.khanewalDefault();
      final expectedFirstFajr = const PrayerTimeService()
          .calculateDay(date: DateTime(2026, 3, 20), config: config)
          .timeOf(SalahPrayer.fajr)
          .add(const Duration(minutes: 10));

      final result = service.buildComparisonSchedules(
        date: DateTime(2026, 3, 20),
        config: config,
        mosques: mosques,
        rulesByMosque: rulesByMosque,
      );

      expect(result.map((entry) => entry.mosque.name), [
        'Masjid A',
        'Masjid B',
      ]);
      expect(result.first.displayPrayers, contains(SalahPrayer.jummah));
      expect(result.first.displayPrayers, isNot(contains(SalahPrayer.dhuhr)));
      expect(
        _hhmm(result.first.resolvedJamaatTimes[SalahPrayer.fajr]!.dateTime),
        _hhmm(expectedFirstFajr),
      );
      expect(
        _hhmm(result[1].resolvedJamaatTimes[SalahPrayer.fajr]!.dateTime),
        '05:45',
      );
    },
  );
}

String _hhmm(DateTime value) {
  final hour = value.hour.toString().padLeft(2, '0');
  final minute = value.minute.toString().padLeft(2, '0');
  return '$hour:$minute';
}
