import '../../core/prayer_log/prayer_log_status.dart';
import '../../core/time/salah_prayer.dart';

class PrayerLogRecord {
  const PrayerLogRecord({
    required this.id,
    required this.date,
    required this.prayer,
    required this.status,
    required this.mosqueId,
    required this.notes,
    required this.loggedAt,
  });

  final int id;
  final DateTime date;
  final SalahPrayer prayer;
  final PrayerLogStatus status;
  final int? mosqueId;
  final String? notes;
  final DateTime loggedAt;
}
