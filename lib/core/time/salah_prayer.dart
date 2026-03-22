enum SalahPrayer { imsak, fajr, sunrise, dhuhr, asr, maghrib, isha, jummah }

extension SalahPrayerX on SalahPrayer {
  String get label => switch (this) {
    SalahPrayer.imsak => 'Imsak',
    SalahPrayer.fajr => 'Fajr',
    SalahPrayer.sunrise => 'Sunrise',
    SalahPrayer.dhuhr => 'Dhuhr',
    SalahPrayer.asr => 'Asr',
    SalahPrayer.maghrib => 'Maghrib',
    SalahPrayer.isha => 'Isha',
    SalahPrayer.jummah => 'Jummah',
  };
}

const List<SalahPrayer> kSchedulePrayerOrder = <SalahPrayer>[
  SalahPrayer.imsak,
  SalahPrayer.fajr,
  SalahPrayer.sunrise,
  SalahPrayer.dhuhr,
  SalahPrayer.asr,
  SalahPrayer.maghrib,
  SalahPrayer.isha,
];

const List<SalahPrayer> kWindowPrayerOrder = <SalahPrayer>[
  SalahPrayer.fajr,
  SalahPrayer.dhuhr,
  SalahPrayer.asr,
  SalahPrayer.maghrib,
  SalahPrayer.isha,
];
