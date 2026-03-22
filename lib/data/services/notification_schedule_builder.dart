import 'package:timezone/timezone.dart' as tz;

import '../../core/mosque/timing_rule.dart';
import '../../core/notifications/notification_kind.dart';
import '../../core/notifications/notification_preferences.dart';
import '../../core/notifications/scheduled_notification_plan.dart';
import '../../core/time/prayer_calculation_config.dart';
import '../../core/time/salah_prayer.dart';
import '../db/app_database.dart';
import '../models/home_schedule_read_model.dart';
import 'mosque_schedule_read_service.dart';

class NotificationScheduleBuilder {
  const NotificationScheduleBuilder({
    MosqueScheduleReadService mosqueScheduleReadService =
        const MosqueScheduleReadService(),
  }) : _mosqueScheduleReadService = mosqueScheduleReadService;

  final MosqueScheduleReadService _mosqueScheduleReadService;

  List<ScheduledNotificationPlan> buildWindow({
    required DateTime now,
    required PrayerCalculationConfig config,
    required Mosque notificationMosque,
    required List<TimingRule> rules,
    required NotificationPreferences preferences,
    Duration window = const Duration(hours: 48),
  }) {
    final location = tz.getLocation(config.timezoneName);
    final windowStart = tz.TZDateTime.from(now, location);
    final cutoff = windowStart.add(window);
    final firstDay = tz.TZDateTime(
      location,
      windowStart.year,
      windowStart.month,
      windowStart.day,
    );

    final plans = <ScheduledNotificationPlan>[];
    for (var offset = 0; offset < 3; offset++) {
      final day = firstDay.add(Duration(days: offset));
      if (day.isAfter(cutoff)) {
        break;
      }

      final schedule = _mosqueScheduleReadService.buildHomeSchedule(
        date: day,
        config: config,
        primaryMosque: notificationMosque,
        rules: rules,
      );
      plans.addAll(
        _buildDayPlans(
          schedule: schedule,
          notificationMosque: notificationMosque,
          preferences: preferences,
        ),
      );
    }

    final filtered = plans
        .where((plan) => plan.scheduledAt.isAfter(windowStart))
        .where((plan) => !plan.scheduledAt.isAfter(cutoff))
        .toList(growable: false);
    filtered.sort((left, right) {
      final dateCompare = left.scheduledAt.compareTo(right.scheduledAt);
      if (dateCompare != 0) {
        return dateCompare;
      }
      return left.id.compareTo(right.id);
    });
    return filtered;
  }

  List<ScheduledNotificationPlan> _buildDayPlans({
    required HomeScheduleReadModel schedule,
    required Mosque notificationMosque,
    required NotificationPreferences preferences,
  }) {
    final snapshot = schedule.computedSnapshot;
    final plans = <ScheduledNotificationPlan>[];

    if (snapshot.isRamadanActive && preferences.sehriEnabled) {
      final imsakTime = snapshot.timeOf(SalahPrayer.imsak);
      plans.add(
        ScheduledNotificationPlan.create(
          mosqueId: notificationMosque.id,
          prayer: SalahPrayer.imsak,
          kind: NotificationKind.sehri,
          scheduledAt: imsakTime,
          title: 'Sehri ends soon',
          body: 'Imsak is at ${_formatTime(imsakTime)}.',
        ),
      );
    }

    for (final prayer in schedule.displayPrayers) {
      if (prayer == SalahPrayer.imsak || prayer == SalahPrayer.sunrise) {
        continue;
      }

      final preference = preferences.forPrayer(prayer);
      final computedPrayer = prayer == SalahPrayer.jummah
          ? SalahPrayer.dhuhr
          : prayer;
      final adhanTime = snapshot.timeOf(computedPrayer);

      if (preference.adhanEnabled) {
        plans.add(
          ScheduledNotificationPlan.create(
            mosqueId: notificationMosque.id,
            prayer: prayer,
            kind: NotificationKind.adhan,
            scheduledAt: adhanTime,
            title: '${prayer.label} Adhan',
            body: 'Prayer time starts at ${_formatTime(adhanTime)}.',
          ),
        );
      }

      final resolvedTiming = schedule.resolvedJamaatTimes[prayer];
      if (resolvedTiming == null) {
        continue;
      }

      if (preference.reminderEnabled) {
        final reminderTime = resolvedTiming.dateTime.subtract(
          Duration(minutes: preferences.reminderOffsetMinutes),
        );
        plans.add(
          ScheduledNotificationPlan.create(
            mosqueId: notificationMosque.id,
            prayer: prayer,
            kind: NotificationKind.reminder,
            scheduledAt: reminderTime,
            title: '${prayer.label} reminder',
            body:
                '${preferences.reminderOffsetMinutes} min before Jamaat at ${_formatTime(resolvedTiming.dateTime)} in ${notificationMosque.name}.',
          ),
        );
      }

      if (preference.jamaatEnabled) {
        plans.add(
          ScheduledNotificationPlan.create(
            mosqueId: notificationMosque.id,
            prayer: prayer,
            kind: NotificationKind.jamaat,
            scheduledAt: resolvedTiming.dateTime,
            title: '${prayer.label} Jamaat',
            body:
                '${notificationMosque.name} at ${_formatTime(resolvedTiming.dateTime)}.',
          ),
        );
      }
    }

    if (snapshot.isRamadanActive && preferences.iftarEnabled) {
      final maghribTime = snapshot.timeOf(SalahPrayer.maghrib);
      plans.add(
        ScheduledNotificationPlan.create(
          mosqueId: notificationMosque.id,
          prayer: SalahPrayer.maghrib,
          kind: NotificationKind.iftar,
          scheduledAt: maghribTime,
          title: 'Iftar time',
          body: 'Maghrib is at ${_formatTime(maghribTime)}.',
        ),
      );
    }

    return plans;
  }

  String _formatTime(DateTime value) {
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
