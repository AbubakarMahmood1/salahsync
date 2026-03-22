import 'salah_prayer.dart';

class PrayerWindow {
  const PrayerWindow({
    required this.prayer,
    required this.start,
    required this.end,
  });

  final SalahPrayer prayer;
  final DateTime start;
  final DateTime end;

  bool contains(DateTime moment) {
    return !moment.isBefore(start) && moment.isBefore(end);
  }
}
