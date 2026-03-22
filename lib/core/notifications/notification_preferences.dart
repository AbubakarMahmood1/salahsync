import '../time/salah_prayer.dart';

enum NotificationPrivacyMode {
  fullDetails('Full details'),
  prayerNameOnly('Prayer name only');

  const NotificationPrivacyMode(this.label);

  final String label;
}

class PrayerNotificationPreference {
  const PrayerNotificationPreference({
    this.adhanEnabled = false,
    this.reminderEnabled = false,
    this.jamaatEnabled = false,
  });

  final bool adhanEnabled;
  final bool reminderEnabled;
  final bool jamaatEnabled;

  PrayerNotificationPreference copyWith({
    bool? adhanEnabled,
    bool? reminderEnabled,
    bool? jamaatEnabled,
  }) {
    return PrayerNotificationPreference(
      adhanEnabled: adhanEnabled ?? this.adhanEnabled,
      reminderEnabled: reminderEnabled ?? this.reminderEnabled,
      jamaatEnabled: jamaatEnabled ?? this.jamaatEnabled,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'adhanEnabled': adhanEnabled,
      'reminderEnabled': reminderEnabled,
      'jamaatEnabled': jamaatEnabled,
    };
  }

  factory PrayerNotificationPreference.fromJson(
    Map<String, dynamic> json, {
    required PrayerNotificationPreference fallback,
  }) {
    return PrayerNotificationPreference(
      adhanEnabled: _boolFromJson(
        json['adhanEnabled'],
        fallback: fallback.adhanEnabled,
      ),
      reminderEnabled: _boolFromJson(
        json['reminderEnabled'],
        fallback: fallback.reminderEnabled,
      ),
      jamaatEnabled: _boolFromJson(
        json['jamaatEnabled'],
        fallback: fallback.jamaatEnabled,
      ),
    );
  }
}

class NotificationPreferences {
  NotificationPreferences({
    required Map<SalahPrayer, PrayerNotificationPreference> perPrayer,
    required this.reminderOffsetMinutes,
    required this.sehriEnabled,
    required this.iftarEnabled,
    required this.privacyMode,
  }) : perPrayer = Map.unmodifiable(perPrayer);

  factory NotificationPreferences.defaults() {
    return NotificationPreferences(
      perPrayer: {
        for (final prayer in kNotificationPreferencePrayers)
          prayer: const PrayerNotificationPreference(),
      },
      reminderOffsetMinutes: 15,
      sehriEnabled: false,
      iftarEnabled: false,
      privacyMode: NotificationPrivacyMode.fullDetails,
    );
  }

  final Map<SalahPrayer, PrayerNotificationPreference> perPrayer;
  final int reminderOffsetMinutes;
  final bool sehriEnabled;
  final bool iftarEnabled;
  final NotificationPrivacyMode privacyMode;

  PrayerNotificationPreference forPrayer(SalahPrayer prayer) {
    return perPrayer[prayer] ?? const PrayerNotificationPreference();
  }

  NotificationPreferences copyWith({
    Map<SalahPrayer, PrayerNotificationPreference>? perPrayer,
    int? reminderOffsetMinutes,
    bool? sehriEnabled,
    bool? iftarEnabled,
    NotificationPrivacyMode? privacyMode,
  }) {
    return NotificationPreferences(
      perPrayer: perPrayer ?? this.perPrayer,
      reminderOffsetMinutes:
          reminderOffsetMinutes ?? this.reminderOffsetMinutes,
      sehriEnabled: sehriEnabled ?? this.sehriEnabled,
      iftarEnabled: iftarEnabled ?? this.iftarEnabled,
      privacyMode: privacyMode ?? this.privacyMode,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'prayers': {
        for (final prayer in kNotificationPreferencePrayers)
          prayer.name: forPrayer(prayer).toJson(),
      },
      'reminderOffsetMinutes': reminderOffsetMinutes,
      'sehriEnabled': sehriEnabled,
      'iftarEnabled': iftarEnabled,
      'privacyMode': privacyMode.name,
    };
  }

  factory NotificationPreferences.fromJson(Map<String, dynamic> json) {
    final defaults = NotificationPreferences.defaults();
    final rawPrayerMap = json['prayers'];
    final prayerMap = rawPrayerMap is Map<String, dynamic>
        ? rawPrayerMap
        : rawPrayerMap is Map
        ? rawPrayerMap.map((key, value) => MapEntry(key.toString(), value))
        : const <String, dynamic>{};

    final perPrayer = <SalahPrayer, PrayerNotificationPreference>{};
    for (final prayer in kNotificationPreferencePrayers) {
      final rawValue = prayerMap[prayer.name] ?? json[prayer.name];
      final payload = rawValue is Map<String, dynamic>
          ? rawValue
          : rawValue is Map
          ? rawValue.map((key, value) => MapEntry(key.toString(), value))
          : const <String, dynamic>{};
      perPrayer[prayer] = PrayerNotificationPreference.fromJson(
        payload,
        fallback: defaults.forPrayer(prayer),
      );
    }

    return NotificationPreferences(
      perPrayer: perPrayer,
      reminderOffsetMinutes: _intFromJson(
        json['reminderOffsetMinutes'],
        fallback: defaults.reminderOffsetMinutes,
      ),
      sehriEnabled: _boolFromJson(
        json['sehriEnabled'],
        fallback: defaults.sehriEnabled,
      ),
      iftarEnabled: _boolFromJson(
        json['iftarEnabled'],
        fallback: defaults.iftarEnabled,
      ),
      privacyMode: _enumFromJson(
        json['privacyMode'],
        values: NotificationPrivacyMode.values,
        fallback: defaults.privacyMode,
      ),
    );
  }

  String get fingerprint {
    final segments = <String>[
      reminderOffsetMinutes.toString(),
      sehriEnabled.toString(),
      iftarEnabled.toString(),
      privacyMode.name,
    ];
    for (final prayer in kNotificationPreferencePrayers) {
      final preference = forPrayer(prayer);
      segments.add(
        '${prayer.name}:${preference.adhanEnabled}:${preference.reminderEnabled}:${preference.jamaatEnabled}',
      );
    }
    return segments.join('|');
  }
}

T _enumFromJson<T extends Enum>(
  Object? value, {
  required List<T> values,
  required T fallback,
}) {
  if (value is String) {
    for (final candidate in values) {
      if (candidate.name == value) {
        return candidate;
      }
    }
  }
  return fallback;
}

const List<SalahPrayer> kNotificationPreferencePrayers = [
  SalahPrayer.fajr,
  SalahPrayer.dhuhr,
  SalahPrayer.asr,
  SalahPrayer.maghrib,
  SalahPrayer.isha,
  SalahPrayer.jummah,
];

bool _boolFromJson(Object? value, {required bool fallback}) {
  return switch (value) {
    final bool typed => typed,
    final String typed => typed.toLowerCase() == 'true',
    _ => fallback,
  };
}

int _intFromJson(Object? value, {required int fallback}) {
  return switch (value) {
    final int typed => typed,
    final num typed => typed.toInt(),
    final String typed => int.tryParse(typed) ?? fallback,
    _ => fallback,
  };
}
