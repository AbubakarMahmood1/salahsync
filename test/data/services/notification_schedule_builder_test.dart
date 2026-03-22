import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'package:salahsync/core/mosque/time_of_day_value.dart';
import 'package:salahsync/core/mosque/timing_rule.dart';
import 'package:salahsync/core/notifications/notification_kind.dart';
import 'package:salahsync/core/notifications/notification_preferences.dart';
import 'package:salahsync/core/notifications/notification_runtime_status.dart';
import 'package:salahsync/core/time/prayer_calculation_config.dart';
import 'package:salahsync/core/time/salah_prayer.dart';
import 'package:salahsync/data/db/app_database.dart';
import 'package:salahsync/data/services/notification_schedule_builder.dart';

void main() {
  setUpAll(() {
    tz.initializeTimeZones();
  });

  late NotificationScheduleBuilder builder;
  late PrayerCalculationConfig config;
  late Mosque mosque;

  setUp(() {
    builder = const NotificationScheduleBuilder();
    config = PrayerCalculationConfig.khanewalDefault().copyWith(
      ramadanModeOverride: true,
    );
    mosque = Mosque(
      id: 1,
      name: 'Masjid Al-Noor',
      area: 'Khanewal',
      latitude: null,
      longitude: null,
      isPrimary: true,
      isActive: true,
      notes: null,
      createdAt: '2026-03-22T00:00:00Z',
      updatedAt: '2026-03-22T00:00:00Z',
    );
  });

  test('buildWindow uses Jummah on Friday and generates deterministic ids', () {
    final preferences = NotificationPreferences.defaults().copyWith(
      perPrayer: {
        for (final prayer in kNotificationPreferencePrayers)
          prayer: const PrayerNotificationPreference(),
        SalahPrayer.fajr: const PrayerNotificationPreference(
          adhanEnabled: true,
          reminderEnabled: true,
          jamaatEnabled: true,
        ),
        SalahPrayer.jummah: const PrayerNotificationPreference(
          adhanEnabled: true,
          reminderEnabled: true,
          jamaatEnabled: true,
        ),
      },
      reminderOffsetMinutes: 15,
      sehriEnabled: true,
      iftarEnabled: true,
    );
    final rules = [
      TimingRule.offset(
        prayer: SalahPrayer.fajr,
        offsetMinutes: 25,
        priority: 1,
      ),
      TimingRule.fixed(
        prayer: SalahPrayer.jummah,
        fixedTime: const TimeOfDayValue(hour: 13, minute: 30),
        priority: 1,
      ),
    ];
    final now = tz.TZDateTime(tz.getLocation(config.timezoneName), 2026, 3, 27);

    final plans = builder.buildWindow(
      now: now,
      config: config,
      notificationMosque: mosque,
      rules: rules,
      preferences: preferences,
    );
    final rerun = builder.buildWindow(
      now: now,
      config: config,
      notificationMosque: mosque,
      rules: rules,
      preferences: preferences,
    );

    expect(plans.map((plan) => plan.id), rerun.map((plan) => plan.id));
    expect(
      plans.where(
        (plan) =>
            plan.prayer == SalahPrayer.jummah &&
            plan.kind == NotificationKind.adhan,
      ),
      isNotEmpty,
    );
    expect(plans.where((plan) => plan.prayer == SalahPrayer.dhuhr), isEmpty);
    expect(plans.any((plan) => plan.kind == NotificationKind.sehri), isTrue);
    expect(plans.any((plan) => plan.kind == NotificationKind.iftar), isTrue);

    final jummahJamaat = plans.firstWhere(
      (plan) =>
          plan.prayer == SalahPrayer.jummah &&
          plan.kind == NotificationKind.jamaat,
    );
    final jummahReminder = plans.firstWhere(
      (plan) =>
          plan.prayer == SalahPrayer.jummah &&
          plan.kind == NotificationKind.reminder,
    );
    expect(
      jummahReminder.scheduledAt,
      jummahJamaat.scheduledAt.subtract(const Duration(minutes: 15)),
    );
  });

  test(
    'buildWindow excludes past notifications and anything beyond 48 hours',
    () {
      final preferences = NotificationPreferences.defaults().copyWith(
        perPrayer: {
          for (final prayer in kNotificationPreferencePrayers)
            prayer: const PrayerNotificationPreference(
              adhanEnabled: true,
              jamaatEnabled: true,
            ),
        },
        reminderOffsetMinutes: 10,
      );
      final now = tz.TZDateTime(
        tz.getLocation(config.timezoneName),
        2026,
        3,
        27,
        15,
        0,
      );
      final cutoff = now.add(const Duration(hours: 48));

      final plans = builder.buildWindow(
        now: now,
        config: config,
        notificationMosque: mosque,
        rules: const [],
        preferences: preferences,
      );

      expect(plans, isNotEmpty);
      expect(plans.every((plan) => plan.scheduledAt.isAfter(now)), isTrue);
      expect(plans.every((plan) => !plan.scheduledAt.isAfter(cutoff)), isTrue);
    },
  );

  test('buildWindow stays under the release safety cap in the worst case', () {
    final preferences = NotificationPreferences.defaults().copyWith(
      perPrayer: {
        for (final prayer in kNotificationPreferencePrayers)
          prayer: const PrayerNotificationPreference(
            adhanEnabled: true,
            reminderEnabled: true,
            jamaatEnabled: true,
          ),
      },
      reminderOffsetMinutes: 15,
      sehriEnabled: true,
      iftarEnabled: true,
    );
    final rules = [
      for (final prayer in const [
        SalahPrayer.fajr,
        SalahPrayer.dhuhr,
        SalahPrayer.asr,
        SalahPrayer.maghrib,
        SalahPrayer.isha,
      ])
        TimingRule.offset(prayer: prayer, offsetMinutes: 20, priority: 1),
      TimingRule.fixed(
        prayer: SalahPrayer.jummah,
        fixedTime: const TimeOfDayValue(hour: 13, minute: 30),
        priority: 1,
      ),
    ];
    final now = tz.TZDateTime(
      tz.getLocation(config.timezoneName),
      2026,
      3,
      27,
      0,
    );

    final plans = builder.buildWindow(
      now: now,
      config: config,
      notificationMosque: mosque,
      rules: rules,
      preferences: preferences,
    );

    expect(
      plans.length,
      lessThanOrEqualTo(NotificationRuntimeStatus.recommendedPendingCap),
    );
  });
}
