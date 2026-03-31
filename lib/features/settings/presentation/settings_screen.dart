import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_selector/file_selector.dart' as fs;
import 'package:share_plus/share_plus.dart';

import '../../../app/providers.dart';
import '../../../core/notifications/notification_preferences.dart';
import '../../../core/notifications/notification_runtime_status.dart';
import '../../../core/settings/app_theme_mode.dart';
import '../../../core/time/geo_coordinates.dart';
import '../../../core/time/prayer_calculation_config.dart';
import '../../../core/time/salah_prayer.dart';
import '../../../core/time/timezone_name.dart';
import '../../../data/services/backup_file_transfer_service.dart';
import '../../../data/services/backup_service.dart';

const _backupFileTypeGroup = fs.XTypeGroup(
  label: 'SalahSync backup',
  extensions: ['json'],
);

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(settingsScreenDataProvider);

    return settingsAsync.when(
      data: (settings) {
        final key = ValueKey(
          [
            settings.config.locationName,
            settings.config.coordinates.latitude,
            settings.config.coordinates.longitude,
            settings.config.timezoneName,
            settings.config.method.name,
            settings.config.asrSchool.name,
            settings.config.ishaEndConvention.name,
            settings.config.imsakOffsetMinutes,
            settings.config.adjustments.fajr,
            settings.config.adjustments.sunrise,
            settings.config.adjustments.dhuhr,
            settings.config.adjustments.asr,
            settings.config.adjustments.maghrib,
            settings.config.adjustments.isha,
            settings.config.hijriOffsetDays,
            settings.config.ramadanModeOverride,
            settings.notificationPreferences.fingerprint,
            settings.themeMode.name,
          ].join('|'),
        );

        return _SettingsForm(
          key: key,
          initialConfig: settings.config,
          initialNotificationPreferences: settings.notificationPreferences,
          initialThemeMode: settings.themeMode,
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => _SettingsError(
        error: error,
        onRetry: () => ref.invalidate(settingsScreenDataProvider),
      ),
    );
  }
}

class _SettingsForm extends ConsumerStatefulWidget {
  const _SettingsForm({
    super.key,
    required this.initialConfig,
    required this.initialNotificationPreferences,
    required this.initialThemeMode,
  });

  final PrayerCalculationConfig initialConfig;
  final NotificationPreferences initialNotificationPreferences;
  final AppThemeMode initialThemeMode;

  @override
  ConsumerState<_SettingsForm> createState() => _SettingsFormState();
}

