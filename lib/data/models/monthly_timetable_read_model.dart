import '../../core/mosque/resolved_timing.dart';
import '../../core/time/prayer_times_snapshot.dart';
import '../db/app_database.dart';

class MonthlyTimetableReadModel {
  const MonthlyTimetableReadModel({
    required this.month,
    required this.primaryMosque,
    required this.days,
  });

  final DateTime month;
  final Mosque? primaryMosque;
  final List<MonthlyTimetableDay> days;
}

class MonthlyTimetableDay {
  const MonthlyTimetableDay({required this.snapshot, this.jummahTiming});

  final PrayerTimesSnapshot snapshot;
  final ResolvedTiming? jummahTiming;
}
