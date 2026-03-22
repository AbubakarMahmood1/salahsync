import 'hijri_date_info.dart';
import 'prayer_window.dart';
import 'salah_prayer.dart';

class PrayerTimesSnapshot {
  const PrayerTimesSnapshot({
    required this.locationName,
    required this.date,
    required this.times,
    required this.windows,
    required this.hijriDate,
    required this.isRamadanActive,
    required this.qiblaBearing,
  });

  final String locationName;
  final DateTime date;
  final Map<SalahPrayer, DateTime> times;
  final Map<SalahPrayer, PrayerWindow> windows;
  final HijriDateInfo hijriDate;
  final bool isRamadanActive;
  final double qiblaBearing;

  DateTime timeOf(SalahPrayer prayer) => times[prayer]!;

  PrayerWindow? windowFor(SalahPrayer prayer) => windows[prayer];

  SalahPrayer? currentWindowPrayerAt(DateTime moment) {
    for (final prayer in kWindowPrayerOrder) {
      final window = windows[prayer];
      if (window != null && window.contains(moment)) {
        return prayer;
      }
    }

    return null;
  }

  SalahPrayer nextPrayerAt(DateTime moment) {
    for (final prayer in const [
      SalahPrayer.fajr,
      SalahPrayer.dhuhr,
      SalahPrayer.asr,
      SalahPrayer.maghrib,
      SalahPrayer.isha,
    ]) {
      final time = times[prayer];
      if (time != null && moment.isBefore(time)) {
        return prayer;
      }
    }

    return SalahPrayer.fajr;
  }
}
