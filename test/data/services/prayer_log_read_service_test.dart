import 'package:flutter_test/flutter_test.dart';

import 'package:salahsync/core/prayer_log/prayer_log_status.dart';
import 'package:salahsync/core/time/salah_prayer.dart';
import 'package:salahsync/data/models/prayer_log_record.dart';
import 'package:salahsync/data/services/prayer_log_read_service.dart';

void main() {
  const service = PrayerLogReadService();

  test('Friday day model swaps dhuhr for jummah and builds summaries', () {
    final model = service.buildDay(
      date: DateTime(2026, 4, 3),
      dayEntries: [
        PrayerLogRecord(
          id: 1,
          date: DateTime(2026, 4, 3),
          prayer: SalahPrayer.jummah,
          status: PrayerLogStatus.jamaat,
          mosqueId: null,
          notes: null,
          loggedAt: DateTime(2026, 4, 3, 12, 0),
        ),
      ],
      weekEntries: [
        PrayerLogRecord(
          id: 1,
          date: DateTime(2026, 4, 3),
          prayer: SalahPrayer.jummah,
          status: PrayerLogStatus.jamaat,
          mosqueId: null,
          notes: null,
          loggedAt: DateTime(2026, 4, 3, 12, 0),
        ),
        PrayerLogRecord(
          id: 2,
          date: DateTime(2026, 4, 2),
          prayer: SalahPrayer.maghrib,
          status: PrayerLogStatus.missed,
          mosqueId: null,
          notes: null,
          loggedAt: DateTime(2026, 4, 2, 18, 0),
        ),
      ],
      monthEntries: [
        PrayerLogRecord(
          id: 1,
          date: DateTime(2026, 4, 3),
          prayer: SalahPrayer.jummah,
          status: PrayerLogStatus.jamaat,
          mosqueId: null,
          notes: null,
          loggedAt: DateTime(2026, 4, 3, 12, 0),
        ),
      ],
      mosques: const [],
    );

    expect(model.rows.map((row) => row.prayer), contains(SalahPrayer.jummah));
    expect(
      model.rows.map((row) => row.prayer),
      isNot(contains(SalahPrayer.dhuhr)),
    );
    expect(model.weekSummary.jamaat, 1);
    expect(model.weekSummary.missed, 1);
    expect(model.monthSummary.total, 1);
  });
}
