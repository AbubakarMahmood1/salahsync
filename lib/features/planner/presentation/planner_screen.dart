import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../core/ibadah/ibadah_task_prayer_link.dart';
import '../../../core/ibadah/ibadah_task_repeat_type.dart';
import '../../../core/time/salah_prayer.dart';
import '../../../core/utils/date_key.dart';
import '../../../data/models/ibadah_planner_read_model.dart';
import '../../../data/models/ibadah_task.dart';
import '../../../data/models/ibadah_task_draft.dart';
import 'task_editor_screen.dart';
import 'tasbih_counter_screen.dart';

class PlannerScreen extends ConsumerWidget {
  const PlannerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final today = startOfDay(DateTime.now());
    final plannerAsync = ref.watch(ibadahPlannerProvider(today));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ibadah planner'),
        actions: [
          IconButton(
            onPressed: () => _openTaskEditor(context, ref, today),
            icon: const Icon(Icons.add_rounded),
            tooltip: 'Add task',
          ),
        ],
      ),
      body: plannerAsync.when(
        data: (model) => _PlannerBody(model: model, date: today),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _PlannerError(
          message: error.toString(),
          onRetry: () => ref.invalidate(ibadahPlannerProvider(today)),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openTaskEditor(context, ref, today),
        icon: const Icon(Icons.add_task_rounded),
        label: const Text('Add task'),
      ),
    );
  }

  Future<void> _openTaskEditor(
    BuildContext context,
    WidgetRef ref,
    DateTime date, {
    IbadahTask? task,
  }) async {
    final didSave = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => TaskEditorScreen(task: task)),
    );

    if (didSave == true) {
      refreshPlannerData(ref, date);
    }
  }
}

class _PlannerBody extends ConsumerWidget {
  const _PlannerBody({required this.model, required this.date});

  final IbadahPlannerDayReadModel model;
  final DateTime date;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Today',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 8),
                Text(
                  '${model.completedItems}/${model.totalItems} items complete',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 12),
                LinearProgressIndicator(
                  value: model.totalItems == 0
                      ? 0
                      : model.completedItems / model.totalItems,
                  minHeight: 10,
                  borderRadius: BorderRadius.circular(999),
                ),
                const SizedBox(height: 12),
                Text(
                  'Tasks stay compact here. Edit the library only when you need to add, pause, or clean up recurring items.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        if (model.sections.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'No active tasks for today',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add a daily task or reactivate something from the task library below.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          )
        else
          for (final section in model.sections) ...[
            _PlannerSectionCard(section: section, date: date),
            const SizedBox(height: 12),
          ],
        Card(
          child: Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              title: const Text('Task library'),
              subtitle: Text('${model.allTasks.length} saved tasks'),
              childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              children: [
                if (model.allTasks.isEmpty)
                  const ListTile(
                    title: Text('No saved tasks yet'),
                    subtitle: Text(
                      'Use Add task to create your first checklist item.',
                    ),
                  )
                else
                  for (final task in model.allTasks)
                    _TaskLibraryTile(task: task, date: date),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _PlannerSectionCard extends ConsumerWidget {
  const _PlannerSectionCard({required this.section, required this.date});

  final IbadahPlannerSection section;
  final DateTime date;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
              child: Text(
                section.title,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
            for (var index = 0; index < section.items.length; index++) ...[
              _PlannerItemTile(item: section.items[index], date: date),
              if (index < section.items.length - 1) const Divider(height: 1),
            ],
          ],
        ),
      ),
    );
  }
}

class _PlannerItemTile extends ConsumerWidget {
  const _PlannerItemTile({required this.item, required this.date});

