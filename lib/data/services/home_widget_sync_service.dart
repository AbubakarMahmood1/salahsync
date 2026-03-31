import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:home_widget/home_widget.dart';

import '../../core/time/salah_prayer.dart';
import '../models/home_schedule_read_model.dart';
import '../repositories/mosque_repository.dart';
import '../repositories/settings_repository.dart';
import '../repositories/timing_rule_repository.dart';
import 'mosque_schedule_read_service.dart';

const kHomeWidgetAndroidQualifiedName =
    'com.salahsync.salahsync.SalahsyncWidgetProvider';
const kHomeWidgetAppGroupId = 'group.com.salahsync.salahsync';

class HomeWidgetSyncService {
  HomeWidgetSyncService({
    required MosqueRepository mosqueRepository,
    required TimingRuleRepository timingRuleRepository,
    required SettingsRepository settingsRepository,
    MosqueScheduleReadService mosqueScheduleReadService =
        const MosqueScheduleReadService(),
  }) : _mosqueRepository = mosqueRepository,
       _timingRuleRepository = timingRuleRepository,
       _settingsRepository = settingsRepository,
       _mosqueScheduleReadService = mosqueScheduleReadService;

  final MosqueRepository _mosqueRepository;
  final TimingRuleRepository _timingRuleRepository;
  final SettingsRepository _settingsRepository;
  final MosqueScheduleReadService _mosqueScheduleReadService;

  Future<void> sync({DateTime? now, String reason = 'manual'}) async {
    try {
      await HomeWidget.setAppGroupId(kHomeWidgetAppGroupId);
      final current = now ?? DateTime.now();
      final primaryMosque = await _mosqueRepository.getPrimary();
      if (primaryMosque == null) {
        await _savePlaceholder(reason: reason);
        return;
      }

      final config = await _settingsRepository.loadPrayerCalculationConfig();
      final rules = await _timingRuleRepository.listDomainForMosque(
        primaryMosque.id,
      );
      final today = _mosqueScheduleReadService.buildHomeSchedule(
        date: current,
        config: config,
        primaryMosque: primaryMosque,
        rules: rules,
      );
      final tomorrow = _mosqueScheduleReadService.buildHomeSchedule(
        date: current.add(const Duration(days: 1)),
        config: config,
        primaryMosque: primaryMosque,
        rules: rules,
      );

      final scheduleEntries = [
        ..._buildEntries(today),
        ..._buildEntries(tomorrow),
      ]..sort((left, right) => left.timeMillis.compareTo(right.timeMillis));

      _WidgetPrayerEntry? nextEntry;
      for (final entry in scheduleEntries) {
        if (entry.timeMillis >= current.millisecondsSinceEpoch) {
          nextEntry = entry;
          break;
        }
      }
      nextEntry ??= scheduleEntries.isEmpty ? null : scheduleEntries.first;

      await HomeWidget.saveWidgetData<String>(
        'widget_location_name',
        primaryMosque.name,
      );
      await HomeWidget.saveWidgetData<String>(
        'widget_hijri_label',
        today.computedSnapshot.hijriDate.shortLabel,
      );
      await HomeWidget.saveWidgetData<String>(
        'widget_schedule_json',
        jsonEncode([for (final entry in scheduleEntries) entry.toJson()]),
      );
      await HomeWidget.saveWidgetData<String>('widget_sync_reason', reason);
      await HomeWidget.saveWidgetData<int>(
        'widget_last_updated',
        current.millisecondsSinceEpoch,
      );
      await HomeWidget.saveWidgetData<String>(
        'widget_next_prayer_label',
        nextEntry?.label ?? 'No prayer',
      );
      await HomeWidget.saveWidgetData<int>(
        'widget_next_prayer_time',
        nextEntry?.timeMillis ?? current.millisecondsSinceEpoch,
      );
      await HomeWidget.updateWidget(
        qualifiedAndroidName: kHomeWidgetAndroidQualifiedName,
        iOSName: 'SalahsyncWidget',
      );
    } on MissingPluginException {
      return;
    }
  }

  Future<bool> canRequestPinWidget() async {
    try {
      return await HomeWidget.isRequestPinWidgetSupported() ?? false;
    } on MissingPluginException {
      return false;
    }
  }

  Future<void> requestPinWidget() async {
    try {
      await HomeWidget.requestPinWidget(
        qualifiedAndroidName: kHomeWidgetAndroidQualifiedName,
      );
    } on MissingPluginException {
      return;
    }
  }

  Future<void> _savePlaceholder({required String reason}) async {
    await HomeWidget.saveWidgetData<String>(
      'widget_location_name',
      'SalahSync',
    );
    await HomeWidget.saveWidgetData<String>('widget_hijri_label', '');
    await HomeWidget.saveWidgetData<String>('widget_schedule_json', '[]');
    await HomeWidget.saveWidgetData<String>('widget_sync_reason', reason);
    await HomeWidget.saveWidgetData<String>(
      'widget_next_prayer_label',
      'Add a primary mosque',
    );
    await HomeWidget.saveWidgetData<int>(
      'widget_next_prayer_time',
      DateTime.now().millisecondsSinceEpoch,
    );
    await HomeWidget.updateWidget(
      qualifiedAndroidName: kHomeWidgetAndroidQualifiedName,
      iOSName: 'SalahsyncWidget',
    );
  }

  List<_WidgetPrayerEntry> _buildEntries(HomeScheduleReadModel model) {
    return [
      for (final prayer in model.displayPrayers)
        if (_supportsWidgetPrayer(prayer))
          _WidgetPrayerEntry(
            label: prayer.label,
            timeMillis:
                (model.resolvedJamaatTimes[prayer]?.dateTime ??
                        model.computedSnapshot.timeOf(
                          prayer == SalahPrayer.jummah
                              ? SalahPrayer.dhuhr
                              : prayer,
                        ))
                    .millisecondsSinceEpoch,
          ),
    ];
  }

  bool _supportsWidgetPrayer(SalahPrayer prayer) {
    return prayer != SalahPrayer.imsak && prayer != SalahPrayer.sunrise;
  }
}

class _WidgetPrayerEntry {
  const _WidgetPrayerEntry({required this.label, required this.timeMillis});

  final String label;
  final int timeMillis;

  Map<String, dynamic> toJson() {
    return {'label': label, 'timeMillis': timeMillis};
  }
}
