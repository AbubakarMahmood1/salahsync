import 'dart:convert';

import 'package:drift/drift.dart';

import '../../core/notifications/notification_preferences.dart';
import '../../core/settings/app_theme_mode.dart';
import '../db/app_database.dart';
import '../models/app_setting_keys.dart';
import '../../core/time/geo_coordinates.dart';
import '../../core/time/prayer_calculation_config.dart';

class SettingsRepository {
  SettingsRepository(this._db);

  final AppDatabase _db;

  Future<Map<String, String>> getAll() async {
    final rows = await _db.select(_db.appSettingsEntries).get();
    return {for (final row in rows) row.key: row.value};
  }

  Stream<Map<String, String>> watchAll() {
    return _db.select(_db.appSettingsEntries).watch().map((rows) {
      return {for (final row in rows) row.key: row.value};
    });
  }

  Stream<AppThemeMode> watchThemeMode() {
    return (_db.select(_db.appSettingsEntries)
          ..where((table) => table.key.equals(AppSettingKeys.themeMode))
          ..limit(1))
        .watchSingleOrNull()
        .map(
          (row) => _parseThemeMode(row?.value, fallback: AppThemeMode.system),
        );
  }

  Future<void> put(String key, String value) async {
    await _db
        .into(_db.appSettingsEntries)
        .insertOnConflictUpdate(
          AppSettingsEntriesCompanion(key: Value(key), value: Value(value)),
        );
  }

  Future<void> putMany(Map<String, String> values) async {
    await _db.batch((batch) {
      for (final entry in values.entries) {
        batch.insert(
          _db.appSettingsEntries,
          AppSettingsEntriesCompanion(
            key: Value(entry.key),
            value: Value(entry.value),
          ),
          mode: InsertMode.insertOrReplace,
        );
      }
    });
  }

  Future<void> seedDefaults() async {
    final current = await getAll();
    final defaults = _defaultValues();
    final missing = <String, String>{};

    for (final entry in defaults.entries) {
      if (!current.containsKey(entry.key)) {
        missing[entry.key] = entry.value;
      }
    }

    if (missing.isNotEmpty) {
      await putMany(missing);
    }
  }

  Future<PrayerCalculationConfig> loadPrayerCalculationConfig() async {
    final current = await getAll();
    final config = PrayerCalculationConfig.khanewalDefault();
    final coordinatePayload = _parseJsonObject(
      current[AppSettingKeys.defaultCoordinates],
    );
    final adjustmentsPayload = _parseJsonObject(
      current[AppSettingKeys.prayerAdjustments],
    );
    final coordinates = _parseCoordinates(
      coordinatePayload,
      fallback: config.coordinates,
    );

    return config.copyWith(
      method: _parseMethod(
        current[AppSettingKeys.calculationMethod],
        fallback: config.method,
      ),
      asrSchool: _parseAsrSchool(
        current[AppSettingKeys.asrSchool],
        fallback: config.asrSchool,
      ),
      ishaEndConvention: _parseIshaEndConvention(
        current[AppSettingKeys.ishaEndConvention],
        fallback: config.ishaEndConvention,
      ),
      imsakOffsetMinutes:
          int.tryParse(current[AppSettingKeys.imsakOffset] ?? '') ??
          config.imsakOffsetMinutes,
      adjustments: _parsePrayerAdjustments(
        adjustmentsPayload,
        fallback: config.adjustments,
      ),
      hijriOffsetDays:
          int.tryParse(current[AppSettingKeys.hijriDateOffset] ?? '') ??
          config.hijriOffsetDays,
      ramadanModeOverride: _parseNullableBool(
        current[AppSettingKeys.ramadanModeOverride],
      ),
      coordinates: coordinates,
      locationName:
          coordinatePayload['locationName'] as String? ?? config.locationName,
      timezoneName:
          coordinatePayload['timezoneName'] as String? ?? config.timezoneName,
    );
  }

  Future<NotificationPreferences> loadNotificationPreferences() async {
    final current = await getAll();
    final payload = _parseJsonObject(current[AppSettingKeys.notificationPrefs]);
    return NotificationPreferences.fromJson(payload);
  }

  Future<AppThemeMode> loadThemeMode() async {
    final current = await getAll();
    return _parseThemeMode(
      current[AppSettingKeys.themeMode],
      fallback: AppThemeMode.system,
    );
  }

  Future<void> savePrayerCalculationConfig(
    PrayerCalculationConfig config,
  ) async {
    await putMany({
      AppSettingKeys.calculationMethod: config.method.name,
      AppSettingKeys.asrSchool: config.asrSchool.name,
      AppSettingKeys.imsakOffset: config.imsakOffsetMinutes.toString(),
      AppSettingKeys.prayerAdjustments: jsonEncode({
        'fajr': config.adjustments.fajr,
        'sunrise': config.adjustments.sunrise,
        'dhuhr': config.adjustments.dhuhr,
        'asr': config.adjustments.asr,
        'maghrib': config.adjustments.maghrib,
        'isha': config.adjustments.isha,
      }),
      AppSettingKeys.ishaEndConvention: config.ishaEndConvention.name,
      AppSettingKeys.hijriDateOffset: config.hijriOffsetDays.toString(),
      AppSettingKeys.ramadanModeOverride:
          config.ramadanModeOverride?.toString() ?? 'null',
      AppSettingKeys.defaultCoordinates: jsonEncode({
        'latitude': config.coordinates.latitude,
        'longitude': config.coordinates.longitude,
        'locationName': config.locationName,
        'timezoneName': config.timezoneName,
      }),
    });
  }

