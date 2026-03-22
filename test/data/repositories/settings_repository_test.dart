import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz;

import 'package:salahsync/core/notifications/notification_preferences.dart';
import 'package:salahsync/core/settings/app_theme_mode.dart';
import 'package:salahsync/core/time/prayer_calculation_config.dart';
import 'package:salahsync/core/time/salah_prayer.dart';
import 'package:salahsync/core/time/timezone_name.dart';
import 'package:salahsync/data/db/app_database.dart';
import 'package:salahsync/data/models/app_setting_keys.dart';
import 'package:salahsync/data/repositories/settings_repository.dart';

void main() {
  late AppDatabase database;
  late SettingsRepository repository;

  setUpAll(() {
    tz.initializeTimeZones();
  });

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    repository = SettingsRepository(database);
  });

  tearDown(() async {
    await database.close();
  });

  test('seedDefaults stores the expected baseline settings', () async {
    await repository.seedDefaults();

    final config = await repository.loadPrayerCalculationConfig();
    final notificationPreferences = await repository
        .loadNotificationPreferences();

    expect(config.method, PrayerCalculationMethodChoice.karachi);
    expect(config.asrSchool, AsrJuristicSchool.hanafi);
    expect(config.imsakOffsetMinutes, 10);
    expect(config.coordinates.latitude, 30.3017);
    expect(config.timezoneName, 'Asia/Karachi');
    expect(notificationPreferences.reminderOffsetMinutes, 15);
    expect(
      notificationPreferences.forPrayer(SalahPrayer.fajr).adhanEnabled,
      isFalse,
    );
  });

  test('savePrayerCalculationConfig persists overrides', () async {
    final config = PrayerCalculationConfig.khanewalDefault().copyWith(
      method: PrayerCalculationMethodChoice.muslimWorldLeague,
      asrSchool: AsrJuristicSchool.shafi,
      ishaEndConvention: IshaEndConvention.fajr,
      imsakOffsetMinutes: 12,
      adjustments: const PrayerAdjustments(
        fajr: 1,
        sunrise: 2,
        dhuhr: 3,
        asr: 4,
        maghrib: 5,
        isha: 6,
      ),
      hijriOffsetDays: 1,
      ramadanModeOverride: true,
    );

    await repository.savePrayerCalculationConfig(config);
    final loaded = await repository.loadPrayerCalculationConfig();

    expect(loaded.method, PrayerCalculationMethodChoice.muslimWorldLeague);
    expect(loaded.asrSchool, AsrJuristicSchool.shafi);
    expect(loaded.ishaEndConvention, IshaEndConvention.fajr);
    expect(loaded.imsakOffsetMinutes, 12);
    expect(loaded.adjustments.fajr, 1);
    expect(loaded.adjustments.isha, 6);
    expect(loaded.hijriOffsetDays, 1);
    expect(loaded.ramadanModeOverride, isTrue);
  });

  test('saveNotificationPreferences persists per-prayer toggles', () async {
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
          jamaatEnabled: true,
        ),
      },
      reminderOffsetMinutes: 20,
      sehriEnabled: true,
      iftarEnabled: true,
      privacyMode: NotificationPrivacyMode.prayerNameOnly,
    );

    await repository.saveNotificationPreferences(preferences);
    final loaded = await repository.loadNotificationPreferences();

    expect(loaded.reminderOffsetMinutes, 20);
    expect(loaded.sehriEnabled, isTrue);
    expect(loaded.iftarEnabled, isTrue);
    expect(loaded.privacyMode, NotificationPrivacyMode.prayerNameOnly);
    expect(loaded.forPrayer(SalahPrayer.fajr).reminderEnabled, isTrue);
    expect(loaded.forPrayer(SalahPrayer.jummah).jamaatEnabled, isTrue);
    expect(loaded.forPrayer(SalahPrayer.asr).adhanEnabled, isFalse);
  });

  test('saveThemeMode persists the selected app theme', () async {
    await repository.saveThemeMode(AppThemeMode.dark);

    final loaded = await repository.loadThemeMode();

    expect(loaded, AppThemeMode.dark);
  });

  test(
    'loadPrayerCalculationConfig falls back to the default timezone for invalid persisted values',
    () async {
      await repository.put(
        AppSettingKeys.defaultCoordinates,
        jsonEncode({
          'latitude': 30.3017,
          'longitude': 71.9321,
          'locationName': 'Broken timezone payload',
          'timezoneName': 'Mars/Olympus',
        }),
      );

      final loaded = await repository.loadPrayerCalculationConfig();

      expect(loaded.timezoneName, kDefaultTimezoneName);
    },
  );

  test(
    'savePrayerCalculationConfig sanitizes invalid timezone names',
    () async {
      final invalidConfig = PrayerCalculationConfig.khanewalDefault().copyWith(
        timezoneName: 'Mars/Olympus',
      );

      await repository.savePrayerCalculationConfig(invalidConfig);
      final settings = await repository.getAll();
      final payload =
          jsonDecode(settings[AppSettingKeys.defaultCoordinates]!)
              as Map<String, dynamic>;

      expect(payload['timezoneName'], kDefaultTimezoneName);
    },
  );
}
