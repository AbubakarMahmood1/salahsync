import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:salahsync/core/mosque/month_day.dart';
import 'package:salahsync/core/mosque/time_of_day_value.dart';
import 'package:salahsync/core/mosque/timing_rule.dart';
import 'package:salahsync/core/time/salah_prayer.dart';
import 'package:salahsync/data/db/app_database.dart';
import 'package:salahsync/data/models/mosque_draft.dart';
import 'package:salahsync/data/models/timing_rule_draft.dart';
import 'package:salahsync/data/repositories/mosque_repository.dart';
import 'package:salahsync/data/repositories/timing_rule_repository.dart';

void main() {
  late AppDatabase database;
  late MosqueRepository mosqueRepository;
  late TimingRuleRepository repository;
  late int mosqueId;

  setUp(() async {
    database = AppDatabase(NativeDatabase.memory());
    mosqueRepository = MosqueRepository(database);
    repository = TimingRuleRepository(database);
    mosqueId = await mosqueRepository.save(const MosqueDraft(name: 'Masjid A'));
  });

  tearDown(() async {
    await database.close();
  });

  test('stores and maps timing rules for a mosque', () async {
    await repository.save(
      TimingRuleDraft(
        mosqueId: mosqueId,
        prayer: SalahPrayer.fajr,
        mode: TimingRuleMode.offset,
        offsetMinutes: 10,
      ),
    );

    await repository.save(
      TimingRuleDraft(
        mosqueId: mosqueId,
        prayer: SalahPrayer.maghrib,
        mode: TimingRuleMode.fixed,
        fixedTime: const TimeOfDayValue(hour: 18, minute: 30),
      ),
    );

    final rules = await repository.listDomainForMosque(mosqueId);

    expect(rules, hasLength(2));
    expect(rules.first.prayer, SalahPrayer.fajr);
    expect(rules.last.prayer, SalahPrayer.maghrib);
  });

  test(
    'rejects overlapping date-range rules for the same mosque prayer',
    () async {
      await repository.save(
        TimingRuleDraft(
          mosqueId: mosqueId,
          prayer: SalahPrayer.isha,
          mode: TimingRuleMode.dateRangeFixed,
          fixedTime: const TimeOfDayValue(hour: 20, minute: 30),
          rangeStart: const MonthDay(month: 5, day: 1),
          rangeEnd: const MonthDay(month: 8, day: 31),
        ),
      );

      expect(
        () => repository.save(
          TimingRuleDraft(
            mosqueId: mosqueId,
            prayer: SalahPrayer.isha,
            mode: TimingRuleMode.dateRangeFixed,
            fixedTime: const TimeOfDayValue(hour: 20, minute: 0),
            rangeStart: const MonthDay(month: 8, day: 15),
            rangeEnd: const MonthDay(month: 10, day: 1),
          ),
        ),
        throwsA(isA<TimingRuleValidationException>()),
      );
    },
  );

  test('updating a timing rule preserves createdAt', () async {
    final ruleId = await repository.save(
      TimingRuleDraft(
        mosqueId: mosqueId,
        prayer: SalahPrayer.maghrib,
        mode: TimingRuleMode.fixed,
        fixedTime: const TimeOfDayValue(hour: 18, minute: 30),
      ),
    );

    final original = (await repository.listForMosque(
      mosqueId,
    )).singleWhere((rule) => rule.id == ruleId);

    await repository.save(
      TimingRuleDraft(
        id: ruleId,
        mosqueId: mosqueId,
        prayer: SalahPrayer.maghrib,
        mode: TimingRuleMode.fixed,
        fixedTime: const TimeOfDayValue(hour: 18, minute: 45),
      ),
    );

    final updated = (await repository.listForMosque(
      mosqueId,
    )).singleWhere((rule) => rule.id == ruleId);

    expect(updated.createdAt, original.createdAt);
    expect(updated.fixedTime!.hour, 18);
    expect(updated.fixedTime!.minute, 45);
  });

  test('rejects mode drafts that omit required timing data', () async {
    expect(
      () => repository.save(
        TimingRuleDraft(
          mosqueId: mosqueId,
          prayer: SalahPrayer.fajr,
          mode: TimingRuleMode.offset,
        ),
      ),
      throwsA(isA<TimingRuleValidationException>()),
    );

    expect(
      () => repository.save(
        TimingRuleDraft(
          mosqueId: mosqueId,
          prayer: SalahPrayer.jummah,
          mode: TimingRuleMode.fixed,
        ),
      ),
      throwsA(isA<TimingRuleValidationException>()),
    );
  });
}