class _SettingsFormState extends ConsumerState<_SettingsForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _locationNameController;
  late final TextEditingController _timezoneController;
  late final TextEditingController _latitudeController;
  late final TextEditingController _longitudeController;
  late final TextEditingController _imsakOffsetController;
  late final TextEditingController _hijriOffsetController;
  late final TextEditingController _reminderOffsetController;
  late final Map<String, TextEditingController> _adjustmentControllers;

  late PrayerCalculationMethodChoice _method;
  late AsrJuristicSchool _asrSchool;
  late IshaEndConvention _ishaEndConvention;
  late AppThemeMode _themeMode;
  late _RamadanOverrideChoice _ramadanOverride;
  late Map<SalahPrayer, PrayerNotificationPreference> _notificationPreferences;
  late NotificationPrivacyMode _notificationPrivacyMode;
  late bool _sehriEnabled;
  late bool _iftarEnabled;
  bool _isSaving = false;
  bool _isBackupBusy = false;
  bool _isResyncingWindow = false;

  @override
  void initState() {
    super.initState();
    _locationNameController = TextEditingController();
    _timezoneController = TextEditingController();
    _latitudeController = TextEditingController();
    _longitudeController = TextEditingController();
    _imsakOffsetController = TextEditingController();
    _hijriOffsetController = TextEditingController();
    _reminderOffsetController = TextEditingController();
    _adjustmentControllers = {
      for (final prayer in _adjustmentPrayerKeys)
        prayer: TextEditingController(),
    };
    _applyConfig(widget.initialConfig);
    _applyNotificationPreferences(widget.initialNotificationPreferences);
    _themeMode = widget.initialThemeMode;
  }

  @override
  void dispose() {
    _locationNameController.dispose();
    _timezoneController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    _imsakOffsetController.dispose();
    _hijriOffsetController.dispose();
    _reminderOffsetController.dispose();
    for (final controller in _adjustmentControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final notificationStatusAsync = ref.watch(
      notificationRuntimeStatusProvider,
    );

    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Calculation profile',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'This screen controls the coordinate-based prayer engine that feeds the home schedule, fallback Jamaat times, and the notification window.',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 18),
                  TextFormField(
                    controller: _locationNameController,
                    decoration: const InputDecoration(
                      labelText: 'Location name',
                    ),
                    validator: _requiredValidator,
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _timezoneController,
                    decoration: const InputDecoration(
                      labelText: 'Timezone name',
                      helperText: 'Use an IANA timezone like Asia/Karachi',
                    ),
                    validator: _timezoneValidator,
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _latitudeController,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                            signed: true,
                          ),
                          decoration: const InputDecoration(
                            labelText: 'Latitude',
                          ),
                          validator: _doubleValidator,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _longitudeController,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                            signed: true,
                          ),
                          decoration: const InputDecoration(
                            labelText: 'Longitude',
                          ),
                          validator: _doubleValidator,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Appearance',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Theme mode is stored locally and applied across the app shell on the next rebuild.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 18),
                  DropdownButtonFormField<AppThemeMode>(
                    key: ValueKey(_themeMode),
                    initialValue: _themeMode,
                    decoration: const InputDecoration(labelText: 'Theme mode'),
                    items: AppThemeMode.values
                        .map(
                          (mode) => DropdownMenuItem(
                            value: mode,
                            child: Text(mode.label),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value == null) {
                        return;
                      }
                      setState(() {
                        _themeMode = value;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Methods and conventions',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 18),
                  DropdownButtonFormField<PrayerCalculationMethodChoice>(
                    key: ValueKey(_method),
                    initialValue: _method,
                    decoration: const InputDecoration(
                      labelText: 'Calculation method',
                    ),
                    items: PrayerCalculationMethodChoice.values
                        .map(
                          (method) => DropdownMenuItem(
                            value: method,
                            child: Text(_methodLabel(method)),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value == null) {
                        return;
                      }
                      setState(() {
                        _method = value;
                      });
                    },
                  ),
                  const SizedBox(height: 14),
                  DropdownButtonFormField<AsrJuristicSchool>(
                    key: ValueKey(_asrSchool),
                    initialValue: _asrSchool,
                    decoration: const InputDecoration(labelText: 'Asr school'),
                    items: AsrJuristicSchool.values
                        .map(
                          (school) => DropdownMenuItem(
                            value: school,
                            child: Text(_asrSchoolLabel(school)),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value == null) {
                        return;
                      }
                      setState(() {
                        _asrSchool = value;
                      });
                    },
                  ),
                  const SizedBox(height: 14),
                  DropdownButtonFormField<IshaEndConvention>(
                    key: ValueKey(_ishaEndConvention),
                    initialValue: _ishaEndConvention,
                    decoration: const InputDecoration(
                      labelText: 'Isha end convention',
                    ),
                    items: IshaEndConvention.values
                        .map(
                          (convention) => DropdownMenuItem(
                            value: convention,
                            child: Text(_ishaEndLabel(convention)),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value == null) {
                        return;
                      }
                      setState(() {
                        _ishaEndConvention = value;
                      });
                    },
                  ),
                  const SizedBox(height: 14),
                  DropdownButtonFormField<_RamadanOverrideChoice>(
                    key: ValueKey(_ramadanOverride),
                    initialValue: _ramadanOverride,
                    decoration: const InputDecoration(
                      labelText: 'Ramadan mode override',
                    ),
                    items: _RamadanOverrideChoice.values
                        .map(
                          (choice) => DropdownMenuItem(
                            value: choice,
                            child: Text(choice.label),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value == null) {
                        return;
                      }
                      setState(() {
                        _ramadanOverride = value;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Offsets',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 18),
                  TextFormField(
                    controller: _imsakOffsetController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Imsak offset minutes',
                    ),
                    validator: _intValidator,
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _hijriOffsetController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Hijri date correction (days)',
                    ),
                    validator: _intValidator,
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'Manual per-prayer adjustments',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  for (final row in _adjustmentRows) ...[
                    Row(
                      children: [
                        for (final key in row) ...[
                          Expanded(
                            child: TextFormField(
                              controller: _adjustmentControllers[key],
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: _adjustmentFieldLabel(key),
                              ),
                              validator: _intValidator,
                            ),
                          ),
                          if (key != row.last) const SizedBox(width: 12),
                        ],
                      ],
                    ),
                    if (row != _adjustmentRows.last) const SizedBox(height: 12),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Notifications',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Adhan alerts stay coordinate-based. Jamaat alerts and pre-Jamaat reminders follow the primary / notification mosque only.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 18),
                  TextFormField(
                    controller: _reminderOffsetController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Pre-Jamaat reminder offset (minutes)',
                    ),
                    validator: _nonNegativeIntValidator,
                  ),
                  const SizedBox(height: 14),
                  DropdownButtonFormField<NotificationPrivacyMode>(
                    key: ValueKey(_notificationPrivacyMode),
                    initialValue: _notificationPrivacyMode,
                    decoration: const InputDecoration(
                      labelText: 'Lock-screen privacy',
                    ),
                    items: NotificationPrivacyMode.values
                        .map(
                          (mode) => DropdownMenuItem(
                            value: mode,
                            child: Text(mode.label),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value == null) {
                        return;
                      }
                      setState(() {
                        _notificationPrivacyMode = value;
                      });
                    },
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Prayer name only removes mosque names and exact schedule text from notification content so lock-screen previews stay less revealing.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'Per-prayer toggles',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Jummah replaces Dhuhr on Fridays for both UI and notifications.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _NotificationMatrix(
                    preferences: _notificationPreferences,
                    onChanged: _updatePrayerNotificationPreference,
                  ),
                  const SizedBox(height: 18),
                  SwitchListTile.adaptive(
                    value: _sehriEnabled,
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Sehri alert'),
                    subtitle: const Text(
                      'Schedules a Ramadan Imsak notification on its own channel.',
                    ),
                    onChanged: (value) {
                      setState(() {
                        _sehriEnabled = value;
                      });
                    },
                  ),
                  SwitchListTile.adaptive(
                    value: _iftarEnabled,
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Iftar alert'),
                    subtitle: const Text(
                      'Schedules a Ramadan Maghrib notification on its own channel.',
                    ),
                    onChanged: (value) {
                      setState(() {
                        _iftarEnabled = value;
                      });
                    },
                  ),
                  const SizedBox(height: 18),
                  notificationStatusAsync.when(
                    data: (status) {
                      return _NotificationStatusCard(
                        status: status,
                        onRequestNotificationPermission: _isSaving
                            ? null
                            : _requestNotificationPermission,
                        onRequestExactPermission: _isSaving
                            ? null
                            : _requestExactAlarmPermission,
                        onRebuildWindow: _isSaving || _isResyncingWindow
                            ? null
                            : _rebuildNotificationWindow,
                        onRefresh: _isSaving
                            ? null
                            : () => ref.invalidate(
                                notificationRuntimeStatusProvider,
                              ),
                      );
                    },
                    loading: () => const LinearProgressIndicator(),
                    error: (error, _) => _NotificationStatusError(
                      message: error.toString(),
                      onRetry: () =>
                          ref.invalidate(notificationRuntimeStatusProvider),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Backup & restore',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Export the local database as a passphrase-protected backup, and import a prior SalahSync backup from file or pasted text. Legacy plaintext backups can still be imported. Import always replaces the current local database.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      FilledButton.tonalIcon(
                        onPressed: _isSaving || _isBackupBusy
                            ? null
                            : _exportBackup,
                        icon: const Icon(Icons.file_upload_outlined),
                        label: Text(
                          _isBackupBusy ? 'Working...' : 'Export Backup',
                        ),
                      ),
                      FilledButton.tonalIcon(
                        onPressed: _isSaving || _isBackupBusy
                            ? null
                            : _importBackup,
                        icon: const Icon(Icons.file_download_outlined),
                        label: const Text('Import JSON'),
                      ),
                      FilledButton.tonalIcon(
                        onPressed: _isSaving || _isBackupBusy
                            ? null
                            : _importBackupFile,
                        icon: const Icon(Icons.folder_open_outlined),
                        label: const Text('Import File'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _isSaving ? null : _resetDefaults,
                  child: const Text('Reset Defaults'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: _isSaving ? null : _save,
                  child: Text(_isSaving ? 'Saving...' : 'Save Settings'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _applyConfig(PrayerCalculationConfig config) {
    _locationNameController.text = config.locationName;
    _timezoneController.text = config.timezoneName;
    _latitudeController.text = config.coordinates.latitude.toString();
    _longitudeController.text = config.coordinates.longitude.toString();
    _imsakOffsetController.text = config.imsakOffsetMinutes.toString();
    _hijriOffsetController.text = config.hijriOffsetDays.toString();
    _adjustmentControllers['fajr']!.text = config.adjustments.fajr.toString();
    _adjustmentControllers['sunrise']!.text = config.adjustments.sunrise
        .toString();
    _adjustmentControllers['dhuhr']!.text = config.adjustments.dhuhr.toString();
    _adjustmentControllers['asr']!.text = config.adjustments.asr.toString();
    _adjustmentControllers['maghrib']!.text = config.adjustments.maghrib
        .toString();
    _adjustmentControllers['isha']!.text = config.adjustments.isha.toString();
    _method = config.method;
    _asrSchool = config.asrSchool;
    _ishaEndConvention = config.ishaEndConvention;
    _ramadanOverride = switch (config.ramadanModeOverride) {
      true => _RamadanOverrideChoice.forceOn,
      false => _RamadanOverrideChoice.forceOff,
      null => _RamadanOverrideChoice.system,
    };
  }

  void _applyNotificationPreferences(NotificationPreferences preferences) {
    _notificationPreferences = {
      for (final prayer in kNotificationPreferencePrayers)
        prayer: preferences.forPrayer(prayer),
    };
    _notificationPrivacyMode = preferences.privacyMode;
    _reminderOffsetController.text = preferences.reminderOffsetMinutes
        .toString();
    _sehriEnabled = preferences.sehriEnabled;
    _iftarEnabled = preferences.iftarEnabled;
  }

  NotificationPreferences _buildNotificationPreferences() {
    return NotificationPreferences(
      perPrayer: _notificationPreferences,
      reminderOffsetMinutes: int.parse(_reminderOffsetController.text.trim()),
      sehriEnabled: _sehriEnabled,
      iftarEnabled: _iftarEnabled,
      privacyMode: _notificationPrivacyMode,
    );
  }

  void _updatePrayerNotificationPreference(
    SalahPrayer prayer,
    PrayerNotificationPreference preference,
  ) {
    setState(() {
      _notificationPreferences = {
        ..._notificationPreferences,
        prayer: preference,
      };
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final config = PrayerCalculationConfig(
      locationName: _locationNameController.text.trim(),
      coordinates: GeoCoordinates(
        latitude: double.parse(_latitudeController.text.trim()),
        longitude: double.parse(_longitudeController.text.trim()),
      ),
      timezoneName: sanitizeTimezoneName(
        _timezoneController.text,
        fallback: kDefaultTimezoneName,
      ),
      method: _method,
      asrSchool: _asrSchool,
      ishaEndConvention: _ishaEndConvention,
      imsakOffsetMinutes: int.parse(_imsakOffsetController.text.trim()),
      adjustments: PrayerAdjustments(
        fajr: int.parse(_adjustmentControllers['fajr']!.text.trim()),
        sunrise: int.parse(_adjustmentControllers['sunrise']!.text.trim()),
        dhuhr: int.parse(_adjustmentControllers['dhuhr']!.text.trim()),
        asr: int.parse(_adjustmentControllers['asr']!.text.trim()),
        maghrib: int.parse(_adjustmentControllers['maghrib']!.text.trim()),
        isha: int.parse(_adjustmentControllers['isha']!.text.trim()),
      ),
      hijriOffsetDays: int.parse(_hijriOffsetController.text.trim()),
      ramadanModeOverride: switch (_ramadanOverride) {
        _RamadanOverrideChoice.system => null,
        _RamadanOverrideChoice.forceOn => true,
        _RamadanOverrideChoice.forceOff => false,
      },
    );
    final notificationPreferences = _buildNotificationPreferences();

    setState(() {
      _isSaving = true;
    });

    try {
      final repository = ref.read(settingsRepositoryProvider);
      await repository.savePrayerCalculationConfig(config);
      await repository.saveNotificationPreferences(notificationPreferences);
      await repository.saveThemeMode(_themeMode);
      refreshMilestone3Data(ref);
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
        _showMessage('Settings saved.');
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
        _showMessage(error.toString());
      }
    }
  }

  Future<void> _resetDefaults() async {
    final shouldReset = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Reset settings?'),
          content: const Text(
            'Reset the calculation profile, offsets, and notification preferences back to the seeded defaults?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Reset'),
            ),
          ],
        );
      },
    );

    if (shouldReset != true) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final repository = ref.read(settingsRepositoryProvider);
      await repository.resetAll();
      await repository.seedDefaults();
      final config = await repository.loadPrayerCalculationConfig();
      final notificationPreferences = await repository
          .loadNotificationPreferences();
      final themeMode = await repository.loadThemeMode();

      refreshMilestone3Data(ref);
      if (mounted) {
        setState(() {
          _applyConfig(config);
          _applyNotificationPreferences(notificationPreferences);
          _themeMode = themeMode;
          _isSaving = false;
        });
        _showMessage('Defaults restored.');
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
        _showMessage(error.toString());
      }
    }
  }

  Future<void> _requestNotificationPermission() async {
    final approved = await _showPermissionExplanation(
      title: 'Enable notifications?',
      message: switch (defaultTargetPlatform) {
        TargetPlatform.iOS =>
          'SalahSync will ask iOS for alert, sound, and badge access after this explanation. Adhan, Jamaat, Sehri, and Iftar alerts stay local to this device.',
        _ =>
          'Android 13 and above require explicit notification permission before prayer alerts can appear. SalahSync only schedules local notifications from your saved settings.',
      },
    );

    if (approved != true) {
      return;
    }

    final granted = await ref
        .read(notificationSyncServiceProvider)
        .requestNotificationPermission();
    ref.invalidate(notificationRuntimeStatusProvider);
    await ref
        .read(notificationSyncServiceProvider)
        .scheduleSync(reason: 'notification-permission-change');
    if (!mounted) {
      return;
    }
    _showMessage(
      granted
          ? 'Notification permission updated.'
          : 'Notification permission was not granted.',
    );
  }

  Future<void> _requestExactAlarmPermission() async {
    final approved = await _showPermissionExplanation(
      title: 'Allow precise timing?',
      message:
          'Exact alarms keep Adhan and Jamaat alerts closer to their scheduled minute on Android. If Android denies exact access, SalahSync falls back to inexact scheduling and resyncs automatically.',
    );

    if (approved != true) {
      return;
    }

    final granted = await ref
        .read(notificationSyncServiceProvider)
        .requestExactAlarmPermission();
    ref.invalidate(notificationRuntimeStatusProvider);
    await ref
        .read(notificationSyncServiceProvider)
        .scheduleSync(reason: 'exact-alarm-permission-change');
    if (!mounted) {
      return;
    }
    _showMessage(
      granted
          ? 'Exact alarm access updated.'
          : 'Exact alarm access is still unavailable. Inexact fallback remains active.',
    );
  }

  Future<void> _rebuildNotificationWindow() async {
    setState(() {
      _isResyncingWindow = true;
    });

    try {
      final result = await ref
          .read(notificationSyncServiceProvider)
          .scheduleSync(reason: 'settings-manual-rebuild');
      ref.invalidate(notificationRuntimeStatusProvider);
      if (!mounted) {
        return;
      }
      _showMessage(
        result.platformAvailable
            ? 'Notification window rebuilt: ${result.scheduledCount} scheduled, ${result.cancelledCount} removed.'
            : 'Notification runtime is unavailable in this environment.',
      );
    } catch (error) {
      if (mounted) {
        _showMessage(error.toString());
      }
    } finally {
      if (mounted) {
        setState(() {
          _isResyncingWindow = false;
        });
      }
    }
  }

  Future<void> _exportBackup() async {
    final passphrase = await showDialog<String>(
      context: context,
      builder: (context) {
        return const _BackupPassphraseDialog();
      },
    );

    if (passphrase == null) {
      return;
    }

    setState(() {
      _isBackupBusy = true;
    });

    try {
      final normalizedPassphrase = normalizeBackupPassphraseInput(passphrase);
      if (normalizedPassphrase == null) {
        throw BackupFormatException(
          'Protected exports require a backup passphrase.',
        );
      }
      final json = await ref
          .read(backupServiceProvider)
          .exportToJson(pretty: true, passphrase: normalizedPassphrase);
      if (!mounted) {
        return;
      }

      await showDialog<void>(
        context: context,
        builder: (context) {
          return _BackupExportDialog(
            backupFileTransferService: ref.read(
              backupFileTransferServiceProvider,
            ),
            json: json,
          );
        },
      );
    } catch (error) {
      if (mounted) {
        _showMessage(error.toString());
      }
    } finally {
      if (mounted) {
        setState(() {
          _isBackupBusy = false;
        });
      }
    }
  }

  Future<void> _importBackup() async {
    await _showImportBackupDialog();
  }

  Future<void> _importBackupFile() async {
    setState(() {
      _isBackupBusy = true;
    });

    try {
      final selectedFile = await fs.openFile(
        acceptedTypeGroups: const [_backupFileTypeGroup],
        confirmButtonText: 'Select Backup',
      );
      if (selectedFile == null) {
        return;
      }

      final json = await ref
          .read(backupFileTransferServiceProvider)
          .readBackupFile(selectedFile.path);
      if (!mounted) {
        return;
      }

      await _showImportBackupDialog(initialJson: json);
    } catch (error) {
      if (mounted) {
        _showMessage(error.toString());
      }
    } finally {
      if (mounted) {
        setState(() {
          _isBackupBusy = false;
        });
      }
    }
  }

  Future<void> _showImportBackupDialog({String initialJson = ''}) async {
    final imported = await showDialog<ImportResult>(
      context: context,
      builder: (context) {
        return _BackupImportDialog(
          backupService: ref.read(backupServiceProvider),
          initialJson: initialJson,
        );
      },
    );

    if (imported == null || !mounted) {
      return;
    }

    refreshMilestone3Data(ref);
    _showMessage(
      'Backup imported: ${imported.summary.mosqueCount} mosques, ${imported.summary.timingRuleCount} timing rules.',
    );
  }

  Future<bool?> _showPermissionExplanation({
    required String title,
    required String message,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Continue'),
            ),
          ],
        );
      },
    );
  }

  String? _requiredValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Required';
    }
    return null;
  }

  String? _timezoneValidator(String? value) {
    final requiredMessage = _requiredValidator(value);
    if (requiredMessage != null) {
      return requiredMessage;
    }
    if (!isValidTimezoneName(value!.trim())) {
      return 'Use a valid timezone like Asia/Karachi';
    }
    return null;
  }

  String? _intValidator(String? value) {
    if (int.tryParse(value ?? '') == null) {
      return 'Enter an integer';
    }
    return null;
  }

  String? _nonNegativeIntValidator(String? value) {
    final parsed = int.tryParse(value ?? '');
    if (parsed == null) {
      return 'Enter an integer';
    }
    if (parsed < 0) {
      return 'Use 0 or more';
    }
    return null;
  }

  String? _doubleValidator(String? value) {
    if (double.tryParse(value ?? '') == null) {
      return 'Enter a number';
    }
    return null;
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

class _NotificationMatrix extends StatelessWidget {
  const _NotificationMatrix({
    required this.preferences,
    required this.onChanged,
  });

  final Map<SalahPrayer, PrayerNotificationPreference> preferences;
  final void Function(SalahPrayer prayer, PrayerNotificationPreference value)
  onChanged;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Table(
        columnWidths: const {
          0: IntrinsicColumnWidth(),
          1: FixedColumnWidth(84),
          2: FixedColumnWidth(94),
          3: FixedColumnWidth(84),
        },
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        children: [
          const TableRow(
            children: [
              Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: Text(
                  'Prayer',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: Center(
                  child: Text(
                    'Adhan',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: Center(
                  child: Text(
                    'Reminder',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: Center(
                  child: Text(
                    'Jamaat',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
          for (final prayer in kNotificationPreferencePrayers)
            _buildPrayerRow(
              prayer,
              preferences[prayer] ?? const PrayerNotificationPreference(),
            ),
        ],
      ),
    );
  }

  TableRow _buildPrayerRow(
    SalahPrayer prayer,
    PrayerNotificationPreference preference,
  ) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Text(prayer.label),
        ),
        Center(
          child: Checkbox(
            value: preference.adhanEnabled,
            onChanged: (value) {
              onChanged(
                prayer,
                preference.copyWith(adhanEnabled: value ?? false),
              );
            },
          ),
        ),
        Center(
          child: Checkbox(
            value: preference.reminderEnabled,
            onChanged: (value) {
              onChanged(
                prayer,
                preference.copyWith(reminderEnabled: value ?? false),
              );
            },
          ),
        ),
        Center(
          child: Checkbox(
            value: preference.jamaatEnabled,
            onChanged: (value) {
              onChanged(
                prayer,
                preference.copyWith(jamaatEnabled: value ?? false),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _BackupPassphraseDialog extends StatefulWidget {
  const _BackupPassphraseDialog();

  @override
  State<_BackupPassphraseDialog> createState() =>
      _BackupPassphraseDialogState();
}

class _BackupPassphraseDialogState extends State<_BackupPassphraseDialog> {
  late final TextEditingController _controller;
  bool _obscureText = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Protect backup export'),
      content: SizedBox(
        width: 520,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Backup exports now require a passphrase. SalahSync encrypts the JSON before you copy or share it.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _controller,
              obscureText: _obscureText,
              enableSuggestions: false,
              autocorrect: false,
              decoration: InputDecoration(
                labelText: 'Backup passphrase',
                helperText:
                    'Use at least $kMinBackupPassphraseLength characters.',
                errorText: _error,
                suffixIcon: IconButton(
                  onPressed: () {
                    setState(() {
                      _obscureText = !_obscureText;
                    });
                  },
                  icon: Icon(
                    _obscureText
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Keep the passphrase separate from the JSON. SalahSync cannot recover a lost backup passphrase.',
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _protectExport,
          child: const Text('Protect Export'),
        ),
      ],
    );
  }

  void _protectExport() {
    try {
      final normalized = normalizeBackupPassphraseInput(_controller.text);
      if (normalized == null) {
        setState(() {
          _error = 'Enter a backup passphrase.';
        });
        return;
      }
      Navigator.of(context).pop(normalized);
    } on BackupFormatException catch (error) {
      setState(() {
        _error = error.message;
      });
    }
  }
}

class _BackupExportDialog extends StatelessWidget {
  const _BackupExportDialog({
    required this.backupFileTransferService,
    required this.json,
  });

  final BackupFileTransferService backupFileTransferService;
  final String json;

  @override
  Widget build(BuildContext context) {
    final controller = TextEditingController(text: json);

    return AlertDialog(
      title: const Text('Export backup'),
      content: SizedBox(
        width: 640,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Copy or share this passphrase-protected backup to move your local data to another device or keep a protected snapshot. Keep the JSON and passphrase separate.',
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Text(
                'Clipboard warning: this copied blob is encrypted, but anyone with both the JSON and the passphrase can still restore your data.',
              ),
            ),
            const SizedBox(height: 12),
            Flexible(
              child: TextField(
                controller: controller,
                readOnly: true,
                maxLines: 16,
                minLines: 8,
                decoration: const InputDecoration(
                  labelText: 'Encrypted backup JSON',
                  alignLabelWithHint: true,
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
        FilledButton.tonalIcon(
          onPressed: () async {
            try {
              final staged = await backupFileTransferService.stageBackupFile(
                json,
                encrypted: true,
              );
              final result = await SharePlus.instance.share(
                ShareParams(
                  files: [
                    XFile(
                      staged.path,
                      mimeType: 'application/json',
                      name: staged.fileName,
                    ),
                  ],
                  title: 'SalahSync backup',
                  subject: 'SalahSync backup',
                  text:
                      'SalahSync protected backup file. Keep the passphrase separate from the JSON file.',
                ),
              );
              if (!context.mounted) {
                return;
              }
              final message = switch (result.status) {
                ShareResultStatus.success => 'Backup file shared.',
                ShareResultStatus.dismissed =>
                  'Backup file prepared. Share was dismissed.',
                ShareResultStatus.unavailable =>
                  'Backup file prepared. Share result is unavailable here.',
              };
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(message)));
            } catch (error) {
              if (!context.mounted) {
                return;
              }
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(error.toString())));
            }
          },
          icon: const Icon(Icons.share_outlined),
          label: const Text('Share File'),
        ),
        OutlinedButton.icon(
          onPressed: () async {
            await Clipboard.setData(const ClipboardData(text: ''));
            if (!context.mounted) {
              return;
            }
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Clipboard cleared.')));
          },
          icon: const Icon(Icons.delete_outline_rounded),
          label: const Text('Clear Clipboard'),
        ),
        FilledButton.icon(
          onPressed: () async {
            await Clipboard.setData(ClipboardData(text: json));
            if (!context.mounted) {
              return;
            }
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Encrypted backup JSON copied.')),
            );
          },
          icon: const Icon(Icons.copy_rounded),
          label: const Text('Copy'),
        ),
      ],
    );
  }
}

class _BackupImportDialog extends StatefulWidget {
  const _BackupImportDialog({
    required this.backupService,
    this.initialJson = '',
  });

  final BackupService backupService;
  final String initialJson;

  @override
  State<_BackupImportDialog> createState() => _BackupImportDialogState();
}

class _BackupImportDialogState extends State<_BackupImportDialog> {
  late final TextEditingController _controller;
  late final TextEditingController _passphraseController;
  BackupPreview? _preview;
  String? _error;
  bool _isWorking = false;
  bool _obscurePassphrase = true;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialJson);
    _passphraseController = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    _passphraseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Import backup'),
      content: SizedBox(
        width: 640,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Paste a prior SalahSync backup here. Import replaces the current local database.',
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _passphraseController,
              obscureText: _obscurePassphrase,
              enableSuggestions: false,
              autocorrect: false,
              decoration: InputDecoration(
                labelText: 'Backup passphrase',
                helperText:
                    'Only needed for passphrase-protected exports. Leave blank for plaintext backups.',
                suffixIcon: IconButton(
                  onPressed: () {
                    setState(() {
                      _obscurePassphrase = !_obscurePassphrase;
                    });
                  },
                  icon: Icon(
                    _obscurePassphrase
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _controller,
              maxLines: 12,
              minLines: 6,
              decoration: const InputDecoration(
                labelText: 'Backup JSON',
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 12),
            if (_preview != null) _BackupPreviewCard(preview: _preview!),
            if (_error != null)
              Text(
                _error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isWorking ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        OutlinedButton(
          onPressed: _isWorking ? null : _validate,
          child: const Text('Preview'),
        ),
        FilledButton(
          onPressed: _isWorking || _preview == null ? null : _confirmImport,
          child: Text(_isWorking ? 'Importing...' : 'Import'),
        ),
      ],
    );
  }

  Future<void> _validate() async {
    setState(() {
      _isWorking = true;
      _error = null;
    });

    try {
      final preview = await widget.backupService.previewJsonAsync(
        _controller.text.trim(),
        passphrase: _passphraseController.text,
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _preview = preview;
        _error = null;
        _isWorking = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _preview = null;
        _error = error.toString();
        _isWorking = false;
      });
    }
  }

  Future<void> _confirmImport() async {
    final shouldImport = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Replace local data?'),
          content: const Text(
            'This replaces the current local database with the pasted backup. Notifications and cached screens will be rebuilt afterward.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Replace Data'),
            ),
          ],
        );
      },
    );

    if (shouldImport != true) {
      return;
    }

    setState(() {
      _isWorking = true;
    });

    try {
      final result = await widget.backupService.importFromJson(
        _controller.text.trim(),
        passphrase: _passphraseController.text,
      );
      if (!mounted) {
        return;
      }
      Navigator.of(context).pop(result);
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isWorking = false;
        _error = error.toString();
      });
    }
  }
}

class _BackupPreviewCard extends StatelessWidget {
  const _BackupPreviewCard({required this.preview});

  final BackupPreview preview;

  @override
  Widget build(BuildContext context) {
    final summary = preview.summary;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Backup preview',
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          _RuntimeRow(label: 'Exported', value: preview.exportedAt),
          const SizedBox(height: 6),
          _RuntimeRow(
            label: 'Schema',
            value:
                'backup v${preview.backupSchemaVersion}, db v${preview.databaseSchemaVersion}',
          ),
          const SizedBox(height: 6),
          _RuntimeRow(label: 'Protection', value: preview.protection.label),
          const SizedBox(height: 6),
          _RuntimeRow(label: 'Integrity', value: preview.integrity.label),
          if (preview.protection.isEncrypted) ...[
            const SizedBox(height: 12),
            const _RuntimeBanner(
              icon: Icons.lock_outline_rounded,
              message:
                  'This backup was passphrase-protected at export time. SalahSync only decrypted it after the correct passphrase was provided.',
            ),
          ],
          if (!preview.integrity.isVerified) ...[
            const SizedBox(height: 12),
            const _RuntimeBanner(
              icon: Icons.info_outline_rounded,
              message:
                  'This backup predates checksum metadata, so SalahSync can import it but cannot verify whether it was modified after export.',
            ),
          ],
          const SizedBox(height: 10),
          _RuntimeRow(label: 'Settings', value: '${summary.appSettingsCount}'),
          const SizedBox(height: 6),
          _RuntimeRow(label: 'Mosques', value: '${summary.mosqueCount}'),
          const SizedBox(height: 6),
          _RuntimeRow(label: 'Rules', value: '${summary.timingRuleCount}'),
          const SizedBox(height: 6),
          _RuntimeRow(
            label: 'Ibadah tasks',
            value: '${summary.ibadahTaskCount}',
          ),
          const SizedBox(height: 6),
          _RuntimeRow(
            label: 'Completions',
            value: '${summary.ibadahCompletionCount}',
          ),
          const SizedBox(height: 6),
          _RuntimeRow(label: 'Prayer log', value: '${summary.prayerLogCount}'),
        ],
      ),
    );
  }
}

class _NotificationStatusCard extends StatelessWidget {
  const _NotificationStatusCard({
    required this.status,
    required this.onRequestNotificationPermission,
    required this.onRequestExactPermission,
    required this.onRebuildWindow,
    required this.onRefresh,
  });

  final NotificationRuntimeStatus status;
  final VoidCallback? onRequestNotificationPermission;
  final VoidCallback? onRequestExactPermission;
  final VoidCallback? onRebuildWindow;
  final VoidCallback? onRefresh;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Runtime status',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          _RuntimeRow(label: 'Notifications', value: status.notificationsLabel),
          const SizedBox(height: 8),
          _RuntimeRow(label: 'Precise timing', value: status.exactAlarmLabel),
          const SizedBox(height: 8),
          _RuntimeRow(label: 'Pending alerts', value: status.pendingCountLabel),
          const SizedBox(height: 8),
          const _RuntimeRow(
            label: 'Rolling window',
            value: 'Next 48 hours, rebuilt on launch, resume, and data changes',
          ),
          if (!status.platformAvailable) ...[
            const SizedBox(height: 16),
            _RuntimeBanner(
              icon: Icons.info_outline_rounded,
              message:
                  'Detailed notification diagnostics only work on Android and iOS runtimes. Desktop and test environments can still save preferences, but they cannot verify pending prayer alerts.',
            ),
          ],
          if (status.platformAvailable && !status.notificationsEnabled) ...[
            const SizedBox(height: 16),
            const _RuntimeBanner(
              icon: Icons.notifications_off_rounded,
              message:
                  'Prayer notifications are currently disabled at the OS level. Enable notifications first or no Adhan, Jamaat, Sehri, or Iftar alerts will appear.',
            ),
          ],
          if (status.platformAvailable &&
              status.exactAlarmsSupported &&
              !status.exactAlarmsEnabled) ...[
            const SizedBox(height: 16),
            const _RuntimeBanner(
              icon: Icons.warning_amber_rounded,
              message:
                  'Precise timing access is unavailable, so SalahSync is using inexact fallback scheduling. This still works, but Android may deliver alerts later than the planned minute.',
            ),
          ],
          if (status.platformAvailable) ...[
            const SizedBox(height: 16),
            const _RuntimeBanner(
              icon: Icons.battery_saver_rounded,
              message:
                  'If notifications are missed on Xiaomi, Samsung, or other aggressive battery-managed devices, allow background execution and check dontkillmyapp.com for the manufacturer-specific steps.',
            ),
          ],
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              FilledButton.tonal(
                onPressed: status.platformAvailable
                    ? onRequestNotificationPermission
                    : null,
                child: const Text('Enable Notifications'),
              ),
              if (status.exactAlarmsSupported)
                FilledButton.tonal(
                  onPressed: status.platformAvailable
                      ? onRequestExactPermission
                      : null,
                  child: const Text('Request Precise Timing'),
                ),
              FilledButton(
                onPressed: status.platformAvailable ? onRebuildWindow : null,
                child: const Text('Rebuild 48h Window'),
              ),
              OutlinedButton(
                onPressed: onRefresh,
                child: const Text('Refresh Status'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RuntimeBanner extends StatelessWidget {
  const _RuntimeBanner({required this.icon, required this.message});

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: scheme.surface,
        border: Border.all(color: scheme.outlineVariant),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: scheme.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(message, style: Theme.of(context).textTheme.bodySmall),
          ),
        ],
      ),
    );
  }
}

