import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../core/prayer_log/prayer_log_status.dart';
import '../../../core/time/salah_prayer.dart';
import '../../../core/utils/date_key.dart';
import '../../../data/models/prayer_log_draft.dart';
import '../../../data/models/prayer_log_read_model.dart';

class PrayerLogScreen extends ConsumerStatefulWidget {
  const PrayerLogScreen({super.key});

  @override
  ConsumerState<PrayerLogScreen> createState() => _PrayerLogScreenState();
}

class _PrayerLogScreenState extends ConsumerState<PrayerLogScreen> {
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = startOfDay(DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    final modelAsync = ref.watch(prayerLogDayProvider(_selectedDate));

    return Scaffold(
      appBar: AppBar(title: const Text('Prayer log')),
      body: modelAsync.when(
        data: (model) => ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            _PrayerLogHeader(
              date: _selectedDate,
              onPrevious: () {
                setState(() {
                  _selectedDate = _selectedDate.subtract(
                    const Duration(days: 1),
                  );
                });
              },
              onNext: () {
                setState(() {
                  _selectedDate = _selectedDate.add(const Duration(days: 1));
                });
              },
              onPickDate: _pickDate,
            ),
            const SizedBox(height: 16),
            _PrayerLogSummaryCard(model: model),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    for (var index = 0; index < model.rows.length; index++) ...[
                      _PrayerLogRowTile(
                        row: model.rows[index],
                        date: _selectedDate,
                      ),
                      if (index < model.rows.length - 1)
                        const Divider(height: 1),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Unable to load prayer log',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(error.toString(), textAlign: TextAlign.center),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () =>
                      ref.invalidate(prayerLogDayProvider(_selectedDate)),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2025),
      lastDate: DateTime(2035),
    );
    if (picked == null) {
      return;
    }
    setState(() {
      _selectedDate = startOfDay(picked);
    });
  }
}

class _PrayerLogHeader extends StatelessWidget {
  const _PrayerLogHeader({
    required this.date,
    required this.onPrevious,
    required this.onNext,
    required this.onPickDate,
  });

  final DateTime date;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback onPickDate;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            IconButton(
              onPressed: onPrevious,
              icon: const Icon(Icons.chevron_left_rounded),
            ),
            Expanded(
              child: InkWell(
                onTap: onPickDate,
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Column(
                    children: [
                      Text(
                        _weekdayLabel(date.weekday),
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${_monthLabel(date.month)} ${date.day}, ${date.year}',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            IconButton(
              onPressed: onNext,
              icon: const Icon(Icons.chevron_right_rounded),
            ),
          ],
        ),
      ),
    );
  }
}

class _PrayerLogSummaryCard extends StatelessWidget {
  const _PrayerLogSummaryCard({required this.model});

  final PrayerLogDayReadModel model;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _SummaryChip(
              label: 'Week Jamaat',
              value: '${model.weekSummary.jamaat}',
            ),
            _SummaryChip(
              label: 'Week Missed',
              value: '${model.weekSummary.missed}',
            ),
            _SummaryChip(
              label: 'Month Jamaat',
              value: '${model.monthSummary.jamaat}',
            ),
            _SummaryChip(
              label: 'Month Logged',
              value: '${model.monthSummary.total}',
            ),
          ],
        ),
      ),
    );
  }
}

class _PrayerLogRowTile extends ConsumerWidget {
  const _PrayerLogRowTile({required this.row, required this.date});

  final PrayerLogDayRow row;
  final DateTime date;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = row.status;
    final badge = _statusBadge(status, Theme.of(context).colorScheme);
    final subtitle = [
      if (status != null) status.label,
      if (row.mosque != null) row.mosque!.name,
      if (row.record?.notes != null && row.record!.notes!.isNotEmpty)
        row.record!.notes!,
    ].join(' • ');

    return ListTile(
      leading: Icon(badge.icon, color: badge.color),
      title: Text(
        row.prayer.label,
        style: Theme.of(
          context,
        ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
      ),
      subtitle: Text(subtitle.isEmpty ? 'Not logged' : subtitle),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: badge.color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          badge.label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: badge.color,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      onTap: () async {
        final didChange = await showModalBottomSheet<bool>(
          context: context,
          isScrollControlled: true,
          builder: (_) => PrayerLogEditorSheet(date: date, row: row),
        );
        if (didChange == true) {
          refreshPrayerLogData(ref, date);
        }
      },
    );
  }
}

class PrayerLogEditorSheet extends ConsumerStatefulWidget {
  const PrayerLogEditorSheet({
    super.key,
    required this.date,
    required this.row,
  });

