import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz;

import 'package:salahsync/core/time/prayer_calculation_config.dart';
import 'package:salahsync/core/time/prayer_time_service.dart';
import 'package:salahsync/core/time/salah_prayer.dart';
import 'package:salahsync/data/db/app_database.dart';
import 'package:salahsync/data/models/home_schedule_read_model.dart';
import 'package:salahsync/features/home/presentation/home_prayer_status.dart';

void main() {
  setUpAll(() {
    tz.initializeTimeZones();
  });

  test('computeHomePrayerStatus uses tomorrow\'s actual Fajr after Isha', () {
    final config = PrayerCalculationConfig.khanewalDefault();
    final prayerTimeService = const PrayerTimeService();
    final todaySnapshot = prayerTimeService.calculateDay(
      date: DateTime(2026, 3, 27),
      config: config,
    );
    final tomorrowSnapshot = prayerTimeService.calculateDay(
      date: DateTime(2026, 3, 28),
      config: config,
    );
    final model = HomeScheduleReadModel(
      primaryMosque: Mosque(
        id: 1,
        name: 'Masjid Al-Noor',
        area: 'Khanewal',
        latitude: null,
        longitude: null,
        isPrimary: true,
        isActive: true,
        notes: null,
        createdAt: '2026-03-22T00:00:00Z',
        updatedAt: '2026-03-22T00:00:00Z',
      ),
      calculationConfig: config,
      computedSnapshot: todaySnapshot,
      displayPrayers: const [
        SalahPrayer.fajr,
        SalahPrayer.dhuhr,
        SalahPrayer.asr,
        SalahPrayer.maghrib,
        SalahPrayer.isha,
      ],
      resolvedJamaatTimes: const {},
    );
    final now = todaySnapshot
        .timeOf(SalahPrayer.isha)
        .add(const Duration(minutes: 10));

    final status = computeHomePrayerStatus(model: model, now: now);

    expect(status.nextPrayer, SalahPrayer.fajr);
    expect(status.nextPrayerTime, tomorrowSnapshot.timeOf(SalahPrayer.fajr));
    expect(
      status.nextPrayerTime,
      isNot(
        todaySnapshot.timeOf(SalahPrayer.fajr).add(const Duration(days: 1)),
      ),
    );
  });
}
