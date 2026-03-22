import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/data/latest.dart' as tz;

import 'app/salah_sync_app.dart';
import 'notifications/background_refresh.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones();
  await initializeBackgroundNotificationRefresh();
  runApp(const ProviderScope(child: SalahSyncApp()));
}
