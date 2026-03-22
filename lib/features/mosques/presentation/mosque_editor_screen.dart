import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../core/mosque/month_day.dart';
import '../../../core/mosque/time_of_day_value.dart';
import '../../../core/mosque/timing_rule.dart';
import '../../../core/time/salah_prayer.dart';
import '../../../data/db/app_database.dart';
import '../../../data/models/mosque_draft.dart';
import '../../../data/models/timing_rule_draft.dart';
import '../../../data/repositories/timing_rule_repository.dart';

class MosqueEditorScreen extends ConsumerWidget {
  const MosqueEditorScreen({super.key, this.mosqueId});

  final int? mosqueId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (mosqueId == null) {
      return const _MosqueEditorForm(initialMosque: null, initialRules: []);
    }

    final mosqueAsync = ref.watch(mosqueByIdProvider(mosqueId!));
    final rulesAsync = ref.watch(timingRulesForMosqueProvider(mosqueId!));

    if (mosqueAsync.isLoading || rulesAsync.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (mosqueAsync.hasError) {
      return _EditorErrorScaffold(
        message: mosqueAsync.error.toString(),
        onRetry: () => ref.invalidate(mosqueByIdProvider(mosqueId!)),
      );
    }
    if (rulesAsync.hasError) {
      return _EditorErrorScaffold(
        message: rulesAsync.error.toString(),
        onRetry: () => ref.invalidate(timingRulesForMosqueProvider(mosqueId!)),
      );
    }

    final mosque = mosqueAsync.value;
    if (mosque == null) {
      return const _EditorErrorScaffold(
        message: 'The requested mosque could not be found.',
      );
    }

    final rules = rulesAsync.value ?? const <TimingRuleEntry>[];
    final rulesFingerprint = rules
        .map((rule) => '${rule.id}:${rule.priority}:${rule.createdAt}')
        .join('|');

    return _MosqueEditorForm(
      key: ValueKey('${mosque.id}-${mosque.updatedAt}-$rulesFingerprint'),
      initialMosque: mosque,
      initialRules: rules,
    );
  }
}

class _MosqueEditorForm extends ConsumerStatefulWidget {
  const _MosqueEditorForm({
    super.key,
    required this.initialMosque,
    required this.initialRules,
  });

  final Mosque? initialMosque;
  final List<TimingRuleEntry> initialRules;

  @override
  ConsumerState<_MosqueEditorForm> createState() => _MosqueEditorFormState();
}

