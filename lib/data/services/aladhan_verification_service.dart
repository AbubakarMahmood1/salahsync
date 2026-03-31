import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:timezone/timezone.dart' as tz;

import '../../core/time/prayer_calculation_config.dart';
import '../../core/time/prayer_time_service.dart';
import '../../core/time/salah_prayer.dart';
import '../../core/time/timezone_name.dart';
import '../models/aladhan_verification_result.dart';

class AlAdhanVerificationService {
  AlAdhanVerificationService({
    http.Client? client,
    PrayerTimeService prayerTimeService = const PrayerTimeService(),
  }) : _client = client ?? http.Client(),
       _prayerTimeService = prayerTimeService;

  final http.Client _client;
  final PrayerTimeService _prayerTimeService;

  Future<AlAdhanVerificationResult> verify({
    required DateTime date,
    required PrayerCalculationConfig config,
  }) async {
    final unadjustedConfig = config.copyWith(
      adjustments: const PrayerAdjustments(),
    );
    final engineSnapshot = _prayerTimeService.calculateDay(
      date: date,
      config: unadjustedConfig,
    );

    final uri = Uri.https(
      'api.aladhan.com',
      '/v1/timings/${_dateParam(date)}',
      {
        'latitude': unadjustedConfig.coordinates.latitude.toStringAsFixed(4),
        'longitude': unadjustedConfig.coordinates.longitude.toStringAsFixed(4),
        'method': _methodId(unadjustedConfig.method).toString(),
        'school': _schoolId(unadjustedConfig.asrSchool).toString(),
      },
    );

    final response = await _client.get(uri);
    if (response.statusCode != 200) {
      throw AlAdhanVerificationException(
        'AlAdhan responded with ${response.statusCode}.',
      );
    }

    final payload =
        jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
    final data = payload['data'];
    if (data is! Map<String, dynamic>) {
      throw const AlAdhanVerificationException('Unexpected AlAdhan payload.');
    }
    final timings = data['timings'];
    if (timings is! Map<String, dynamic>) {
      throw const AlAdhanVerificationException('Missing timing data.');
    }

    final location = resolveTimezoneLocation(unadjustedConfig.timezoneName);
    final apiTimes = <SalahPrayer, DateTime>{
      SalahPrayer.fajr: _parseTiming(
        timings['Fajr']?.toString(),
        location,
        date,
      ),
      SalahPrayer.sunrise: _parseTiming(
        timings['Sunrise']?.toString(),
        location,
        date,
      ),
      SalahPrayer.dhuhr: _parseTiming(
        timings['Dhuhr']?.toString(),
        location,
        date,
      ),
      SalahPrayer.asr: _parseTiming(timings['Asr']?.toString(), location, date),
      SalahPrayer.maghrib: _parseTiming(
        timings['Maghrib']?.toString(),
        location,
        date,
      ),
      SalahPrayer.isha: _parseTiming(
        timings['Isha']?.toString(),
        location,
        date,
      ),
    };

    return AlAdhanVerificationResult(
      date: date,
      locationLabel: unadjustedConfig.locationName,
      apiUrl: uri.toString(),
      engineSnapshot: engineSnapshot,
      apiTimes: apiTimes,
      differences: {
        for (final prayer in _verificationPrayers)
          prayer: apiTimes[prayer]!.difference(engineSnapshot.timeOf(prayer)),
      },
    );
  }

  DateTime _parseTiming(String? value, tz.Location location, DateTime date) {
    final match = RegExp(r'(\d{1,2}):(\d{2})').firstMatch(value ?? '');
    if (match == null) {
      throw AlAdhanVerificationException('Invalid timing value: $value');
    }

    final hour = int.parse(match.group(1)!);
    final minute = int.parse(match.group(2)!);
    return tz.TZDateTime(
      location,
      date.year,
      date.month,
      date.day,
      hour,
      minute,
    );
  }

  int _methodId(PrayerCalculationMethodChoice method) {
    return switch (method) {
      PrayerCalculationMethodChoice.karachi => 1,
      PrayerCalculationMethodChoice.muslimWorldLeague => 3,
      PrayerCalculationMethodChoice.egyptian => 5,
      PrayerCalculationMethodChoice.ummAlQura => 4,
      PrayerCalculationMethodChoice.dubai => 8,
      PrayerCalculationMethodChoice.qatar => 10,
      PrayerCalculationMethodChoice.kuwait => 9,
      PrayerCalculationMethodChoice.moonsightingCommittee => 15,
      PrayerCalculationMethodChoice.singapore => 11,
      PrayerCalculationMethodChoice.turkiye => 13,
      PrayerCalculationMethodChoice.tehran => 7,
      PrayerCalculationMethodChoice.other => 99,
    };
  }

  int _schoolId(AsrJuristicSchool school) {
    return switch (school) {
      AsrJuristicSchool.shafi => 0,
      AsrJuristicSchool.hanafi => 1,
    };
  }

  String _dateParam(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day-$month-${date.year}';
  }
}

const _verificationPrayers = <SalahPrayer>[
  SalahPrayer.fajr,
  SalahPrayer.sunrise,
  SalahPrayer.dhuhr,
  SalahPrayer.asr,
  SalahPrayer.maghrib,
  SalahPrayer.isha,
];

class AlAdhanVerificationException implements Exception {
  const AlAdhanVerificationException(this.message);

  final String message;

  @override
  String toString() => 'AlAdhanVerificationException: $message';
}
