import '../../core/mosque/resolved_timing.dart';
import '../../core/mosque/timing_rule.dart';
import '../../core/mosque/timing_rule_resolver.dart';
import '../../core/time/geo_coordinates.dart';
import '../../core/time/prayer_calculation_config.dart';
import '../../core/time/prayer_time_service.dart';
import '../../core/time/prayer_times_snapshot.dart';
import '../../core/time/salah_prayer.dart';
import '../db/app_database.dart';
import '../models/home_schedule_read_model.dart';
import '../models/mosque_comparison_schedule_read_model.dart';

class MosqueScheduleReadService {
  const MosqueScheduleReadService({
    PrayerTimeService prayerTimeService = const PrayerTimeService(),
    TimingRuleResolver timingRuleResolver = const TimingRuleResolver(),
  }) : _prayerTimeService = prayerTimeService,
       _timingRuleResolver = timingRuleResolver;

  final PrayerTimeService _prayerTimeService;
  final TimingRuleResolver _timingRuleResolver;

  HomeScheduleReadModel buildHomeSchedule({
    required DateTime date,
    required PrayerCalculationConfig config,
    required Mosque primaryMosque,
    required List<TimingRule> rules,
  }) {
    final computedSnapshot = _buildSnapshotForMosque(
      date: date,
      config: config,
      mosque: primaryMosque,
    );
    final displayPrayers = _displayPrayersFor(date);

    final resolvedJamaatTimes = <SalahPrayer, ResolvedTiming>{
      for (final prayer in displayPrayers)
        if (_isJamaatPrayer(prayer))
          prayer: _timingRuleResolver.resolve(
            date: computedSnapshot.date,
            prayer: prayer,
            computedSnapshot: computedSnapshot,
            rules: rules,
          ),
    };

    return HomeScheduleReadModel(
      primaryMosque: primaryMosque,
      calculationConfig: config,
      computedSnapshot: computedSnapshot,
      displayPrayers: displayPrayers,
      resolvedJamaatTimes: resolvedJamaatTimes,
    );
  }

  List<MosqueComparisonScheduleReadModel> buildComparisonSchedules({
    required DateTime date,
    required PrayerCalculationConfig config,
    required List<Mosque> mosques,
    required Map<int, List<TimingRule>> rulesByMosque,
  }) {
    final displayPrayers = _displayPrayersFor(
      date,
    ).where(_isJamaatPrayer).toList(growable: false);

    return mosques
        .where((mosque) => mosque.isActive)
        .map((mosque) {
          final computedSnapshot = _buildSnapshotForMosque(
            date: date,
            config: config,
            mosque: mosque,
          );
          final rules = rulesByMosque[mosque.id] ?? const <TimingRule>[];

          return MosqueComparisonScheduleReadModel(
            mosque: mosque,
            displayPrayers: displayPrayers,
            resolvedJamaatTimes: {
              for (final prayer in displayPrayers)
                prayer: _timingRuleResolver.resolve(
                  date: computedSnapshot.date,
                  prayer: prayer,
                  computedSnapshot: computedSnapshot,
                  rules: rules,
                ),
            },
          );
        })
        .toList(growable: false);
  }

  PrayerTimesSnapshot _buildSnapshotForMosque({
    required DateTime date,
    required PrayerCalculationConfig config,
    required Mosque mosque,
  }) {
    final effectiveCoordinates =
        mosque.latitude != null && mosque.longitude != null
        ? GeoCoordinates(
            latitude: mosque.latitude!,
            longitude: mosque.longitude!,
          )
        : config.coordinates;

    return _prayerTimeService.calculateDay(
      date: date,
      config: config.copyWith(
        locationName: mosque.name,
        coordinates: effectiveCoordinates,
      ),
    );
  }

  List<SalahPrayer> _displayPrayersFor(DateTime date) {
    return date.weekday == DateTime.friday
        ? const [
            SalahPrayer.imsak,
            SalahPrayer.fajr,
            SalahPrayer.sunrise,
            SalahPrayer.jummah,
            SalahPrayer.asr,
            SalahPrayer.maghrib,
            SalahPrayer.isha,
          ]
        : const [
            SalahPrayer.imsak,
            SalahPrayer.fajr,
            SalahPrayer.sunrise,
            SalahPrayer.dhuhr,
            SalahPrayer.asr,
            SalahPrayer.maghrib,
            SalahPrayer.isha,
          ];
  }

  bool _isJamaatPrayer(SalahPrayer prayer) {
    return prayer != SalahPrayer.imsak && prayer != SalahPrayer.sunrise;
  }
}