class _NotificationStatusError extends StatelessWidget {
  const _NotificationStatusError({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Unable to read notification status.',
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(message),
          const SizedBox(height: 12),
          FilledButton.tonal(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}

class _RuntimeRow extends StatelessWidget {
  const _RuntimeRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 110,
          child: Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
        ),
        Expanded(
          child: Text(value, style: Theme.of(context).textTheme.bodyMedium),
        ),
      ],
    );
  }
}

class _SettingsError extends StatelessWidget {
  const _SettingsError({required this.error, required this.onRetry});

  final Object error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Unable to load settings.',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(error.toString(), textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}

String _methodLabel(PrayerCalculationMethodChoice method) {
  return switch (method) {
    PrayerCalculationMethodChoice.karachi => 'Karachi',
    PrayerCalculationMethodChoice.muslimWorldLeague => 'Muslim World League',
    PrayerCalculationMethodChoice.egyptian => 'Egyptian',
    PrayerCalculationMethodChoice.ummAlQura => 'Umm al-Qura',
    PrayerCalculationMethodChoice.dubai => 'Dubai',
    PrayerCalculationMethodChoice.qatar => 'Qatar',
    PrayerCalculationMethodChoice.kuwait => 'Kuwait',
    PrayerCalculationMethodChoice.moonsightingCommittee =>
      'Moonsighting Committee',
    PrayerCalculationMethodChoice.singapore => 'Singapore',
    PrayerCalculationMethodChoice.turkiye => 'Turkiye',
    PrayerCalculationMethodChoice.tehran => 'Tehran',
    PrayerCalculationMethodChoice.other => 'Other',
  };
}

String _asrSchoolLabel(AsrJuristicSchool school) {
  return switch (school) {
    AsrJuristicSchool.hanafi => 'Hanafi',
    AsrJuristicSchool.shafi => 'Shafi',
  };
}

String _ishaEndLabel(IshaEndConvention convention) {
  return switch (convention) {
    IshaEndConvention.midnight => 'Midnight',
    IshaEndConvention.fajr => 'Fajr',
  };
}

String _adjustmentFieldLabel(String key) {
  return switch (key) {
    'fajr' => 'Fajr',
    'sunrise' => 'Sunrise',
    'dhuhr' => 'Dhuhr',
    'asr' => 'Asr',
    'maghrib' => 'Maghrib',
    'isha' => 'Isha',
    _ => key,
  };
}

enum _RamadanOverrideChoice {
  system('System / auto'),
  forceOn('Force on'),
  forceOff('Force off');

  const _RamadanOverrideChoice(this.label);

  final String label;
}

const List<String> _adjustmentPrayerKeys = [
  'fajr',
  'sunrise',
  'dhuhr',
  'asr',
  'maghrib',
  'isha',
];

const List<List<String>> _adjustmentRows = [
  ['fajr', 'sunrise'],
  ['dhuhr', 'asr'],
  ['maghrib', 'isha'],
];
