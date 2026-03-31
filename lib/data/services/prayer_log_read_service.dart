import '../../core/prayer_log/prayer_log_status.dart';
import '../../core/time/salah_prayer.dart';
import '../../core/utils/date_key.dart';
import '../db/app_database.dart';
import '../models/prayer_log_read_model.dart';
import '../models/prayer_log_record.dart';

class PrayerLogReadService {
  const PrayerLogReadService();

  PrayerLogDayReadModel buildDay({
    required DateTime date,
    required List<PrayerLogRecord> dayEntries,
    required List<PrayerLogRecord> weekEntries,
    required List<PrayerLogRecord> monthEntries,
    required List<Mosque> mosques,
  }) {
    final mosqueById = {for (final mosque in mosques) mosque.id: mosque};
    final byPrayer = {for (final entry in dayEntries) entry.prayer: entry};
    final prayers = _displayPrayersFor(date);

    return PrayerLogDayReadModel(
      date: startOfDay(date),
      rows: [
        for (final prayer in prayers)
          PrayerLogDayRow(
            prayer: prayer,
            record: byPrayer[prayer],
            mosque: byPrayer[prayer]?.mosqueId == null
                ? null
                : mosqueById[byPrayer[prayer]!.mosqueId!],
          ),
      ],
      weekSummary: _buildSummary(weekEntries),
      monthSummary: _buildSummary(monthEntries),
    );
  }

  PrayerLogSummary _buildSummary(List<PrayerLogRecord> entries) {
    var jamaat = 0;
    var alone = 0;
    var missed = 0;
    for (final entry in entries) {
      switch (entry.status) {
        case PrayerLogStatus.jamaat:
          jamaat++;
        case PrayerLogStatus.alone:
          alone++;
        case PrayerLogStatus.missed:
          missed++;
      }
    }

    return PrayerLogSummary(
      total: entries.length,
      jamaat: jamaat,
      alone: alone,
      missed: missed,
    );
  }

  List<SalahPrayer> _displayPrayersFor(DateTime date) {
    return date.weekday == DateTime.friday
        ? const [
            SalahPrayer.fajr,
            SalahPrayer.jummah,
            SalahPrayer.asr,
            SalahPrayer.maghrib,
            SalahPrayer.isha,
          ]
        : const [
            SalahPrayer.fajr,
            SalahPrayer.dhuhr,
            SalahPrayer.asr,
            SalahPrayer.maghrib,
            SalahPrayer.isha,
          ];
  }
}
