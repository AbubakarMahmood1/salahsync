import '../../../core/time/prayer_time_service.dart';
import '../../../core/time/salah_prayer.dart';
import '../../../data/models/home_schedule_read_model.dart';

class HomePrayerStatus {
  const HomePrayerStatus({
    required this.currentPrayer,
    required this.nextPrayer,
    required this.nextPrayerTime,
  });

  final SalahPrayer? currentPrayer;
  final SalahPrayer nextPrayer;
  final DateTime nextPrayerTime;
}

HomePrayerStatus computeHomePrayerStatus({
  required HomeScheduleReadModel model,
  required DateTime now,
  PrayerTimeService prayerTimeService = const PrayerTimeService(),
}) {
  final snapshot = model.computedSnapshot;
  final currentPrayer = _displayPrayerForDate(
    snapshot.currentWindowPrayerAt(now),
    snapshot.date,
  );
  final nextPrayer =
      _displayPrayerForDate(snapshot.nextPrayerAt(now), snapshot.date) ??
      SalahPrayer.fajr;

  var nextPrayerTime = snapshot.timeOf(
    nextPrayer == SalahPrayer.jummah ? SalahPrayer.dhuhr : nextPrayer,
  );
  if (nextPrayer == SalahPrayer.fajr &&
      now.isAfter(snapshot.timeOf(SalahPrayer.isha))) {
    final tomorrowSnapshot = prayerTimeService.calculateDay(
      date: snapshot.date.add(const Duration(days: 1)),
      config: model.calculationConfig,
    );
    nextPrayerTime = tomorrowSnapshot.timeOf(SalahPrayer.fajr);
  }

  return HomePrayerStatus(
    currentPrayer: currentPrayer,
    nextPrayer: nextPrayer,
    nextPrayerTime: nextPrayerTime,
  );
}

SalahPrayer? _displayPrayerForDate(SalahPrayer? prayer, DateTime date) {
  if (prayer == null) {
    return null;
  }
  if (date.weekday == DateTime.friday && prayer == SalahPrayer.dhuhr) {
    return SalahPrayer.jummah;
  }
  return prayer;
}
