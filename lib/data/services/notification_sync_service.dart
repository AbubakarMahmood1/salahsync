import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

import '../../core/notifications/notification_kind.dart';
import '../../core/notifications/notification_runtime_status.dart';
import '../../core/notifications/notification_sync_result.dart';
import '../../core/notifications/scheduled_notification_plan.dart';
import '../db/app_database.dart';
import '../repositories/mosque_repository.dart';
import '../repositories/settings_repository.dart';
import '../repositories/timing_rule_repository.dart';
import 'notification_schedule_builder.dart';

class NotificationSyncService {
  NotificationSyncService({
    required MosqueRepository mosqueRepository,
    required TimingRuleRepository timingRuleRepository,
    required SettingsRepository settingsRepository,
    NotificationScheduleBuilder notificationScheduleBuilder =
        const NotificationScheduleBuilder(),
    FlutterLocalNotificationsPlugin? plugin,
  }) : _mosqueRepository = mosqueRepository,
       _timingRuleRepository = timingRuleRepository,
       _settingsRepository = settingsRepository,
       _notificationScheduleBuilder = notificationScheduleBuilder,
       _plugin = plugin ?? FlutterLocalNotificationsPlugin(),
       _ownedDatabase = null;

  factory NotificationSyncService.background({
    FlutterLocalNotificationsPlugin? plugin,
  }) {
    final database = AppDatabase.local();
    return NotificationSyncService._background(
      database: database,
      plugin: plugin ?? FlutterLocalNotificationsPlugin(),
    );
  }

  NotificationSyncService._background({
    required AppDatabase database,
    required FlutterLocalNotificationsPlugin plugin,
  }) : _mosqueRepository = MosqueRepository(database),
       _timingRuleRepository = TimingRuleRepository(database),
       _settingsRepository = SettingsRepository(database),
       _notificationScheduleBuilder = const NotificationScheduleBuilder(),
       _plugin = plugin,
       _ownedDatabase = database;

  final MosqueRepository _mosqueRepository;
  final TimingRuleRepository _timingRuleRepository;
  final SettingsRepository _settingsRepository;
  final NotificationScheduleBuilder _notificationScheduleBuilder;
  final FlutterLocalNotificationsPlugin _plugin;
  final AppDatabase? _ownedDatabase;

  bool _initialized = false;
  bool _platformAvailable = true;

  Future<void> dispose() async {
    await _ownedDatabase?.close();
  }