  final DateTime date;
  final PrayerLogDayRow row;

  @override
  ConsumerState<PrayerLogEditorSheet> createState() =>
      _PrayerLogEditorSheetState();
}

class _PrayerLogEditorSheetState extends ConsumerState<PrayerLogEditorSheet> {
  late PrayerLogStatus _status;
  int? _mosqueId;
  late final TextEditingController _notesController;
  var _isSaving = false;

  @override
  void initState() {
    super.initState();
    _status = widget.row.status ?? PrayerLogStatus.jamaat;
    _mosqueId = widget.row.record?.mosqueId;
    _notesController = TextEditingController(
      text: widget.row.record?.notes ?? '',
    );
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mosquesAsync = ref.watch(mosquesProvider);

    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: mosquesAsync.when(
        data: (mosques) {
          final activeMosques = mosques
              .where((mosque) => mosque.isActive)
              .toList();

          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.row.prayer.label,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 16),
              SegmentedButton<PrayerLogStatus>(
                selected: {_status},
                showSelectedIcon: false,
                segments: [
                  for (final status in PrayerLogStatus.values)
                    ButtonSegment(value: status, label: Text(status.label)),
                ],
                onSelectionChanged: (selection) {
                  setState(() {
                    _status = selection.first;
                    if (_status != PrayerLogStatus.jamaat) {
                      _mosqueId = null;
                    }
                  });
                },
              ),
              if (_status == PrayerLogStatus.jamaat) ...[
                const SizedBox(height: 16),
                DropdownButtonFormField<int?>(
                  initialValue: _mosqueId,
                  decoration: const InputDecoration(labelText: 'Mosque'),
                  items: [
                    const DropdownMenuItem<int?>(
                      value: null,
                      child: Text('No mosque selected'),
                    ),
                    for (final mosque in activeMosques)
                      DropdownMenuItem<int?>(
                        value: mosque.id,
                        child: Text(mosque.name),
                      ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _mosqueId = value;
                    });
                  },
                ),
              ],
              const SizedBox(height: 16),
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(labelText: 'Notes'),
                minLines: 2,
                maxLines: 4,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isSaving
                          ? null
                          : () async {
                              final navigator = Navigator.of(context);
                              await ref
                                  .read(prayerLogRepositoryProvider)
                                  .clear(
                                    date: widget.date,
                                    prayer: widget.row.prayer,
                                  );
                              if (context.mounted) {
                                navigator.pop(true);
                              }
                            },
                      child: const Text('Clear'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: _isSaving
                          ? null
                          : () async {
                              final navigator = Navigator.of(context);
                              setState(() {
                                _isSaving = true;
                              });
                              await ref
                                  .read(prayerLogRepositoryProvider)
                                  .save(
                                    PrayerLogDraft(
                                      date: widget.date,
                                      prayer: widget.row.prayer,
                                      status: _status,
                                      mosqueId:
                                          _status == PrayerLogStatus.jamaat
                                          ? _mosqueId
                                          : null,
                                      notes: _notesController.text.trim(),
                                    ),
                                  );
                              if (context.mounted) {
                                navigator.pop(true);
                              }
                            },
                      child: const Text('Save'),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Padding(
          padding: const EdgeInsets.all(12),
          child: Text(error.toString()),
        ),
      ),
    );
  }
}

class _SummaryChip extends StatelessWidget {
  const _SummaryChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelMedium),
          const SizedBox(height: 2),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge {
  const _StatusBadge({
    required this.label,
    required this.icon,
    required this.color,
  });

  final String label;
  final IconData icon;
  final Color color;
}

_StatusBadge _statusBadge(PrayerLogStatus? status, ColorScheme scheme) {
  return switch (status) {
    PrayerLogStatus.jamaat => _StatusBadge(
      label: 'Jamaat',
      icon: Icons.groups_rounded,
      color: scheme.primary,
    ),
    PrayerLogStatus.alone => _StatusBadge(
      label: 'Alone',
      icon: Icons.person_rounded,
      color: scheme.tertiary,
    ),
    PrayerLogStatus.missed => _StatusBadge(
      label: 'Missed',
      icon: Icons.close_rounded,
      color: scheme.error,
    ),
    null => _StatusBadge(
      label: 'Open',
      icon: Icons.radio_button_unchecked_rounded,
      color: scheme.outline,
    ),
  };
}

String _weekdayLabel(int weekday) {
  const labels = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];
  return labels[weekday - 1];
}

String _monthLabel(int month) {
  const labels = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];
  return labels[month - 1];
}
