import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../core/notifications/notification_preferences.dart';
import '../core/notifications/notification_runtime_status.dart';
import '../core/notifications/notification_sync_result.dart';
import '../core/ibadah/ibadah_task_repeat_type.dart';
import '../core/settings/app_theme_mode.dart';
import '../core/time/qibla_service.dart';
import '../core/time/prayer_calculation_config.dart';
import '../core/time/prayer_time_service.dart';
import '../core/utils/date_key.dart';
import '../data/db/app_database.dart';
import '../data/models/ibadah_planner_read_model.dart';
import '../data/models/home_schedule_read_model.dart';
import '../data/models/monthly_timetable_read_model.dart';
import '../data/models/mosque_comparison_schedule_read_model.dart';
import '../data/models/prayer_log_read_model.dart';
import '../data/repositories/ibadah_completion_repository.dart';
import '../data/repositories/ibadah_task_repository.dart';
import '../data/repositories/mosque_repository.dart';
import '../data/repositories/prayer_log_repository.dart';
import '../data/repositories/settings_repository.dart';
import '../data/repositories/timing_rule_repository.dart';
import '../data/seeding/app_seed_service.dart';
import '../data/services/backup_file_transfer_service.dart';
import '../data/services/backup_service.dart';
import '../data/services/aladhan_verification_service.dart';
import '../data/services/home_widget_sync_service.dart';
import '../data/services/ibadah_planner_service.dart';
import '../data/services/mosque_schedule_read_service.dart';
import '../data/services/monthly_timetable_service.dart';
import '../data/services/notification_schedule_builder.dart';
import '../data/services/notification_sync_service.dart';
import '../data/services/prayer_log_read_service.dart';

final databaseProvider = Provider<AppDatabase>((ref) {
  final database = AppDatabase.local();
  ref.onDispose(database.close);
  return database;
});

final mosqueRepositoryProvider = Provider<MosqueRepository>((ref) {
  return MosqueRepository(ref.watch(databaseProvider));
});

final ibadahTaskRepositoryProvider = Provider<IbadahTaskRepository>((ref) {
  return IbadahTaskRepository(ref.watch(databaseProvider));
});

final ibadahCompletionRepositoryProvider = Provider<IbadahCompletionRepository>(
  (ref) {
    return IbadahCompletionRepository(ref.watch(databaseProvider));
  },
);

final timingRuleRepositoryProvider = Provider<TimingRuleRepository>((ref) {
  return TimingRuleRepository(ref.watch(databaseProvider));
});

final prayerLogRepositoryProvider = Provider<PrayerLogRepository>((ref) {
  return PrayerLogRepository(ref.watch(databaseProvider));
});

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return SettingsRepository(ref.watch(databaseProvider));
});

final httpClientProvider = Provider<http.Client>((ref) {
  final client = http.Client();
  ref.onDispose(client.close);
  return client;
});

final backupServiceProvider = Provider<BackupService>((ref) {
  return BackupService(ref.watch(databaseProvider));
});

final backupFileTransferServiceProvider = Provider<BackupFileTransferService>((
  ref,
) {
  return BackupFileTransferService();
});

final appSeedServiceProvider = Provider<AppSeedService>((ref) {
  return AppSeedService(
    mosqueRepository: ref.watch(mosqueRepositoryProvider),
    timingRuleRepository: ref.watch(timingRuleRepositoryProvider),
    settingsRepository: ref.watch(settingsRepositoryProvider),
  );
});

final mosqueScheduleReadServiceProvider = Provider<MosqueScheduleReadService>((
  ref,
) {
  return const MosqueScheduleReadService();
});

final prayerTimeServiceProvider = Provider<PrayerTimeService>((ref) {
  return const PrayerTimeService();
});

final qiblaServiceProvider = Provider<QiblaService>((ref) {
  return const QiblaService();
});

final ibadahPlannerServiceProvider = Provider<IbadahPlannerService>((ref) {
  return const IbadahPlannerService();
});

final prayerLogReadServiceProvider = Provider<PrayerLogReadService>((ref) {
  return const PrayerLogReadService();
});

