import '../../core/mosque/resolved_timing.dart';
import '../../core/time/salah_prayer.dart';
import '../db/app_database.dart';

class MosqueComparisonScheduleReadModel {
  const MosqueComparisonScheduleReadModel({
    required this.mosque,
    required this.displayPrayers,
    required this.resolvedJamaatTimes,
  });

  final Mosque mosque;
  final List<SalahPrayer> displayPrayers;
  final Map<SalahPrayer, ResolvedTiming> resolvedJamaatTimes;
}