class _MosqueEditorFormState extends ConsumerState<_MosqueEditorForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _areaController;
  late final TextEditingController _latitudeController;
  late final TextEditingController _longitudeController;
  late final TextEditingController _notesController;

  late bool _isActive;
  late bool _isPrimary;
  int? _mosqueId;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final mosque = widget.initialMosque;
    _mosqueId = mosque?.id;
    _nameController = TextEditingController(text: mosque?.name ?? '');
    _areaController = TextEditingController(text: mosque?.area ?? '');
    _latitudeController = TextEditingController(
      text: mosque?.latitude?.toString() ?? '',
    );
    _longitudeController = TextEditingController(
      text: mosque?.longitude?.toString() ?? '',
    );
    _notesController = TextEditingController(text: mosque?.notes ?? '');
    _isActive = mosque?.isActive ?? true;
    _isPrimary = mosque?.isPrimary ?? false;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _areaController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.initialMosque != null;
    final sortedRules = _sortedRules(widget.initialRules);

    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? 'Edit Mosque' : 'New Mosque')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          children: [
            _SectionCard(
              title: 'Mosque details',
              description:
                  'Store the mosque identity, optional coordinates, notes, and whether this record stays active in daily views.',
              child: Column(
                children: [
                  TextFormField(
                    controller: _nameController,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(labelText: 'Name'),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Name is required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _areaController,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'Area / address',
                    ),
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
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return null;
                            }
                            return double.tryParse(value.trim()) == null
                                ? 'Invalid'
                                : null;
                          },
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
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return null;
                            }
                            return double.tryParse(value.trim()) == null
                                ? 'Invalid'
                                : null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  SwitchListTile.adaptive(
                    value: _isActive,
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Active mosque'),
                    subtitle: const Text(
                      'Archived mosques stay in the database but disappear from daily comparison and home selection.',
                    ),
                    onChanged: (value) {
                      setState(() {
                        _isActive = value;
                        if (!value) {
                          _isPrimary = false;
                        }
                      });
                    },
                  ),
                  SwitchListTile.adaptive(
                    value: _isPrimary,
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Primary / notification mosque'),
                    subtitle: const Text(
                      'Only one active mosque can hold this role at a time.',
                    ),
                    onChanged: _isActive
                        ? (value) {
                            setState(() {
                              _isPrimary = value;
                            });
                          }
                        : null,
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _notesController,
                    minLines: 3,
                    maxLines: 5,
                    decoration: const InputDecoration(
                      labelText: 'Notes',
                      alignLabelWithHint: true,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _SectionCard(
              title: 'Jamaat rules',
              description: _mosqueId == null
                  ? 'Save the mosque once before adding per-prayer offset, fixed, or seasonal rules.'
                  : 'Rules apply to Fajr, Dhuhr, Asr, Maghrib, Isha, and Jummah. Seasonal overlaps are blocked by the repository.',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FilledButton.tonalIcon(
                    onPressed: _mosqueId == null ? null : _addRule,
                    icon: const Icon(Icons.add_alarm_rounded),
                    label: const Text('Add Rule'),
                  ),
                  const SizedBox(height: 16),
                  if (_mosqueId == null)
                    const Text('Save the mosque to enable rule editing.')
                  else if (sortedRules.isEmpty)
                    const Text('No rules yet. Add the first Jamaat rule.')
                  else
                    for (final rule in sortedRules) ...[
                      _RuleTile(
                        rule: rule,
                        onEdit: () => _editRule(rule),
                        onDelete: () => _deleteRule(rule),
                      ),
                      if (rule != sortedRules.last) const Divider(height: 24),
                    ],
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isSaving
                        ? null
                        : () => Navigator.of(context).maybePop(),
                    child: const Text('Close'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: _isSaving ? null : _saveMosque,
                    child: Text(_isSaving ? 'Saving...' : 'Save Mosque'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<TimingRuleEntry> _sortedRules(List<TimingRuleEntry> rules) {
    final prayerOrder = {
      for (var index = 0; index < _editablePrayers.length; index++)
        _editablePrayers[index]: index,
    };
    final sorted = [...rules];
    sorted.sort((left, right) {
      final prayerCompare = (prayerOrder[left.prayer] ?? 99).compareTo(
        prayerOrder[right.prayer] ?? 99,
      );
      if (prayerCompare != 0) {
        return prayerCompare;
      }
      final priorityCompare = right.priority.compareTo(left.priority);
      if (priorityCompare != 0) {
        return priorityCompare;
      }
      return left.id.compareTo(right.id);
    });
    return sorted;
  }

  Future<void> _saveMosque() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final latitudeText = _latitudeController.text.trim();
    final longitudeText = _longitudeController.text.trim();
    if ((latitudeText.isEmpty && longitudeText.isNotEmpty) ||
        (latitudeText.isNotEmpty && longitudeText.isEmpty)) {
      _showMessage('Enter both latitude and longitude or leave both blank.');
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final savedId = await ref
          .read(mosqueRepositoryProvider)
          .save(
            MosqueDraft(
              id: _mosqueId,
              name: _nameController.text.trim(),
              area: _emptyToNull(_areaController.text),
              latitude: latitudeText.isEmpty
                  ? null
                  : double.parse(latitudeText),
              longitude: longitudeText.isEmpty
                  ? null
                  : double.parse(longitudeText),
              isPrimary: _isPrimary,
              isActive: _isActive,
              notes: _emptyToNull(_notesController.text),
            ),
          );

      refreshMilestone3Data(ref, mosqueId: savedId, includeSettings: false);
      setState(() {
        _mosqueId = savedId;
        _isSaving = false;
      });
      _showMessage(
        widget.initialMosque == null
            ? 'Mosque saved. You can add Jamaat rules now.'
            : 'Mosque updated.',
      );
    } catch (error) {
      setState(() {
        _isSaving = false;
      });
      _showMessage(error.toString());
    }
  }

  Future<void> _addRule() async {
    final mosqueId = _mosqueId;
    if (mosqueId == null) {
      return;
    }

    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return _TimingRuleEditorSheet(mosqueId: mosqueId);
      },
    );

    if (saved == true) {
      refreshMilestone3Data(ref, mosqueId: mosqueId, includeSettings: false);
    }
  }

  Future<void> _editRule(TimingRuleEntry rule) async {
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return _TimingRuleEditorSheet(
          mosqueId: rule.mosqueId,
          initialRule: rule,
        );
      },
    );

    if (saved == true) {
      refreshMilestone3Data(
        ref,
        mosqueId: rule.mosqueId,
        includeSettings: false,
      );
    }
  }

  Future<void> _deleteRule(TimingRuleEntry rule) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete timing rule?'),
          content: Text(
            'Delete the ${rule.prayer.label} ${_modeLabel(rule.mode)} rule?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true) {
      return;
    }

    try {
      await ref.read(timingRuleRepositoryProvider).delete(rule.id);
      refreshMilestone3Data(
        ref,
        mosqueId: rule.mosqueId,
        includeSettings: false,
      );
    } catch (error) {
      _showMessage(error.toString());
    }
  }

  String? _emptyToNull(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return null;
    }
    return trimmed;
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

