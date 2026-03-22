import '../../core/mosque/month_day.dart';
import '../../core/mosque/time_of_day_value.dart';
import '../../core/mosque/timing_rule.dart';
import '../../core/time/salah_prayer.dart';
import '../models/mosque_draft.dart';
import '../models/timing_rule_draft.dart';
import '../repositories/mosque_repository.dart';
import '../repositories/settings_repository.dart';
import '../repositories/timing_rule_repository.dart';

class AppSeedService {
  AppSeedService({
    required MosqueRepository mosqueRepository,
    required TimingRuleRepository timingRuleRepository,
    required SettingsRepository settingsRepository,
  }) : _mosqueRepository = mosqueRepository,
       _timingRuleRepository = timingRuleRepository,
       _settingsRepository = settingsRepository;

  final MosqueRepository _mosqueRepository;
  final TimingRuleRepository _timingRuleRepository;
  final SettingsRepository _settingsRepository;

  Future<void> seedIfEmpty() async {
    await _settingsRepository.seedDefaults();
    final mosques = await _mosqueRepository.getAll();
    if (mosques.isNotEmpty) {
      return;
    }

    final mosqueId = await _mosqueRepository.save(
      const MosqueDraft(
        name: 'Masjid Al-Noor',
        area: 'Khanewal',
        latitude: 30.3017,
        longitude: 71.9321,
        isPrimary: true,
        isActive: true,
        notes: 'Seed mosque from Appendix B example data.',
      ),
    );

    for (final rule in _exampleRulesFor(mosqueId)) {
      await _timingRuleRepository.save(rule);
    }
  }

  List<TimingRuleDraft> _exampleRulesFor(int mosqueId) {
    return <TimingRuleDraft>[
      TimingRuleDraft(
        mosqueId: mosqueId,
        prayer: SalahPrayer.fajr,
        mode: TimingRuleMode.offset,
        offsetMinutes: 10,
      ),
      TimingRuleDraft(
        mosqueId: mosqueId,
        prayer: SalahPrayer.dhuhr,
        mode: TimingRuleMode.dateRangeFixed,
        fixedTime: const TimeOfDayValue(hour: 13, minute: 0),
        rangeStart: const MonthDay(month: 10, day: 1),
        rangeEnd: const MonthDay(month: 3, day: 31),
      ),
      TimingRuleDraft(
        mosqueId: mosqueId,
        prayer: SalahPrayer.dhuhr,
        mode: TimingRuleMode.dateRangeFixed,
        fixedTime: const TimeOfDayValue(hour: 13, minute: 30),
        rangeStart: const MonthDay(month: 4, day: 1),
        rangeEnd: const MonthDay(month: 9, day: 30),
      ),
      TimingRuleDraft(
        mosqueId: mosqueId,
        prayer: SalahPrayer.asr,
        mode: TimingRuleMode.offset,
        offsetMinutes: 15,
      ),
      TimingRuleDraft(
        mosqueId: mosqueId,
        prayer: SalahPrayer.maghrib,
        mode: TimingRuleMode.offset,
        offsetMinutes: 5,
      ),
      TimingRuleDraft(
        mosqueId: mosqueId,
        prayer: SalahPrayer.isha,
        mode: TimingRuleMode.dateRangeFixed,
        fixedTime: const TimeOfDayValue(hour: 20, minute: 30),
        rangeStart: const MonthDay(month: 5, day: 1),
        rangeEnd: const MonthDay(month: 8, day: 31),
      ),
      TimingRuleDraft(
        mosqueId: mosqueId,
        prayer: SalahPrayer.isha,
        mode: TimingRuleMode.dateRangeFixed,
        fixedTime: const TimeOfDayValue(hour: 20, minute: 0),
        rangeStart: const MonthDay(month: 9, day: 1),
        rangeEnd: const MonthDay(month: 10, day: 31),
      ),
      TimingRuleDraft(
        mosqueId: mosqueId,
        prayer: SalahPrayer.isha,
        mode: TimingRuleMode.dateRangeFixed,
        fixedTime: const TimeOfDayValue(hour: 19, minute: 30),
        rangeStart: const MonthDay(month: 11, day: 1),
        rangeEnd: const MonthDay(month: 2, day: 28),
      ),
      TimingRuleDraft(
        mosqueId: mosqueId,
        prayer: SalahPrayer.isha,
        mode: TimingRuleMode.dateRangeFixed,
        fixedTime: const TimeOfDayValue(hour: 19, minute: 0),
        rangeStart: const MonthDay(month: 3, day: 1),
        rangeEnd: const MonthDay(month: 4, day: 30),
      ),
      TimingRuleDraft(
        mosqueId: mosqueId,
        prayer: SalahPrayer.jummah,
        mode: TimingRuleMode.fixed,
        fixedTime: const TimeOfDayValue(hour: 13, minute: 30),
      ),
    ];
  }

  Future<void> resetAndReseed() async {
    await _timingRuleRepository.resetAll();
    await _mosqueRepository.resetAll();
    await _settingsRepository.resetAll();
    await seedIfEmpty();
  }
}