  final IbadahPlannerItem item;
  final DateTime date;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repository = ref.read(ibadahCompletionRepositoryProvider);
    final subtitle = <String>[
      if (item.task.description != null && item.task.description!.isNotEmpty)
        item.task.description!,
      _taskDetail(item.task, item.prayer),
      if (item.isCountBased) 'Progress ${item.progressLabel}',
    ].join(' • ');

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      leading: item.isCountBased
          ? Icon(
              item.completed
                  ? Icons.check_circle_rounded
                  : Icons.touch_app_rounded,
            )
          : Checkbox(
              value: item.completed,
              onChanged: (value) async {
                if (value == true) {
                  await repository.upsert(
                    taskId: item.task.id,
                    date: date,
                    prayerInstance: item.prayerInstance,
                    countDone: item.task.countTarget ?? item.countDone,
                    completed: true,
                    notes: item.notes,
                  );
                } else {
                  await repository.clear(
                    taskId: item.task.id,
                    date: date,
                    prayerInstance: item.prayerInstance,
                  );
                }
                refreshPlannerData(ref, date);
              },
            ),
      title: Text(
        item.task.title,
        style: Theme.of(
          context,
        ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
      ),
      subtitle: subtitle.isEmpty ? null : Text(subtitle),
      trailing: item.isCountBased
          ? FilledButton.tonal(
              onPressed: () async {
                await Navigator.of(context).push<void>(
                  MaterialPageRoute(
                    builder: (_) => TasbihCounterScreen(item: item, date: date),
                  ),
                );
                refreshPlannerData(ref, date);
              },
              child: Text(item.progressLabel),
            )
          : null,
      onTap: item.isCountBased
          ? () async {
              await Navigator.of(context).push<void>(
                MaterialPageRoute(
                  builder: (_) => TasbihCounterScreen(item: item, date: date),
                ),
              );
              refreshPlannerData(ref, date);
            }
          : null,
    );
  }

  String _taskDetail(IbadahTask task, SalahPrayer? prayer) {
    final timing = task.repeatType == IbadahTaskRepeatType.afterEveryPrayer
        ? 'After each prayer'
        : prayer == null
        ? task.prayerLink == IbadahTaskPrayerLink.anyPrayer
              ? '${task.timing.label} any prayer'
              : task.repeatType.label
        : '${task.timing.label} ${prayer.label}';
    return '${task.repeatType.label} • $timing';
  }
}

class _TaskLibraryTile extends ConsumerWidget {
  const _TaskLibraryTile({required this.task, required this.date});

  final IbadahTask task;
  final DateTime date;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repository = ref.read(ibadahTaskRepositoryProvider);

    return ListTile(
      title: Text(task.title),
      subtitle: Text(
        [
          task.repeatType.label,
          task.isActive ? 'Active' : 'Paused',
          if (task.countTarget != null) 'Target ${task.countTarget}',
        ].join(' • '),
      ),
      leading: Icon(
        task.isActive ? Icons.task_alt_rounded : Icons.pause_circle_rounded,
      ),
      trailing: PopupMenuButton<_TaskLibraryAction>(
        onSelected: (action) async {
          switch (action) {
            case _TaskLibraryAction.edit:
              final didSave = await Navigator.of(context).push<bool>(
                MaterialPageRoute(builder: (_) => TaskEditorScreen(task: task)),
              );
              if (didSave == true) {
                refreshPlannerData(ref, date);
              }
            case _TaskLibraryAction.toggleActive:
              await repository.save(
                IbadahTaskDraft(
                  id: task.id,
                  title: task.title,
                  description: task.description,
                  prayerLink: task.prayerLink,
                  timing: task.timing,
                  repeatType: task.repeatType,
                  repeatDays: task.repeatDays,
                  countTarget: task.countTarget,
                  isActive: !task.isActive,
                  sortOrder: task.sortOrder,
                ),
              );
              refreshPlannerData(ref, date);
            case _TaskLibraryAction.delete:
              await repository.delete(task.id);
              refreshPlannerData(ref, date);
          }
        },
        itemBuilder: (context) => [
          const PopupMenuItem(
            value: _TaskLibraryAction.edit,
            child: Text('Edit'),
          ),
          PopupMenuItem(
            value: _TaskLibraryAction.toggleActive,
            child: Text(task.isActive ? 'Pause' : 'Activate'),
          ),
          const PopupMenuItem(
            value: _TaskLibraryAction.delete,
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }
}

enum _TaskLibraryAction { edit, toggleActive, delete }

class _PlannerError extends StatelessWidget {
  const _PlannerError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Unable to load planner',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}
