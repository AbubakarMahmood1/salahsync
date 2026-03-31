import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'package:salahsync/data/db/app_database.dart';
import 'package:salahsync/data/repositories/mosque_repository.dart';
import 'package:salahsync/data/repositories/settings_repository.dart';
import 'package:salahsync/data/repositories/timing_rule_repository.dart';
import 'package:salahsync/data/seeding/app_seed_service.dart';
import 'package:salahsync/data/services/home_widget_sync_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('home_widget');
  late AppDatabase database;
  late HomeWidgetSyncService service;
  late List<MethodCall> calls;

  setUpAll(() {
    tz.initializeTimeZones();
  });

  setUp(() async {
    database = AppDatabase(NativeDatabase.memory());
    final mosqueRepository = MosqueRepository(database);
    final timingRuleRepository = TimingRuleRepository(database);
    final settingsRepository = SettingsRepository(database);
    final seedService = AppSeedService(
      mosqueRepository: mosqueRepository,
      timingRuleRepository: timingRuleRepository,
      settingsRepository: settingsRepository,
    );
    await seedService.seedIfEmpty();

    calls = <MethodCall>[];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          calls.add(call);
          return true;
        });

    service = HomeWidgetSyncService(
      mosqueRepository: mosqueRepository,
      timingRuleRepository: timingRuleRepository,
      settingsRepository: settingsRepository,
    );
  });

  tearDown(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
    await database.close();
  });

  test('sync writes schedule data and requests widget update', () async {
    final now = tz.TZDateTime(tz.getLocation('Asia/Karachi'), 2026, 3, 31, 12);
    await service.sync(now: now, reason: 'test');

    final saveCalls = calls.where((call) => call.method == 'saveWidgetData');
    expect(saveCalls.length, greaterThanOrEqualTo(5));
    final scheduleCall = saveCalls.firstWhere(
      (call) => (call.arguments as Map)['id'] == 'widget_schedule_json',
    );
    final scheduleJson = (scheduleCall.arguments as Map)['data'] as String;
    final schedule = jsonDecode(scheduleJson) as List<dynamic>;
    expect(schedule, isNotEmpty);

    expect(calls.any((call) => call.method == 'updateWidget'), isTrue);
  });
}