final monthlyTimetableServiceProvider = Provider<MonthlyTimetableService>((
  ref,
) {
  return const MonthlyTimetableService();
});

final homeWidgetSyncServiceProvider = Provider<HomeWidgetSyncService>((ref) {
  return HomeWidgetSyncService(
    mosqueRepository: ref.watch(mosqueRepositoryProvider),
    timingRuleRepository: ref.watch(timingRuleRepositoryProvider),
    settingsRepository: ref.watch(settingsRepositoryProvider),
    mosqueScheduleReadService: ref.watch(mosqueScheduleReadServiceProvider),
  );
});

final alAdhanVerificationServiceProvider = Provider<AlAdhanVerificationService>(
  (ref) {
    return AlAdhanVerificationService(client: ref.watch(httpClientProvider));
  },
);

final notificationScheduleBuilderProvider =
    Provider<NotificationScheduleBuilder>((ref) {
      return const NotificationScheduleBuilder();
    });

final notificationSyncServiceProvider = Provider<NotificationSyncService>((
  ref,
) {
  return NotificationSyncService(
    mosqueRepository: ref.watch(mosqueRepositoryProvider),
    timingRuleRepository: ref.watch(timingRuleRepositoryProvider),
    settingsRepository: ref.watch(settingsRepositoryProvider),
    notificationScheduleBuilder: ref.watch(notificationScheduleBuilderProvider),
  );
});

final appBootstrapProvider = FutureProvider<void>((ref) async {
  await ref.watch(appSeedServiceProvider).seedIfEmpty();
});

final scheduleRefreshTickProvider = StreamProvider<DateTime>((ref) {
  final controller = StreamController<DateTime>();
  Timer? timer;

  void scheduleNextTick() {
    final now = DateTime.now();
    final nextTick = DateTime(
      now.year,
      now.month,
      now.day,
      now.hour,
      now.minute + 1,
    );
    timer = Timer(nextTick.difference(now), () {
      if (controller.isClosed) {
        return;
      }
      controller.add(DateTime.now());
      scheduleNextTick();
    });
  }

  controller.add(DateTime.now());
  scheduleNextTick();

  ref.onDispose(() async {
    timer?.cancel();
    await controller.close();
  });

  return controller.stream;
});

final prayerCalculationConfigProvider = FutureProvider<PrayerCalculationConfig>(
  (ref) async {
    await ref.watch(appBootstrapProvider.future);
    return ref.watch(settingsRepositoryProvider).loadPrayerCalculationConfig();
  },
);

final notificationPreferencesProvider = FutureProvider<NotificationPreferences>(
  (ref) async {
    await ref.watch(appBootstrapProvider.future);
    return ref.watch(settingsRepositoryProvider).loadNotificationPreferences();
  },
);

final settingsScreenDataProvider =
    FutureProvider<
      ({
        PrayerCalculationConfig config,
        NotificationPreferences notificationPreferences,
        AppThemeMode themeMode,
      })
    >((ref) async {
      await ref.watch(appBootstrapProvider.future);
      final repository = ref.watch(settingsRepositoryProvider);
      return (
        config: await repository.loadPrayerCalculationConfig(),
        notificationPreferences: await repository.loadNotificationPreferences(),
        themeMode: await repository.loadThemeMode(),
      );
    });

final appThemeModeProvider = StreamProvider<AppThemeMode>((ref) async* {
  await ref.watch(appBootstrapProvider.future);
  yield* ref.watch(settingsRepositoryProvider).watchThemeMode();
});

final mosquesProvider = FutureProvider<List<Mosque>>((ref) async {
  await ref.watch(appBootstrapProvider.future);
  return ref.watch(mosqueRepositoryProvider).getAll();
});

final mosqueByIdProvider = FutureProvider.family<Mosque?, int>((
  ref,
  mosqueId,
) async {
  await ref.watch(appBootstrapProvider.future);
  return ref.watch(mosqueRepositoryProvider).getById(mosqueId);
});

