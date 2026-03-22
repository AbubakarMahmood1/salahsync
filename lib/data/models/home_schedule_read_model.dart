import '../../core/mosque/resolved_timing.dart';
import '../../core/time/prayer_calculation_config.dart';
import '../../core/time/prayer_times_snapshot.dart';
import '../../core/time/salah_prayer.dart';
import '../db/app_database.dart';

class HomeScheduleReadModel {
  const HomeScheduleReadModel({
    required this.primaryMosque,
    required this.calculationConfig,
    required this.computedSnapshot,
    required this.displayPrayers,
    required this.resolvedJamaatTimes,
  });

  final Mosque primaryMosque;
  final PrayerCalculationConfig calculationConfig;
  final PrayerTimesSnapshot computedSnapshot;
  final List<SalahPrayer> displayPrayers;
  final Map<SalahPrayer, ResolvedTiming> resolvedJamaatTimes;
}
