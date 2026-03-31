import 'package:drift/native.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'package:salahsync/core/notifications/notification_preferences.dart';
import 'package:salahsync/core/notifications/notification_runtime_status.dart';
import 'package:salahsync/core/time/salah_prayer.dart';
import 'package:salahsync/data/db/app_database.dart';
import 'package:salahsync/data/repositories/mosque_repository.dart';
import 'package:salahsync/data/repositories/settings_repository.dart';
import 'package:salahsync/data/repositories/timing_rule_repository.dart';
import 'package:salahsync/data/seeding/app_seed_service.dart';
import 'package:salahsync/data/services/notification_sync_service.dart';

void main() {
  late AppDatabase database;
  late MosqueRepository mosqueRepository;
  late TimingRuleRepository timingRuleRepository;
  late SettingsRepository settingsRepository;
  late AppSeedService seedService;

  setUpAll(() {
    tz.initializeTimeZones();
  });

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    mosqueRepository = MosqueRepository(database);
    timingRuleRepository = TimingRuleRepository(database);
    settingsRepository = SettingsRepository(database);
    seedService = AppSeedService(
      mosqueRepository: mosqueRepository,
      timingRuleRepository: timingRuleRepository,
      settingsRepository: settingsRepository,
    );
  });

  tearDown(() async {
    await database.close();
  });

  test('syncWindow keeps scheduling after one plan throws', () async {
    await seedService.seedIfEmpty();
    await settingsRepository.saveNotificationPreferences(
      NotificationPreferences.defaults().copyWith(
        perPrayer: {
          for (final prayer in kNotificationPreferencePrayers)
            prayer: const PrayerNotificationPreference(),
          SalahPrayer.fajr: const PrayerNotificationPreference(
            adhanEnabled: true,
            jamaatEnabled: true,
          ),
          SalahPrayer.dhuhr: const PrayerNotificationPreference(
            adhanEnabled: true,
            jamaatEnabled: true,
          ),
          SalahPrayer.asr: const PrayerNotificationPreference(
            adhanEnabled: true,
          ),
        },
      ),
    );

    final plugin = _RecordingLocalNotificationsPlugin(failFirstSchedule: true);
    final service = _TestNotificationSyncService(
      mosqueRepository: mosqueRepository,
      timingRuleRepository: timingRuleRepository,
      settingsRepository: settingsRepository,
      plugin: plugin,
    );

    final result = await service.syncWindow(
      now: tz.TZDateTime(tz.getLocation('Asia/Karachi'), 2026, 3, 27, 0),
      reason: 'test',
    );

    expect(result.platformAvailable, isTrue);
    expect(plugin.didFailSchedule, isTrue);
    expect(plugin.scheduleAttempts, greaterThan(result.scheduledCount));
    expect(result.scheduledCount, greaterThan(0));
    expect(plugin.pending.length, result.scheduledCount);
  });
}

class _TestNotificationSyncService extends NotificationSyncService {
  _TestNotificationSyncService({
    required super.mosqueRepository,
    required super.timingRuleRepository,
    required super.settingsRepository,
    required super.plugin,
  });

  @override
  Future<void> ensureInitialized() async {}

  @override
  Future<NotificationRuntimeStatus> loadRuntimeStatus() async {
    return const NotificationRuntimeStatus(
      platformAvailable: true,
      notificationsEnabled: true,
      exactAlarmsSupported: true,
      exactAlarmsEnabled: true,
      managedPendingCount: 0,
    );
  }
}

class _RecordingLocalNotificationsPlugin
    implements FlutterLocalNotificationsPlugin {
  _RecordingLocalNotificationsPlugin({this.failFirstSchedule = false});

  final bool failFirstSchedule;
  final Map<int, PendingNotificationRequest> pending =
      <int, PendingNotificationRequest>{};
  int scheduleAttempts = 0;
  bool didFailSchedule = false;

  @override
  Future<void> cancel({required int id, String? tag}) async {
    pending.remove(id);
  }

  @override
  Future<List<PendingNotificationRequest>> pendingNotificationRequests() async {
    return pending.values.toList(growable: false);
  }

  @override
  T? resolvePlatformSpecificImplementation<
    T extends FlutterLocalNotificationsPlatform
  >() {
    return null;
  }

  @override
  Future<void> zonedSchedule({
    required int id,
    required tz.TZDateTime scheduledDate,
    required NotificationDetails notificationDetails,
    required AndroidScheduleMode androidScheduleMode,
    String? title,
    String? body,
    String? payload,
    DateTimeComponents? matchDateTimeComponents,
  }) async {
    scheduleAttempts++;
    if (failFirstSchedule && !didFailSchedule) {
      didFailSchedule = true;
      throw StateError('Synthetic scheduling failure');
    }

    pending[id] = PendingNotificationRequest(id, title, body, payload);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) {
    return super.noSuchMethod(invocation);
  }
}
