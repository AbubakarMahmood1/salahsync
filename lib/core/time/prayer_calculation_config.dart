import 'geo_coordinates.dart';
import 'salah_prayer.dart';
import 'timezone_name.dart';

enum PrayerCalculationMethodChoice {
  karachi,
  muslimWorldLeague,
  egyptian,
  ummAlQura,
  dubai,
  qatar,
  kuwait,
  moonsightingCommittee,
  singapore,
  turkiye,
  tehran,
  other,
}

enum AsrJuristicSchool { shafi, hanafi }

enum IshaEndConvention { midnight, fajr }

class PrayerAdjustments {
  const PrayerAdjustments({
    this.fajr = 0,
    this.sunrise = 0,
    this.dhuhr = 0,
    this.asr = 0,
    this.maghrib = 0,
    this.isha = 0,
  });

  final int fajr;
  final int sunrise;
  final int dhuhr;
  final int asr;
  final int maghrib;
  final int isha;

  int valueFor(SalahPrayer prayer) {
    return switch (prayer) {
      SalahPrayer.fajr => fajr,
      SalahPrayer.sunrise => sunrise,
      SalahPrayer.dhuhr => dhuhr,
      SalahPrayer.asr => asr,
      SalahPrayer.maghrib => maghrib,
      SalahPrayer.isha => isha,
      _ => 0,
    };
  }

  PrayerAdjustments copyWith({
    int? fajr,
    int? sunrise,
    int? dhuhr,
    int? asr,
    int? maghrib,
    int? isha,
  }) {
    return PrayerAdjustments(
      fajr: fajr ?? this.fajr,
      sunrise: sunrise ?? this.sunrise,
      dhuhr: dhuhr ?? this.dhuhr,
      asr: asr ?? this.asr,
      maghrib: maghrib ?? this.maghrib,
      isha: isha ?? this.isha,
    );
  }
}

class PrayerCalculationConfig {
  const PrayerCalculationConfig({
    required this.locationName,
    required this.coordinates,
    required this.timezoneName,
    required this.method,
    required this.asrSchool,
    required this.ishaEndConvention,
    this.imsakOffsetMinutes = 10,
    this.adjustments = const PrayerAdjustments(),
    this.hijriOffsetDays = 0,
    this.ramadanModeOverride,
  });

  factory PrayerCalculationConfig.khanewalDefault() {
    return const PrayerCalculationConfig(
      locationName: 'Khanewal, Pakistan',
      coordinates: GeoCoordinates(latitude: 30.3017, longitude: 71.9321),
      timezoneName: kDefaultTimezoneName,
      method: PrayerCalculationMethodChoice.karachi,
      asrSchool: AsrJuristicSchool.hanafi,
      ishaEndConvention: IshaEndConvention.midnight,
    );
  }

  final String locationName;
  final GeoCoordinates coordinates;
  final String timezoneName;
  final PrayerCalculationMethodChoice method;
  final AsrJuristicSchool asrSchool;
  final IshaEndConvention ishaEndConvention;
  final int imsakOffsetMinutes;
  final PrayerAdjustments adjustments;
  final int hijriOffsetDays;
  final bool? ramadanModeOverride;

  PrayerCalculationConfig copyWith({
    String? locationName,
    GeoCoordinates? coordinates,
    String? timezoneName,
    PrayerCalculationMethodChoice? method,
    AsrJuristicSchool? asrSchool,
    IshaEndConvention? ishaEndConvention,
    int? imsakOffsetMinutes,
    PrayerAdjustments? adjustments,
    int? hijriOffsetDays,
    bool? ramadanModeOverride,
  }) {
    return PrayerCalculationConfig(
      locationName: locationName ?? this.locationName,
      coordinates: coordinates ?? this.coordinates,
      timezoneName: timezoneName ?? this.timezoneName,
      method: method ?? this.method,
      asrSchool: asrSchool ?? this.asrSchool,
      ishaEndConvention: ishaEndConvention ?? this.ishaEndConvention,
      imsakOffsetMinutes: imsakOffsetMinutes ?? this.imsakOffsetMinutes,
      adjustments: adjustments ?? this.adjustments,
      hijriOffsetDays: hijriOffsetDays ?? this.hijriOffsetDays,
      ramadanModeOverride: ramadanModeOverride ?? this.ramadanModeOverride,
    );
  }
}
