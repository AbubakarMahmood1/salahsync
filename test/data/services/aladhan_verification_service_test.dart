import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:timezone/data/latest.dart' as tz;

import 'package:salahsync/core/time/prayer_calculation_config.dart';
import 'package:salahsync/core/time/salah_prayer.dart';
import 'package:salahsync/data/services/aladhan_verification_service.dart';

void main() {
  setUpAll(() {
    tz.initializeTimeZones();
  });

  test('verify parses timings and computes per-prayer differences', () async {
    final service = AlAdhanVerificationService(
      client: MockClient((request) async {
        expect(request.url.path, '/v1/timings/31-03-2026');
        return http.Response(
          jsonEncode({
            'data': {
              'timings': {
                'Fajr': '04:42',
                'Sunrise': '06:03',
                'Dhuhr': '12:16',
                'Asr': '16:44',
                'Maghrib': '18:30',
                'Isha': '19:51',
              },
            },
          }),
          200,
        );
      }),
    );

    final result = await service.verify(
      date: DateTime(2026, 3, 31),
      config: PrayerCalculationConfig.khanewalDefault(),
    );

    expect(result.apiTimes[SalahPrayer.fajr]!.hour, 4);
    expect(result.apiTimes[SalahPrayer.fajr]!.minute, 42);
    expect(result.differences.containsKey(SalahPrayer.isha), isTrue);
  });
}