class _TimingRuleEditorSheet extends ConsumerStatefulWidget {
  const _TimingRuleEditorSheet({required this.mosqueId, this.initialRule});

  final int mosqueId;
  final TimingRuleEntry? initialRule;

  @override
  ConsumerState<_TimingRuleEditorSheet> createState() =>
      _TimingRuleEditorSheetState();
}

class _TimingRuleEditorSheetState
    extends ConsumerState<_TimingRuleEditorSheet> {
  final _formKey = GlobalKey<FormState>();
  late SalahPrayer _prayer;
  late TimingRuleMode _mode;
  late final TextEditingController _offsetController;
  late final TextEditingController _priorityController;
  late final TextEditingController _rangeStartController;
  late final TextEditingController _rangeEndController;
  TimeOfDayValue? _fixedTime;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final rule = widget.initialRule;
    _prayer = rule?.prayer ?? SalahPrayer.fajr;
    _mode = rule?.mode ?? TimingRuleMode.offset;
    _offsetController = TextEditingController(
      text: rule?.offsetMinutes?.toString() ?? '',
    );
    _priorityController = TextEditingController(
      text: rule?.priority.toString() ?? '0',
    );
    _rangeStartController = TextEditingController(
      text: rule?.rangeStart?.toString() ?? '',
    );
    _rangeEndController = TextEditingController(
      text: rule?.rangeEnd?.toString() ?? '',
    );
    _fixedTime = rule?.fixedTime;
  }

  @override
  void dispose() {
    _offsetController.dispose();
    _priorityController.dispose();
    _rangeStartController.dispose();
    _rangeEndController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewInsets = MediaQuery.of(context).viewInsets;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(20, 20, 20, viewInsets.bottom + 20),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.initialRule == null
                      ? 'Add timing rule'
                      : 'Edit timing rule',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<SalahPrayer>(
                  key: ValueKey(_prayer),
                  initialValue: _prayer,
                  decoration: const InputDecoration(labelText: 'Prayer'),
                  items: _editablePrayers
                      .map(
                        (prayer) => DropdownMenuItem(
                          value: prayer,
                          child: Text(prayer.label),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value == null) {
                      return;
                    }
                    setState(() {
                      _prayer = value;
                    });
                  },
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<TimingRuleMode>(
                  key: ValueKey(_mode),
                  initialValue: _mode,
                  decoration: const InputDecoration(labelText: 'Rule mode'),
                  items: TimingRuleMode.values
                      .map(
                        (mode) => DropdownMenuItem(
                          value: mode,
                          child: Text(_modeLabel(mode)),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value == null) {
                      return;
                    }
                    setState(() {
                      _mode = value;
                    });
                  },
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _priorityController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Priority',
                    helperText:
                        'Higher priority wins when multiple rules match.',
                  ),
                  validator: (value) {
                    if (int.tryParse(value ?? '') == null) {
                      return 'Enter a valid integer';
                    }
                    return null;
                  },
                ),
                if (_mode == TimingRuleMode.offset) ...[
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _offsetController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Offset minutes',
                      helperText:
                          'Positive values mean after the computed prayer start.',
                    ),
                    validator: (value) {
                      if (_mode != TimingRuleMode.offset) {
                        return null;
                      }
                      if (int.tryParse(value ?? '') == null) {
                        return 'Enter an integer minute offset';
                      }
                      return null;
                    },
                  ),
                ],
                if (_mode != TimingRuleMode.offset) ...[
                  const SizedBox(height: 14),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Fixed time'),
                    subtitle: Text(_fixedTime?.toString() ?? 'Pick a time'),
                    trailing: FilledButton.tonal(
                      onPressed: _pickTime,
                      child: const Text('Choose'),
                    ),
                  ),
                ],
                if (_mode == TimingRuleMode.dateRangeFixed) ...[
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _rangeStartController,
                          decoration: const InputDecoration(
                            labelText: 'Range start',
                            helperText: 'MM-DD',
                          ),
                          validator: (value) {
                            if (_mode != TimingRuleMode.dateRangeFixed) {
                              return null;
                            }
                            return _validateMonthDay(value);
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _rangeEndController,
                          decoration: const InputDecoration(
                            labelText: 'Range end',
                            helperText: 'MM-DD',
                          ),
                          validator: (value) {
                            if (_mode != TimingRuleMode.dateRangeFixed) {
                              return null;
                            }
                            return _validateMonthDay(value);
                          },
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _isSaving
                            ? null
                            : () => Navigator.of(context).pop(false),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        onPressed: _isSaving ? null : _save,
                        child: Text(_isSaving ? 'Saving...' : 'Save Rule'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: _fixedTime?.hour ?? 13,
        minute: _fixedTime?.minute ?? 0,
      ),
    );

    if (picked == null) {
      return;
    }

    setState(() {
      _fixedTime = TimeOfDayValue(hour: picked.hour, minute: picked.minute);
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_mode != TimingRuleMode.offset && _fixedTime == null) {
      _showError('Choose a fixed time first.');
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      await ref
          .read(timingRuleRepositoryProvider)
          .save(
            TimingRuleDraft(
              id: widget.initialRule?.id,
              mosqueId: widget.mosqueId,
              prayer: _prayer,
              mode: _mode,
              offsetMinutes: _mode == TimingRuleMode.offset
                  ? int.parse(_offsetController.text.trim())
                  : null,
              fixedTime: _mode == TimingRuleMode.offset ? null : _fixedTime,
              rangeStart: _mode == TimingRuleMode.dateRangeFixed
                  ? _parseMonthDay(_rangeStartController.text)
                  : null,
              rangeEnd: _mode == TimingRuleMode.dateRangeFixed
                  ? _parseMonthDay(_rangeEndController.text)
                  : null,
              priority: int.parse(_priorityController.text.trim()),
            ),
          );

      if (!mounted) {
        return;
      }
      Navigator.of(context).pop(true);
    } on TimingRuleValidationException catch (error) {
      setState(() {
        _isSaving = false;
      });
      _showError(error.message);
    } catch (error) {
      setState(() {
        _isSaving = false;
      });
      _showError(error.toString());
    }
  }

  String? _validateMonthDay(String? value) {
    try {
      _parseMonthDay(value ?? '');
      return null;
    } catch (_) {
      return 'Use MM-DD';
    }
  }

  MonthDay _parseMonthDay(String input) {
    final trimmed = input.trim();
    final match = RegExp(r'^\d{2}-\d{2}$').hasMatch(trimmed);
    if (!match) {
      throw const FormatException('Use MM-DD');
    }

    final parsed = MonthDay.parse(trimmed);
    if (parsed.month < 1 ||
        parsed.month > 12 ||
        parsed.day < 1 ||
        parsed.day > 31) {
      throw const FormatException('Invalid month/day');
    }
    return parsed;
  }

  void _showError(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.description,
    required this.child,
  });

  final String title;
  final String description;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
            ),
            const SizedBox(height: 18),
            child,
          ],
        ),
      ),
    );
  }
}