final timingRulesForMosqueProvider =
    FutureProvider.family<List<TimingRuleEntry>, int>((ref, mosqueId) async {
      await ref.watch(appBootstrapProvider.future);
      return ref.watch(timingRuleRepositoryProvider).listForMosque(mosqueId);
    });

final ibadahPlannerProvider =
    FutureProvider.family<IbadahPlannerDayReadModel, DateTime>((
      ref,
      date,
    ) async {
      await ref.watch(appBootstrapProvider.future);
      final taskRepository = ref.watch(ibadahTaskRepositoryProvider);
      final completionRepository = ref.watch(
        ibadahCompletionRepositoryProvider,
      );
      final service = ref.watch(ibadahPlannerServiceProvider);

      final tasks = await taskRepository.getAll();
      final completions = await completionRepository.listForDate(date);
      final oneTimeTaskIds = tasks
          .where(
            (task) =>
                task.repeatType == IbadahTaskRepeatType.oneTime &&
                task.isActive,
          )
          .map((task) => task.id)
          .toList(growable: false);
      final historical = await completionRepository.listForTaskIds(
        oneTimeTaskIds,
      );
      final tasksById = {for (final task in tasks) task.id: task};
      final completedOneTimeTaskIds = historical
          .where((completion) {
            final task = tasksById[completion.taskId];
            final target = task?.countTarget;
            if (target != null && target > 0) {
              return completion.completed || completion.countDone >= target;
            }
            return completion.completed;
          })
          .map((completion) => completion.taskId)
          .toSet();

      return service.buildDay(
        date: date,
        tasks: tasks,
        completions: completions,
        completedOneTimeTaskIds: completedOneTimeTaskIds,
      );
    });

final prayerLogDayProvider =
    FutureProvider.family<PrayerLogDayReadModel, DateTime>((ref, date) async {
      await ref.watch(appBootstrapProvider.future);
      final prayerLogRepository = ref.watch(prayerLogRepositoryProvider);
      final mosqueRepository = ref.watch(mosqueRepositoryProvider);
      final readService = ref.watch(prayerLogReadServiceProvider);

      return readService.buildDay(
        date: date,
        dayEntries: await prayerLogRepository.listForDate(date),
        weekEntries: await prayerLogRepository.listForRange(
          startOfWeek(date),
          endOfWeek(date),
        ),
        monthEntries: await prayerLogRepository.listForRange(
          startOfMonth(date),
          endOfMonth(date),
        ),
        mosques: await mosqueRepository.getAll(),
      );
    });

final monthlyTimetableProvider =
    FutureProvider.family<MonthlyTimetableReadModel, DateTime>((
      ref,
      month,
    ) async {
      await ref.watch(appBootstrapProvider.future);
      final mosqueRepository = ref.watch(mosqueRepositoryProvider);
      final settingsRepository = ref.watch(settingsRepositoryProvider);
      final timingRuleRepository = ref.watch(timingRuleRepositoryProvider);
      final service = ref.watch(monthlyTimetableServiceProvider);
      final primaryMosque = await mosqueRepository.getPrimary();

      return service.buildMonth(
        month: month,
        config: await settingsRepository.loadPrayerCalculationConfig(),
        primaryMosque: primaryMosque,
        rules: primaryMosque == null
            ? const []
            : await timingRuleRepository.listDomainForMosque(primaryMosque.id),
      );
    });

final homeScheduleProvider = FutureProvider<HomeScheduleReadModel?>((
  ref,
) async {
  await ref.watch(appBootstrapProvider.future);
  final refreshTick = ref.watch(scheduleRefreshTickProvider);
  final now = refreshTick.when(
    data: (value) => value,
    error: (_, _) => DateTime.now(),
    loading: DateTime.now,
  );

  final mosqueRepository = ref.watch(mosqueRepositoryProvider);
  final settingsRepository = ref.watch(settingsRepositoryProvider);
  final timingRuleRepository = ref.watch(timingRuleRepositoryProvider);
  final readService = ref.watch(mosqueScheduleReadServiceProvider);

  final primaryMosque = await mosqueRepository.getPrimary();
  if (primaryMosque == null) {
    return null;
  }

  final config = await settingsRepository.loadPrayerCalculationConfig();
  final rules = await timingRuleRepository.listDomainForMosque(
    primaryMosque.id,
  );

  return readService.buildHomeSchedule(
    date: now,
    config: config,
    primaryMosque: primaryMosque,
    rules: rules,
  );
});

