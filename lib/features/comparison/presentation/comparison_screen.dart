import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/app_scaffold.dart';
import '../../../app/providers.dart';
import '../../../core/mosque/resolved_timing.dart';
import '../../../core/time/salah_prayer.dart';

class ComparisonScreen extends ConsumerWidget {
  const ComparisonScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final schedulesAsync = ref.watch(comparisonSchedulesProvider);

    return schedulesAsync.when(
      data: (schedules) {
        if (schedules.isEmpty) {
          return _EmptyComparison(
            onRefresh: () => ref.invalidate(comparisonSchedulesProvider),
            onManageMosques: () {
              AppScaffoldTabController.maybeOf(context)?.setCurrentIndex(1);
            },
          );
        }

        final prayers = schedules.first.displayPrayers;

        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          children: [
            _HeaderCard(scheduleCount: schedules.length),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    headingRowHeight: 62,
                    dataRowMinHeight: 76,
                    dataRowMaxHeight: 96,
                    columns: [
                      const DataColumn(label: Text('Prayer')),
                      for (final schedule in schedules)
                        DataColumn(
                          label: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (schedule.mosque.isPrimary)
                                    const Icon(Icons.star_rounded, size: 16),
                                  if (schedule.mosque.isPrimary)
                                    const SizedBox(width: 4),
                                  Text(schedule.mosque.name),
                                ],
                              ),
                              if (schedule.mosque.area != null &&
                                  schedule.mosque.area!.isNotEmpty)
                                Text(
                                  schedule.mosque.area!,
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                            ],
                          ),
                        ),
                    ],
                    rows: [
                      for (final prayer in prayers)
                        DataRow(
                          cells: [
                            DataCell(
                              Text(
                                prayer.label,
                                style: Theme.of(context).textTheme.titleSmall
                                    ?.copyWith(fontWeight: FontWeight.w700),
                              ),
                            ),
                            for (final schedule in schedules)
                              DataCell(
                                _ComparisonCell(
                                  timing: schedule.resolvedJamaatTimes[prayer]!,
                                ),
                              ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => _EmptyComparison(
        onRefresh: () => ref.invalidate(comparisonSchedulesProvider),
        onManageMosques: () {
          AppScaffoldTabController.maybeOf(context)?.setCurrentIndex(1);
        },
        message: error.toString(),
      ),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({required this.scheduleCount});

  final int scheduleCount;

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
              'Jamaat comparison',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 10),
            Text(
              'Today\'s resolved Jamaat schedule for every active mosque. Primary is marked with a star, and each cell shows whether the time came from an offset, fixed, seasonal, or fallback source.',
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: scheme.onSurfaceVariant),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _SummaryChip(label: 'Active mosques', value: '$scheduleCount'),
                const _SummaryChip(label: 'Scope', value: 'Jamaat only'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ComparisonCell extends StatelessWidget {
  const _ComparisonCell({required this.timing});

  final ResolvedTiming timing;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final tone = switch (timing.source) {
      ResolvedTimingSource.offsetRule => scheme.primary,
      ResolvedTimingSource.fixedRule => scheme.secondary,
      ResolvedTimingSource.dateRangeRule => scheme.tertiary,
      ResolvedTimingSource.computedFallback => scheme.outline,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          _formatTime(context, timing.dateTime),
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: tone.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Text(
            _sourceLabel(timing.source),
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: tone,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _SummaryChip extends StatelessWidget {
  const _SummaryChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
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

class _EmptyComparison extends StatelessWidget {
  const _EmptyComparison({
    required this.onRefresh,
    required this.onManageMosques,
    this.message,
  });

  final VoidCallback onRefresh;
  final VoidCallback onManageMosques;
  final String? message;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'No active mosques to compare',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 10),
                Text(
                  message ??
                      'Activate at least one mosque to build the side-by-side Jamaat table.',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    FilledButton(
                      onPressed: onManageMosques,
                      child: const Text('Manage Mosques'),
                    ),
                    OutlinedButton(
                      onPressed: onRefresh,
                      child: const Text('Refresh'),
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
}

String _sourceLabel(ResolvedTimingSource source) {
  return switch (source) {
    ResolvedTimingSource.offsetRule => 'Offset',
    ResolvedTimingSource.fixedRule => 'Fixed',
    ResolvedTimingSource.dateRangeRule => 'Seasonal',
    ResolvedTimingSource.computedFallback => 'Fallback',
  };
}

String _formatTime(BuildContext context, DateTime value) {
  return MaterialLocalizations.of(
    context,
  ).formatTimeOfDay(TimeOfDay.fromDateTime(value), alwaysUse24HourFormat: true);
}