class _RuleTile extends StatelessWidget {
  const _RuleTile({
    required this.rule,
    required this.onEdit,
    required this.onDelete,
  });

  final TimingRuleEntry rule;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                rule.prayer.label,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 4),
              Text(
                _ruleSummary(rule),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              'P${rule.priority}',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: scheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                IconButton(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_rounded),
                  tooltip: 'Edit rule',
                ),
                IconButton(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline_rounded),
                  tooltip: 'Delete rule',
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

class _EditorErrorScaffold extends StatelessWidget {
  const _EditorErrorScaffold({required this.message, this.onRetry});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mosque Editor')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                message,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              if (onRetry != null) ...[
                const SizedBox(height: 16),
                FilledButton(onPressed: onRetry, child: const Text('Retry')),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

String _ruleSummary(TimingRuleEntry rule) {
  return switch (rule.mode) {
    TimingRuleMode.offset =>
      'Offset rule: ${rule.offsetMinutes! >= 0 ? '+' : ''}${rule.offsetMinutes} min',
    TimingRuleMode.fixed => 'Fixed rule: ${rule.fixedTime}',
    TimingRuleMode.dateRangeFixed =>
      'Seasonal rule: ${rule.fixedTime} (${rule.rangeStart} to ${rule.rangeEnd})',
  };
}

String _modeLabel(TimingRuleMode mode) {
  return switch (mode) {
    TimingRuleMode.offset => 'Offset',
    TimingRuleMode.fixed => 'Fixed',
    TimingRuleMode.dateRangeFixed => 'Date-range fixed',
  };
}

const List<SalahPrayer> _editablePrayers = [
  SalahPrayer.fajr,
  SalahPrayer.dhuhr,
  SalahPrayer.asr,
  SalahPrayer.maghrib,
  SalahPrayer.isha,
  SalahPrayer.jummah,
];
