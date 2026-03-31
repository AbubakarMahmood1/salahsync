import '../time/salah_prayer.dart';

enum IbadahTaskPrayerLink {
  none('Any time'),
  anyPrayer('Any prayer'),
  fajr('Fajr'),
  dhuhr('Dhuhr'),
  asr('Asr'),
  maghrib('Maghrib'),
  isha('Isha');

  const IbadahTaskPrayerLink(this.label);

  final String label;
}

extension IbadahTaskPrayerLinkX on IbadahTaskPrayerLink {
  SalahPrayer? toPrayerForDate(DateTime date) {
    return switch (this) {
      IbadahTaskPrayerLink.none => null,
      IbadahTaskPrayerLink.anyPrayer => null,
      IbadahTaskPrayerLink.fajr => SalahPrayer.fajr,
      IbadahTaskPrayerLink.dhuhr =>
        date.weekday == DateTime.friday
            ? SalahPrayer.jummah
            : SalahPrayer.dhuhr,
      IbadahTaskPrayerLink.asr => SalahPrayer.asr,
      IbadahTaskPrayerLink.maghrib => SalahPrayer.maghrib,
      IbadahTaskPrayerLink.isha => SalahPrayer.isha,
    };
  }

  String get storageValue {
    return switch (this) {
      IbadahTaskPrayerLink.none => 'none',
      IbadahTaskPrayerLink.anyPrayer => 'any',
      IbadahTaskPrayerLink.fajr => SalahPrayer.fajr.name,
      IbadahTaskPrayerLink.dhuhr => SalahPrayer.dhuhr.name,
      IbadahTaskPrayerLink.asr => SalahPrayer.asr.name,
      IbadahTaskPrayerLink.maghrib => SalahPrayer.maghrib.name,
      IbadahTaskPrayerLink.isha => SalahPrayer.isha.name,
    };
  }
}

IbadahTaskPrayerLink prayerLinkFromStorage(String? value) {
  return switch (value) {
    null => IbadahTaskPrayerLink.none,
    'none' => IbadahTaskPrayerLink.none,
    'any' => IbadahTaskPrayerLink.anyPrayer,
    'fajr' => IbadahTaskPrayerLink.fajr,
    'dhuhr' => IbadahTaskPrayerLink.dhuhr,
    'asr' => IbadahTaskPrayerLink.asr,
    'maghrib' => IbadahTaskPrayerLink.maghrib,
    'isha' => IbadahTaskPrayerLink.isha,
    _ => IbadahTaskPrayerLink.none,
  };
}
