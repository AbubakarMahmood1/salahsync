import 'dart:async';

import 'package:adhan_dart/adhan_dart.dart';
import 'package:hijri_calendar/hijri_calendar.dart';
import 'package:timezone/timezone.dart' as tz;

import 'hijri_date_info.dart';
import 'prayer_calculation_config.dart';
import 'prayer_times_snapshot.dart';
import 'prayer_window.dart';
import 'qibla_service.dart';
import 'salah_prayer.dart';
import 'timezone_name.dart';

class PrayerTimeService {
  const PrayerTimeService();

  PrayerTimesSnapshot calculateDay({
    required DateTime date,
    required PrayerCalculationConfig config,
  }) {
    final location = resolveTimezoneLocation(
      config.timezoneName,
      fallback: kDefaultTimezoneName,
    );
    final localDate = tz.TZDateTime(location, date.year, date.month, date.day);
    final parameters = _buildCalculationParameters(config);

    final rawPrayerTimes = PrayerTimes(
      date: localDate,
      coordinates: Coordinates(
        config.coordinates.latitude,
        config.coordinates.longitude,
      ),
      calculationParameters: parameters,
    );

    final fajr = tz.TZDateTime.from(rawPrayerTimes.fajr, location);
    final sunrise = tz.TZDateTime.from(rawPrayerTimes.sunrise, location);
    final dhuhr = tz.TZDateTime.from(rawPrayerTimes.dhuhr, location);
    final asr = tz.TZDateTime.from(rawPrayerTimes.asr, location);
    final maghrib = tz.TZDateTime.from(rawPrayerTimes.maghrib, location);
    final isha = tz.TZDateTime.from(rawPrayerTimes.isha, location);
    final nextFajr = tz.TZDateTime.from(rawPrayerTimes.fajrAfter, location);
    final imsak = fajr.subtract(Duration(minutes: config.imsakOffsetMinutes));

    final hijriSourceDate = localDate.add(
      Duration(days: config.hijriOffsetDays),
    );
    final hijriCalendar = runZoned<HijriCalendarConfig>(
      () => HijriCalendarConfig.fromGregorian(hijriSourceDate),
      zoneSpecification: ZoneSpecification(
        print: (self, parent, zone, line) {},
      ),
    );
    final hijriDate = HijriDateInfo(
      year: hijriCalendar.hYear,
      month: hijriCalendar.hMonth,
      day: hijriCalendar.hDay,
      monthName: hijriCalendar.getLongMonthName(),
      weekdayName: hijriCalendar.getDayName(),
      adjustmentDays: config.hijriOffsetDays,
    );

    final ishaEnd = switch (config.ishaEndConvention) {
      IshaEndConvention.midnight => maghrib.add(
        Duration(seconds: nextFajr.difference(maghrib).inSeconds ~/ 2),
      ),
      IshaEndConvention.fajr => nextFajr,
    };

    return PrayerTimesSnapshot(
      locationName: config.locationName,
      date: localDate,
      times: <SalahPrayer, DateTime>{
        SalahPrayer.imsak: imsak,
        SalahPrayer.fajr: fajr,
        SalahPrayer.sunrise: sunrise,
        SalahPrayer.dhuhr: dhuhr,
        SalahPrayer.asr: asr,
        SalahPrayer.maghrib: maghrib,
        SalahPrayer.isha: isha,
      },
      windows: <SalahPrayer, PrayerWindow>{
        SalahPrayer.fajr: PrayerWindow(
          prayer: SalahPrayer.fajr,
          start: fajr,
          end: sunrise,
        ),
        SalahPrayer.dhuhr: PrayerWindow(
          prayer: SalahPrayer.dhuhr,
          start: dhuhr,
          end: asr,
        ),
        SalahPrayer.asr: PrayerWindow(
          prayer: SalahPrayer.asr,
          start: asr,
          end: maghrib,
        ),
        SalahPrayer.maghrib: PrayerWindow(
          prayer: SalahPrayer.maghrib,
          start: maghrib,
          end: isha,
        ),
        SalahPrayer.isha: PrayerWindow(
          prayer: SalahPrayer.isha,
          start: isha,
          end: ishaEnd,
        ),
      },
      hijriDate: hijriDate,
      isRamadanActive: config.ramadanModeOverride ?? hijriDate.isRamadan,
      qiblaBearing: const QiblaService().bearingFor(config.coordinates),
    );
  }

  CalculationParameters _buildCalculationParameters(
    PrayerCalculationConfig config,
  ) {
    final parameters = switch (config.method) {
      PrayerCalculationMethodChoice.karachi =>
        CalculationMethodParameters.karachi(),
      PrayerCalculationMethodChoice.muslimWorldLeague =>
        CalculationMethodParameters.muslimWorldLeague(),
      PrayerCalculationMethodChoice.egyptian =>
        CalculationMethodParameters.egyptian(),
      PrayerCalculationMethodChoice.ummAlQura =>
        CalculationMethodParameters.ummAlQura(),
      PrayerCalculationMethodChoice.dubai =>
        CalculationMethodParameters.dubai(),
      PrayerCalculationMethodChoice.qatar =>
        CalculationMethodParameters.qatar(),
      PrayerCalculationMethodChoice.kuwait =>
        CalculationMethodParameters.kuwait(),
      PrayerCalculationMethodChoice.moonsightingCommittee =>
        CalculationMethodParameters.moonsightingCommittee(),
      PrayerCalculationMethodChoice.singapore =>
        CalculationMethodParameters.singapore(),
      PrayerCalculationMethodChoice.turkiye =>
        CalculationMethodParameters.turkiye(),
      PrayerCalculationMethodChoice.tehran =>
        CalculationMethodParameters.tehran(),
      PrayerCalculationMethodChoice.other =>
        CalculationMethodParameters.other(),
    };

    parameters.madhab = switch (config.asrSchool) {
      AsrJuristicSchool.shafi => Madhab.shafi,
      AsrJuristicSchool.hanafi => Madhab.hanafi,
    };

    parameters.adjustments[Prayer.fajr] = config.adjustments.fajr;
    parameters.adjustments[Prayer.sunrise] = config.adjustments.sunrise;
    parameters.adjustments[Prayer.dhuhr] = config.adjustments.dhuhr;
    parameters.adjustments[Prayer.asr] = config.adjustments.asr;
    parameters.adjustments[Prayer.maghrib] = config.adjustments.maghrib;
    parameters.adjustments[Prayer.isha] = config.adjustments.isha;

    return parameters;
  }
}
