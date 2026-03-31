import '../../core/prayer_log/prayer_log_status.dart';
import '../../core/time/salah_prayer.dart';
import '../db/app_database.dart';
import 'prayer_log_record.dart';

class PrayerLogDayReadModel {
  const PrayerLogDayReadModel({
    required this.date,
    required this.rows,
    required this.weekSummary,
    required this.monthSummary,
  });

  final DateTime date;
  final List<PrayerLogDayRow> rows;
  final PrayerLogSummary weekSummary;
  final PrayerLogSummary monthSummary;
}

class PrayerLogDayRow {
  const PrayerLogDayRow({
    required this.prayer,
    required this.record,
    required this.mosque,
  });

  final SalahPrayer prayer;
  final PrayerLogRecord? record;
  final Mosque? mosque;

  PrayerLogStatus? get status => record?.status;
}

class PrayerLogSummary {
  const PrayerLogSummary({
    required this.total,
    required this.jamaat,
    required this.alone,
    required this.missed,
  });

  final int total;
  final int jamaat;
  final int alone;
  final int missed;
}
