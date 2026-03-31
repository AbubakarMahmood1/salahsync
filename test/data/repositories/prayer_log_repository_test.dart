import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:salahsync/core/prayer_log/prayer_log_status.dart';
import 'package:salahsync/core/time/salah_prayer.dart';
import 'package:salahsync/data/db/app_database.dart';
import 'package:salahsync/data/models/prayer_log_draft.dart';
import 'package:salahsync/data/repositories/prayer_log_repository.dart';

void main() {
  late AppDatabase database;
  late PrayerLogRepository repository;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    repository = PrayerLogRepository(database);
  });

  tearDown(() async {
    await database.close();
  });

  test('save upserts by date and prayer', () async {
    final date = DateTime(2026, 4, 1);
    await repository.save(
      PrayerLogDraft(
        date: date,
        prayer: SalahPrayer.fajr,
        status: PrayerLogStatus.alone,
      ),
    );
    await repository.save(
      PrayerLogDraft(
        date: date,
        prayer: SalahPrayer.fajr,
        status: PrayerLogStatus.jamaat,
      ),
    );

    final rows = await repository.listForDate(date);
    expect(rows, hasLength(1));
    expect(rows.single.status, PrayerLogStatus.jamaat);
  });
}
