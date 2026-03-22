import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz;

import 'package:salahsync/core/time/prayer_calculation_config.dart';
import 'package:salahsync/core/time/prayer_time_service.dart';
import 'package:salahsync/core/time/salah_prayer.dart';
import 'package:salahsync/core/time/timezone_name.dart';

void main() {
  setUpAll(() {
    tz.initializeTimeZones();
  });

  group('PrayerTimeService', () {
    const service = PrayerTimeService();
    final config = PrayerCalculationConfig.khanewalDefault();

    test(
      'matches the AlAdhan Hanafi reference dates from the SRS checklist',
      () {
        final fixtures = <_ReferenceTiming>[
          _ReferenceTiming(
            date: DateTime(2026, 3, 21),
            fajr: '04:55',
            sunrise: '06:15',
            dhuhr: '12:19',
            asr: '16:41',
            maghrib: '18:24',
            isha: '19:44',
            imsak: '04:45',
          ),
          _ReferenceTiming(
            date: DateTime(2026, 6, 21),
            fajr: '03:34',
            sunrise: '05:11',
            dhuhr: '12:14',
            asr: '17:08',
            maghrib: '19:17',
            isha: '20:54',
            imsak: '03:24',
          ),
          _ReferenceTiming(
            date: DateTime(2026, 9, 22),
            fajr: '04:40',
            sunrise: '06:00',
            dhuhr: '12:05',
            asr: '16:27',
            maghrib: '18:09',
            isha: '19:29',
            imsak: '04:30',
          ),
          _ReferenceTiming(
            date: DateTime(2026, 12, 21),
            fajr: '05:39',
            sunrise: '07:04',
            dhuhr: '12:10',
            asr: '15:39',
            maghrib: '17:16',
            isha: '18:42',
            imsak: '05:29',
          ),
        ];

        for (final fixture in fixtures) {
          final snapshot = service.calculateDay(
            date: fixture.date,
            config: config,
          );

          expect(
            _minuteDelta(snapshot.timeOf(SalahPrayer.imsak), fixture.imsak),
            lessThanOrEqualTo(1),
          );
          expect(
            _minuteDelta(snapshot.timeOf(SalahPrayer.fajr), fixture.fajr),
            lessThanOrEqualTo(1),
          );
          expect(
            _minuteDelta(snapshot.timeOf(SalahPrayer.sunrise), fixture.sunrise),
            lessThanOrEqualTo(1),
          );
          expect(
            _minuteDelta(snapshot.timeOf(SalahPrayer.dhuhr), fixture.dhuhr),
            lessThanOrEqualTo(1),
          );
          expect(
            _minuteDelta(snapshot.timeOf(SalahPrayer.asr), fixture.asr),
            lessThanOrEqualTo(1),
          );
          expect(
            _minuteDelta(snapshot.timeOf(SalahPrayer.maghrib), fixture.maghrib),
            lessThanOrEqualTo(1),
          );
          expect(
            _minuteDelta(snapshot.timeOf(SalahPrayer.isha), fixture.isha),
            lessThanOrEqualTo(1),
          );
        }
      },
    );

    test('manual adjustments propagate into derived times and windows', () {
      final adjustedConfig = config.copyWith(
        adjustments: const PrayerAdjustments(fajr: 2, asr: -1),
      );

      final snapshot = service.calculateDay(
        date: DateTime(2026, 3, 21),
        config: adjustedConfig,
      );

      expect(_hhmm(snapshot.timeOf(SalahPrayer.fajr)), '04:57');
      expect(_hhmm(snapshot.timeOf(SalahPrayer.imsak)), '04:47');
      expect(_hhmm(snapshot.timeOf(SalahPrayer.asr)), '16:40');
      expect(_hhmm(snapshot.windowFor(SalahPrayer.dhuhr)!.end), '16:40');
    });

    test('computes the Khanewal qibla bearing close to the SRS reference', () {
      final snapshot = service.calculateDay(
        date: DateTime(2026, 3, 21),
        config: config,
      );

      expect(snapshot.qiblaBearing, closeTo(260.5, 0.2));
    });

    test('falls back to the default timezone for invalid timezone names', () {
      final invalidTimezoneConfig = config.copyWith(
        timezoneName: 'Mars/Olympus',
      );

      final fallbackSnapshot = service.calculateDay(
        date: DateTime(2026, 3, 21),
        config: invalidTimezoneConfig,
      );
      final defaultSnapshot = service.calculateDay(
        date: DateTime(2026, 3, 21),
        config: config.copyWith(timezoneName: kDefaultTimezoneName),
      );

      expect(
        _hhmm(fallbackSnapshot.timeOf(SalahPrayer.fajr)),
        _hhmm(defaultSnapshot.timeOf(SalahPrayer.fajr)),
      );
      expect(
        fallbackSnapshot.date.timeZoneName,
        defaultSnapshot.date.timeZoneName,
      );
    });
  });
}

class _ReferenceTiming {
  const _ReferenceTiming({
    required this.date,
    required this.fajr,
    required this.sunrise,
    required this.dhuhr,
    required this.asr,
    required this.maghrib,
    required this.isha,
    required this.imsak,
  });

  final DateTime date;
  final String fajr;
  final String sunrise;
  final String dhuhr;
  final String asr;
  final String maghrib;
  final String isha;
  final String imsak;
}

String _hhmm(DateTime value) {
  final hour = value.hour.toString().padLeft(2, '0');
  final minute = value.minute.toString().padLeft(2, '0');
  return '$hour:$minute';
}

int _minuteDelta(DateTime actual, String expected) {
  final parts = expected.split(':');
  final expectedMinutes = (int.parse(parts[0]) * 60) + int.parse(parts[1]);
  final actualMinutes = (actual.hour * 60) + actual.minute;
  return (actualMinutes - expectedMinutes).abs();
}
