import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/notifications/notification_preferences.dart';
import '../core/notifications/notification_runtime_status.dart';
import '../core/settings/app_theme_mode.dart';
import '../core/mosque/timing_rule.dart';
import '../core/time/prayer_calculation_config.dart';
import '../core/time/prayer_time_service.dart';
import '../data/db/app_database.dart';
import '../data/models/home_schedule_read_model.dart';
import '../data/models/mosque_comparison_schedule_read_model.dart';
import '../data/repositories/mosque_repository.dart';
import '../data/repositories/settings_repository.dart';
import '../data/repositories/timing_rule_repository.dart';
import '../data/seeding/app_seed_service.dart';
import '../data/services/backup_file_transfer_service.dart';
import '../data/services/backup_service.dart';
import '../data/services/mosque_schedule_read_service.dart';
import '../data/services/notification_schedule_builder.dart';
import '../data/services/notification_sync_service.dart';

final databaseProvider = Provider<AppDatabase>((ref) {
  final database = AppDatabase.local();
  ref.onDispose(database.close);
  return database;
});

final mosqueRepositoryProvider = Provider<MosqueRepository>((ref) {
  return MosqueRepository(ref.watch(databaseProvider));
});

final timingRuleRepositoryProvider = Provider<TimingRuleRepository>((ref) {
  return TimingRuleRepository(ref.watch(databaseProvider));
});

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return SettingsRepository(ref.watch(databaseProvider));
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

final homeScheduleProvider = FutureProvider<HomeScheduleReadModel?>((
  ref,
) async {
  await ref.watch(appBootstrapProvider.future);

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
    date: DateTime.now(),
    config: config,
    primaryMosque: primaryMosque,
    rules: rules,
  );
});

final comparisonSchedulesProvider =
    FutureProvider<List<MosqueComparisonScheduleReadModel>>((ref) async {
      await ref.watch(appBootstrapProvider.future);

      final mosqueRepository = ref.watch(mosqueRepositoryProvider);
      final settingsRepository = ref.watch(settingsRepositoryProvider);
      final timingRuleRepository = ref.watch(timingRuleRepositoryProvider);
      final readService = ref.watch(mosqueScheduleReadServiceProvider);

      final mosques = await mosqueRepository.getAll(activeOnly: true);
      if (mosques.isEmpty) {
        return const <MosqueComparisonScheduleReadModel>[];
      }

      final config = await settingsRepository.loadPrayerCalculationConfig();
      final rulesByMosque = <int, List<TimingRule>>{};
      for (final mosque in mosques) {
        rulesByMosque[mosque.id] = await timingRuleRepository
            .listDomainForMosque(mosque.id);
      }

      return readService.buildComparisonSchedules(
        date: DateTime.now(),
        config: config,
        mosques: mosques,
        rulesByMosque: rulesByMosque,
      );
    });

final notificationSyncTriggerProvider = FutureProvider<void>((ref) async {
  await ref.watch(appBootstrapProvider.future);

  final settingsRepository = ref.watch(settingsRepositoryProvider);
  final mosqueRepository = ref.watch(mosqueRepositoryProvider);
  final timingRuleRepository = ref.watch(timingRuleRepositoryProvider);

  await settingsRepository.loadPrayerCalculationConfig();
  await settingsRepository.loadNotificationPreferences();

  final primaryMosque = await mosqueRepository.getPrimary();
  if (primaryMosque != null) {
    await timingRuleRepository.listForMosque(primaryMosque.id);
  }
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
}

Future<void> syncNotificationsAfterForegroundChange(WidgetRef ref) async {
  ref.invalidate(notificationRuntimeStatusProvider);
  await ref
      .read(notificationSyncServiceProvider)
      .syncWindow(reason: 'foreground-resume');
}
