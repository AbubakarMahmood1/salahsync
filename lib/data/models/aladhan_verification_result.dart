import '../../core/time/prayer_times_snapshot.dart';
import '../../core/time/salah_prayer.dart';

class AlAdhanVerificationResult {
  const AlAdhanVerificationResult({
    required this.date,
    required this.locationLabel,
    required this.apiUrl,
    required this.engineSnapshot,
    required this.apiTimes,
    required this.differences,
  });

  final DateTime date;
  final String locationLabel;
  final String apiUrl;
  final PrayerTimesSnapshot engineSnapshot;
  final Map<SalahPrayer, DateTime> apiTimes;
  final Map<SalahPrayer, Duration> differences;

  bool get hasWarning {
    return differences.values.any(
      (difference) => difference.inMinutes.abs() > 2,
    );
  }
}
