enum PrayerLogStatus {
  jamaat('Jamaat'),
  alone('Alone'),
  missed('Missed');

  const PrayerLogStatus(this.label);

  final String label;
}