  Future<void> ensureInitialized() async {
    if (_initialized) {
      return;
    }
    if (kIsWeb || !(Platform.isAndroid || Platform.isIOS)) {
      _platformAvailable = false;
      _initialized = true;
      return;
    }

    try {
      const initializationSettings = InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      );
      await _plugin.initialize(settings: initializationSettings);
      await _createChannels();
      _initialized = true;
    } on MissingPluginException {
      _platformAvailable = false;
      _initialized = true;
    }
  }

  Future<NotificationRuntimeStatus> loadRuntimeStatus() async {
    await ensureInitialized();
    if (!_platformAvailable) {
      return const NotificationRuntimeStatus.unavailable();
    }

    try {
      final pendingRequests = await _plugin.pendingNotificationRequests();
      final managedPendingCount = pendingRequests
          .where(
            (request) => request.payload?.startsWith(_managedPrefix) ?? false,
          )
          .length;

      if (Platform.isAndroid) {
        final android = _androidNotifications;
        return NotificationRuntimeStatus(
          platformAvailable: android != null,
          notificationsEnabled:
              await android?.areNotificationsEnabled() ?? false,
          exactAlarmsSupported: true,
          exactAlarmsEnabled:
              await android?.canScheduleExactNotifications() ?? true,
          managedPendingCount: managedPendingCount,
        );
      }

      if (Platform.isIOS) {
        final permissions = await _iosNotifications?.checkPermissions();
        return NotificationRuntimeStatus(
          platformAvailable: true,
          notificationsEnabled: permissions?.isEnabled ?? false,
          exactAlarmsSupported: false,
          exactAlarmsEnabled: false,
          managedPendingCount: managedPendingCount,
        );
      }
    } on MissingPluginException {
      _platformAvailable = false;
    }

    return const NotificationRuntimeStatus.unavailable();
  }

  Future<bool> requestNotificationPermission() async {
    await ensureInitialized();
    if (!_platformAvailable) {
      return false;
    }

    try {
      if (Platform.isAndroid) {
        return await _androidNotifications?.requestNotificationsPermission() ??
            false;
      }
      if (Platform.isIOS) {
        return await _iosNotifications?.requestPermissions(
              alert: true,
              badge: true,
              sound: true,
            ) ??
            false;
      }
    } on MissingPluginException {
      _platformAvailable = false;
    }

    return false;
  }

  Future<bool> requestExactAlarmPermission() async {
    await ensureInitialized();
    if (!_platformAvailable || !Platform.isAndroid) {
      return false;
    }

    try {
      return await _androidNotifications?.requestExactAlarmsPermission() ??
          false;
    } on MissingPluginException {
      _platformAvailable = false;
      return false;
    }
  }

  Future<NotificationSyncResult> syncWindow({
    DateTime? now,
    String reason = 'manual',
  }) async {
    await ensureInitialized();
    if (!_platformAvailable) {
      return NotificationSyncResult.unavailable();
    }

    try {
      final runtimeStatus = await loadRuntimeStatus();
      final notificationMosque = await _mosqueRepository.getPrimary();
      if (notificationMosque == null || !notificationMosque.isActive) {
        final cancelledCount = await _cancelManagedNotifications();
        return NotificationSyncResult(
          platformAvailable: true,
          scheduledCount: 0,
          cancelledCount: cancelledCount,
          runtimeStatus: runtimeStatus,
        );
      }

      final config = await _settingsRepository.loadPrayerCalculationConfig();
      final preferences = await _settingsRepository
          .loadNotificationPreferences();
      final rules = await _timingRuleRepository.listDomainForMosque(
        notificationMosque.id,
      );

      var plans = _notificationScheduleBuilder.buildWindow(
        now: now ?? DateTime.now(),
        config: config,
        notificationMosque: notificationMosque,
        rules: rules,
        preferences: preferences,
      );
      if (plans.length > 50) {
        plans = plans.take(50).toList(growable: false);
      }

      final pendingRequests = await _plugin.pendingNotificationRequests();
      final managedIds = pendingRequests
          .where(
            (request) => request.payload?.startsWith(_managedPrefix) ?? false,
          )
          .map((request) => request.id)
          .toSet();
      final desiredIds = plans.map((plan) => plan.id).toSet();

      var cancelledCount = 0;
      for (final staleId in managedIds.difference(desiredIds)) {
        await _plugin.cancel(id: staleId);
        cancelledCount++;
      }

      final useExactScheduling = runtimeStatus.isUsingExactScheduling;
      for (final plan in plans) {
        await _schedulePlan(
          plan,
          timezoneName: config.timezoneName,
          useExactScheduling: useExactScheduling,
        );
      }

      debugPrint(
        'NotificationSyncService.syncWindow($reason) scheduled=${plans.length} cancelled=$cancelledCount exact=$useExactScheduling',
      );

      return NotificationSyncResult(
        platformAvailable: true,
        scheduledCount: plans.length,
        cancelledCount: cancelledCount,
        runtimeStatus: runtimeStatus,
      );
    } on MissingPluginException {
      _platformAvailable = false;
      return NotificationSyncResult.unavailable();
    }
  }

  Future<void> _createChannels() async {
    if (!Platform.isAndroid) {
      return;
    }

    final android = _androidNotifications;
    if (android == null) {
      return;
    }

    for (final kind in NotificationKind.values) {
      await android.createNotificationChannel(
        AndroidNotificationChannel(
          kind.channelId,
          kind.channelName,
          description: kind.channelDescription,
          importance: _importanceFor(kind),
        ),
      );
    }
  }

  Future<void> _schedulePlan(
    ScheduledNotificationPlan plan, {
    required String timezoneName,
    required bool useExactScheduling,
  }) async {
    final location = tz.getLocation(timezoneName);
    final scheduledDate = tz.TZDateTime.from(plan.scheduledAt, location);

    await _plugin.zonedSchedule(
      id: plan.id,
      title: plan.title,
      body: plan.body,
      scheduledDate: scheduledDate,
      notificationDetails: _detailsFor(plan.kind),
      payload: plan.payload,
      androidScheduleMode: useExactScheduling
          ? AndroidScheduleMode.exactAllowWhileIdle
          : AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }

  NotificationDetails _detailsFor(NotificationKind kind) {
    return NotificationDetails(
      android: AndroidNotificationDetails(
        kind.channelId,
        kind.channelName,
        channelDescription: kind.channelDescription,
        importance: _importanceFor(kind),
        priority: _priorityFor(kind),
      ),
      iOS: DarwinNotificationDetails(
        threadIdentifier: 'salahsync_${kind.name}',
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );
  }

  Future<int> _cancelManagedNotifications() async {
    final pendingRequests = await _plugin.pendingNotificationRequests();
    final managed = pendingRequests
        .where(
          (request) => request.payload?.startsWith(_managedPrefix) ?? false,
        )
        .map((request) => request.id)
        .toList(growable: false);

    for (final id in managed) {
      await _plugin.cancel(id: id);
    }
    return managed.length;
  }

  AndroidFlutterLocalNotificationsPlugin? get _androidNotifications {
    return _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
  }

  IOSFlutterLocalNotificationsPlugin? get _iosNotifications {
    return _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();
  }
}

const _managedPrefix = 'salahsync:v1|';

Importance _importanceFor(NotificationKind kind) {
  return switch (kind) {
    NotificationKind.reminder => Importance.high,
    NotificationKind.adhan => Importance.high,
    NotificationKind.jamaat => Importance.high,
    NotificationKind.sehri => Importance.max,
    NotificationKind.iftar => Importance.high,
  };
}

Priority _priorityFor(NotificationKind kind) {
  return switch (kind) {
    NotificationKind.reminder => Priority.high,
    NotificationKind.adhan => Priority.high,
    NotificationKind.jamaat => Priority.high,
    NotificationKind.sehri => Priority.max,
    NotificationKind.iftar => Priority.high,
  };
}
