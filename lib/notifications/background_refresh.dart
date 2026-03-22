import 'dart:io';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:workmanager/workmanager.dart';

import '../data/services/notification_sync_service.dart';

const salahSyncNotificationRefreshTaskIdentifier =
    'com.salahsync.salahsync.notification.refresh';
const salahSyncNotificationRefreshTaskName = 'notification_refresh';

@pragma('vm:entry-point')
void salahSyncNotificationRefreshDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    WidgetsFlutterBinding.ensureInitialized();
    DartPluginRegistrant.ensureInitialized();
    tz.initializeTimeZones();

    final service = NotificationSyncService.background();
    try {
      await service.syncWindow(reason: 'background:$task');
      return true;
    } catch (_) {
      return false;
    } finally {
      await service.dispose();
    }
  });
}

Future<void> initializeBackgroundNotificationRefresh() async {
  if (kIsWeb || !(Platform.isAndroid || Platform.isIOS)) {
    return;
  }

  try {
    await Workmanager().initialize(salahSyncNotificationRefreshDispatcher);
    await Workmanager().registerPeriodicTask(
      salahSyncNotificationRefreshTaskIdentifier,
      salahSyncNotificationRefreshTaskName,
      frequency: const Duration(hours: 12),
      existingWorkPolicy: ExistingPeriodicWorkPolicy.update,
    );
  } on MissingPluginException {
    return;
  } on PlatformException {
    return;
  }
}