  Future<void> saveNotificationPreferences(
    NotificationPreferences preferences,
  ) async {
    await put(
      AppSettingKeys.notificationPrefs,
      jsonEncode(preferences.toJson()),
    );
  }

  Future<void> saveThemeMode(AppThemeMode themeMode) async {
    await put(AppSettingKeys.themeMode, themeMode.name);
  }

  Future<void> resetAll() async {
    await (_db.delete(_db.appSettingsEntries)).go();
  }

  Map<String, String> _defaultValues() {
    return {
      AppSettingKeys.calculationMethod:
          PrayerCalculationMethodChoice.karachi.name,
      AppSettingKeys.asrSchool: AsrJuristicSchool.hanafi.name,
      AppSettingKeys.imsakOffset: '10',
      AppSettingKeys.prayerAdjustments: jsonEncode({
        'fajr': 0,
        'sunrise': 0,
        'dhuhr': 0,
        'asr': 0,
        'maghrib': 0,
        'isha': 0,
      }),
      AppSettingKeys.ishaEndConvention: IshaEndConvention.midnight.name,
      AppSettingKeys.themeMode: 'system',
      AppSettingKeys.notificationPrefs: jsonEncode(
        NotificationPreferences.defaults().toJson(),
      ),
      AppSettingKeys.ramadanModeEnabled: 'false',
      AppSettingKeys.ramadanModeOverride: 'null',
      AppSettingKeys.hijriDateOffset: '0',
      AppSettingKeys.defaultCoordinates: jsonEncode({
        'latitude': 30.3017,
        'longitude': 71.9321,
        'locationName': 'Khanewal, Pakistan',
        'timezoneName': 'Asia/Karachi',
      }),
    };
  }

  Map<String, dynamic> _parseJsonObject(String? value) {
    if (value == null) {
      return const <String, dynamic>{};
    }

    try {
      return jsonDecode(value) as Map<String, dynamic>;
    } on FormatException {
      return const <String, dynamic>{};
    }
  }

  PrayerAdjustments _parsePrayerAdjustments(
    Map<String, dynamic> json, {
    required PrayerAdjustments fallback,
  }) {
    int valueFor(String key, int fallbackValue) {
      return (json[key] as num?)?.toInt() ?? fallbackValue;
    }

    return PrayerAdjustments(
      fajr: valueFor('fajr', fallback.fajr),
      sunrise: valueFor('sunrise', fallback.sunrise),
      dhuhr: valueFor('dhuhr', fallback.dhuhr),
      asr: valueFor('asr', fallback.asr),
      maghrib: valueFor('maghrib', fallback.maghrib),
      isha: valueFor('isha', fallback.isha),
    );
  }

  GeoCoordinates _parseCoordinates(
    Map<String, dynamic> json, {
    required GeoCoordinates fallback,
  }) {
    final latitude = json['latitude'] as num?;
    final longitude = json['longitude'] as num?;
    if (latitude == null || longitude == null) {
      return fallback;
    }

    return GeoCoordinates(
      latitude: latitude.toDouble(),
      longitude: longitude.toDouble(),
    );
  }

  PrayerCalculationMethodChoice _parseMethod(
    String? value, {
    required PrayerCalculationMethodChoice fallback,
  }) {
    if (value == null) {
      return fallback;
    }

    return _enumByName(PrayerCalculationMethodChoice.values, value) ?? fallback;
  }

  AsrJuristicSchool _parseAsrSchool(
    String? value, {
    required AsrJuristicSchool fallback,
  }) {
    if (value == null) {
      return fallback;
    }

    return _enumByName(AsrJuristicSchool.values, value) ?? fallback;
  }

  IshaEndConvention _parseIshaEndConvention(
    String? value, {
    required IshaEndConvention fallback,
  }) {
    if (value == null) {
      return fallback;
    }

    return _enumByName(IshaEndConvention.values, value) ?? fallback;
  }

  bool? _parseNullableBool(String? value) {
    if (value == null || value == 'null') {
      return null;
    }
    return value.toLowerCase() == 'true';
  }

  AppThemeMode _parseThemeMode(
    String? value, {
    required AppThemeMode fallback,
  }) {
    if (value == null) {
      return fallback;
    }

    return _enumByName(AppThemeMode.values, value) ?? fallback;
  }

  T? _enumByName<T extends Enum>(Iterable<T> values, String name) {
    for (final value in values) {
      if (value.name == name) {
        return value;
      }
    }
    return null;
  }
}
