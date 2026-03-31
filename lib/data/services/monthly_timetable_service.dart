import '../../core/mosque/resolved_timing.dart';
import '../../core/mosque/timing_rule.dart';
import '../../core/mosque/timing_rule_resolver.dart';
import '../../core/time/geo_coordinates.dart';
import '../../core/time/prayer_calculation_config.dart';
import '../../core/time/prayer_time_service.dart';
import '../../core/time/salah_prayer.dart';
import '../db/app_database.dart';
import '../models/monthly_timetable_read_model.dart';

class MonthlyTimetableService {
  const MonthlyTimetableService({
    PrayerTimeService prayerTimeService = const PrayerTimeService(),
    TimingRuleResolver timingRuleResolver = const TimingRuleResolver(),
  }) : _prayerTimeService = prayerTimeService,
       _timingRuleResolver = timingRuleResolver;

  final PrayerTimeService _prayerTimeService;
  final TimingRuleResolver _timingRuleResolver;

  MonthlyTimetableReadModel buildMonth({
    required DateTime month,
    required PrayerCalculationConfig config,
    required Mosque? primaryMosque,
    required List<TimingRule> rules,
  }) {
    final firstDay = DateTime(month.year, month.month);
    final lastDay = DateTime(month.year, month.month + 1, 0);
    final effectiveConfig = primaryMosque == null
        ? config
        : config.copyWith(
            locationName: primaryMosque.name,
            coordinates:
                primaryMosque.latitude != null &&
                    primaryMosque.longitude != null
                ? GeoCoordinates(
                    latitude: primaryMosque.latitude!,
                    longitude: primaryMosque.longitude!,
                  )
                : config.coordinates,
          );

    final days = <MonthlyTimetableDay>[];
    for (var day = firstDay.day; day <= lastDay.day; day++) {
      final date = DateTime(month.year, month.month, day);
      final snapshot = _prayerTimeService.calculateDay(
        date: date,
        config: effectiveConfig,
      );
      ResolvedTiming? jummahTiming;
      if (date.weekday == DateTime.friday) {
        jummahTiming = _timingRuleResolver.resolve(
          date: snapshot.date,
          prayer: SalahPrayer.jummah,
          computedSnapshot: snapshot,
          rules: rules,
        );
      }

      days.add(
        MonthlyTimetableDay(snapshot: snapshot, jummahTiming: jummahTiming),
      );
    }

    return MonthlyTimetableReadModel(
      month: firstDay,
      primaryMosque: primaryMosque,
      days: List<MonthlyTimetableDay>.unmodifiable(days),
    );
  }
}
