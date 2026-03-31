import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../core/ibadah/ibadah_task_prayer_link.dart';
import '../../../core/ibadah/ibadah_task_repeat_type.dart';
import '../../../core/ibadah/ibadah_task_timing.dart';
import '../../../data/models/ibadah_task.dart';
import '../../../data/models/ibadah_task_draft.dart';
import '../../../data/repositories/ibadah_task_repository.dart';

class TaskEditorScreen extends ConsumerStatefulWidget {
  const TaskEditorScreen({super.key, this.task});

  final IbadahTask? task;

  @override
  ConsumerState<TaskEditorScreen> createState() => _TaskEditorScreenState();
}

class _TaskEditorScreenState extends ConsumerState<TaskEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _countTargetController;

  late IbadahTaskPrayerLink _prayerLink;
  late IbadahTaskTiming _timing;
  late IbadahTaskRepeatType _repeatType;
  late bool _isActive;
  late Set<int> _repeatDays;
  var _isSaving = false;

  @override
  void initState() {
    super.initState();
    final task = widget.task;
    _titleController = TextEditingController(text: task?.title ?? '');
    _descriptionController = TextEditingController(
      text: task?.description ?? '',
    );
    _countTargetController = TextEditingController(
      text: task?.countTarget?.toString() ?? '',
    );
    _prayerLink = task?.prayerLink ?? IbadahTaskPrayerLink.none;
    _timing = task?.timing ?? IbadahTaskTiming.after;
    _repeatType = task?.repeatType ?? IbadahTaskRepeatType.daily;
    _isActive = task?.isActive ?? true;
    _repeatDays = {...?task?.repeatDays};
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _countTargetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final countHelp = _repeatType == IbadahTaskRepeatType.afterEveryPrayer
        ? 'Use a target for tasbih-style counters after each prayer.'
        : 'Leave blank for a simple checkbox task.';

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.task == null ? 'Add task' : 'Edit task'),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title'),
                textCapitalization: TextCapitalization.sentences,
                validator: _requiredValidator,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                minLines: 2,
                maxLines: 4,
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 14),
              DropdownButtonFormField<IbadahTaskRepeatType>(
                initialValue: _repeatType,
                decoration: const InputDecoration(labelText: 'Repeat pattern'),
                items: IbadahTaskRepeatType.values
                    .map(
                      (value) => DropdownMenuItem(
                        value: value,
                        child: Text(value.label),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value == null) {
                    return;
                  }
                  setState(() {
                    _repeatType = value;
                    if (value == IbadahTaskRepeatType.afterEveryPrayer) {
                      _timing = IbadahTaskTiming.after;
                      _prayerLink = IbadahTaskPrayerLink.anyPrayer;
                    }
                    if (!value.requiresDaySelection) {
                      _repeatDays = <int>{};
                    }
                  });
                },
              ),
              const SizedBox(height: 14),
              DropdownButtonFormField<IbadahTaskPrayerLink>(
                initialValue: _prayerLink,
                decoration: const InputDecoration(labelText: 'Prayer link'),
                items: IbadahTaskPrayerLink.values
                    .map(
                      (value) => DropdownMenuItem(
                        value: value,
                        child: Text(value.label),
                      ),
                    )
                    .toList(),
                onChanged: _repeatType == IbadahTaskRepeatType.afterEveryPrayer
                    ? null
                    : (value) {
                        if (value != null) {
                          setState(() {
                            _prayerLink = value;
                          });
                        }
                      },
              ),
              const SizedBox(height: 14),
              DropdownButtonFormField<IbadahTaskTiming>(
                initialValue: _timing,
                decoration: const InputDecoration(labelText: 'Timing'),
                items: IbadahTaskTiming.values
                    .map(
                      (value) => DropdownMenuItem(
                        value: value,
                        child: Text(value.label),
                      ),
                    )
                    .toList(),
                onChanged: _repeatType == IbadahTaskRepeatType.afterEveryPrayer
                    ? null
                    : (value) {
                        if (value != null) {
                          setState(() {
                            _timing = value;
                          });
                        }
                      },
              ),
              if (_repeatType.requiresDaySelection) ...[
                const SizedBox(height: 18),
                Text(
                  _repeatType == IbadahTaskRepeatType.weekly
                      ? 'Choose one weekday'
                      : 'Choose weekdays',
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final day in _weekdayOptions)
                      FilterChip(
                        label: Text(day.label),
                        selected: _repeatDays.contains(day.weekday),
                        onSelected: (selected) {
                          setState(() {
                            if (_repeatType == IbadahTaskRepeatType.weekly) {
                              _repeatDays = selected ? {day.weekday} : <int>{};
                            } else if (selected) {
                              _repeatDays = {..._repeatDays, day.weekday};
                            } else {
                              _repeatDays = {
                                for (final value in _repeatDays)
                                  if (value != day.weekday) value,
                              };
                            }
                          });
                        },
                      ),
                  ],
                ),
              ],
              const SizedBox(height: 18),
              TextFormField(
                controller: _countTargetController,
                decoration: InputDecoration(
                  labelText: 'Count target',
                  helperText: countHelp,
                ),
                keyboardType: TextInputType.number,
                validator: _countValidator,
              ),
              const SizedBox(height: 8),
              SwitchListTile(
                value: _isActive,
                onChanged: (value) {
                  setState(() {
                    _isActive = value;
                  });
                },
                contentPadding: EdgeInsets.zero,
                title: const Text('Active'),
                subtitle: const Text('Paused tasks stay in the library only.'),
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _isSaving ? null : _save,
                child: Text(_isSaving ? 'Saving...' : 'Save task'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final countTarget = int.tryParse(_countTargetController.text.trim());
      await ref
          .read(ibadahTaskRepositoryProvider)
          .save(
            IbadahTaskDraft(
              id: widget.task?.id,
              title: _titleController.text.trim(),
              description: _descriptionController.text.trim(),
              prayerLink: _repeatType == IbadahTaskRepeatType.afterEveryPrayer
                  ? IbadahTaskPrayerLink.anyPrayer
                  : _prayerLink,
              timing: _repeatType == IbadahTaskRepeatType.afterEveryPrayer
                  ? IbadahTaskTiming.after
                  : _timing,
              repeatType: _repeatType,
              repeatDays: _repeatDays,
              countTarget: countTarget,
              isActive: _isActive,
              sortOrder: widget.task?.sortOrder ?? 0,
            ),
          );
      if (!mounted) {
        return;
      }
      Navigator.of(context).pop(true);
    } on IbadahTaskValidationException catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message)));
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  String? _requiredValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Required';
    }
    return null;
  }

  String? _countValidator(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) {
      return null;
    }
    final parsed = int.tryParse(trimmed);
    if (parsed == null || parsed < 1) {
      return 'Enter a number greater than 0';
    }
    return null;
  }
}

class _WeekdayOption {
  const _WeekdayOption({required this.weekday, required this.label});

  final int weekday;
  final String label;
}

const _weekdayOptions = <_WeekdayOption>[
  _WeekdayOption(weekday: DateTime.monday, label: 'Mon'),
  _WeekdayOption(weekday: DateTime.tuesday, label: 'Tue'),
  _WeekdayOption(weekday: DateTime.wednesday, label: 'Wed'),
  _WeekdayOption(weekday: DateTime.thursday, label: 'Thu'),
  _WeekdayOption(weekday: DateTime.friday, label: 'Fri'),
  _WeekdayOption(weekday: DateTime.saturday, label: 'Sat'),
  _WeekdayOption(weekday: DateTime.sunday, label: 'Sun'),
];
