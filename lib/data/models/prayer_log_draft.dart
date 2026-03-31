import '../../core/prayer_log/prayer_log_status.dart';
import '../../core/time/salah_prayer.dart';

class PrayerLogDraft {
  const PrayerLogDraft({
    required this.date,
    required this.prayer,
    required this.status,
    this.mosqueId,
    this.notes,
  });

  final DateTime date;
  final SalahPrayer prayer;
  final PrayerLogStatus status;
  final int? mosqueId;
  final String? notes;
}