final comparisonSchedulesProvider =
    FutureProvider<List<MosqueComparisonScheduleReadModel>>((ref) async {
      await ref.watch(appBootstrapProvider.future);
      final refreshTick = ref.watch(scheduleRefreshTickProvider);
      final now = refreshTick.when(
        data: (value) => value,
        error: (_, _) => DateTime.now(),
        loading: DateTime.now,
      );

      final mosqueRepository = ref.watch(mosqueRepositoryProvider);
      final settingsRepository = ref.watch(settingsRepositoryProvider);
      final timingRuleRepository = ref.watch(timingRuleRepositoryProvider);
      final readService = ref.watch(mosqueScheduleReadServiceProvider);

      final mosques = await mosqueRepository.getAll(activeOnly: true);
      if (mosques.isEmpty) {
        return const <MosqueComparisonScheduleReadModel>[];
      }

      final config = await settingsRepository.loadPrayerCalculationConfig();
      final rulesByMosque = await timingRuleRepository.listDomainForMosques(
        mosques.map((mosque) => mosque.id),
      );

      return readService.buildComparisonSchedules(
        date: now,
        config: config,
        mosques: mosques,
        rulesByMosque: rulesByMosque,
      );
    });

final notificationSyncTriggerProvider = FutureProvider<NotificationSyncResult>((
  ref,
) async {
  await ref.watch(appBootstrapProvider.future);
  return ref
      .watch(notificationSyncServiceProvider)
      .scheduleSync(reason: 'data-change');
});

final homeWidgetSyncTriggerProvider = FutureProvider<void>((ref) async {
  await ref.watch(appBootstrapProvider.future);
  await ref.watch(homeWidgetSyncServiceProvider).sync(reason: 'data-change');
});

final notificationRuntimeStatusProvider =
    FutureProvider<NotificationRuntimeStatus>((ref) async {
      await ref.watch(appBootstrapProvider.future);
      return ref.watch(notificationSyncServiceProvider).loadRuntimeStatus();
    });

void refreshMilestone3Data(
  WidgetRef ref, {
  int? mosqueId,
  bool includeSettings = true,
}) {
  ref.invalidate(mosquesProvider);
  ref.invalidate(homeScheduleProvider);
  ref.invalidate(comparisonSchedulesProvider);

  if (includeSettings) {
    ref.invalidate(prayerCalculationConfigProvider);
    ref.invalidate(notificationPreferencesProvider);
    ref.invalidate(settingsScreenDataProvider);
  }
  if (mosqueId != null) {
    ref.invalidate(mosqueByIdProvider(mosqueId));
    ref.invalidate(timingRulesForMosqueProvider(mosqueId));
  }
  ref.invalidate(notificationRuntimeStatusProvider);
  ref.invalidate(notificationSyncTriggerProvider);
  ref.invalidate(homeWidgetSyncTriggerProvider);
}

void refreshPlannerData(WidgetRef ref, DateTime date) {
  ref.invalidate(ibadahPlannerProvider(date));
}

void refreshPrayerLogData(WidgetRef ref, DateTime date) {
  ref.invalidate(prayerLogDayProvider(date));
}

void refreshTimetableData(WidgetRef ref, DateTime month) {
  ref.invalidate(monthlyTimetableProvider(month));
}

Future<void> syncNotificationsAfterForegroundChange(WidgetRef ref) async {
  ref.invalidate(notificationRuntimeStatusProvider);
  await ref
      .read(notificationSyncServiceProvider)
      .scheduleSync(reason: 'foreground-resume');
}

Future<void> syncHomeWidgetAfterForegroundChange(WidgetRef ref) async {
  await ref
      .read(homeWidgetSyncServiceProvider)
      .sync(reason: 'foreground-resume');
}
