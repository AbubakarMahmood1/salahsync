import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/app_scaffold.dart';
import '../../../app/providers.dart';
import '../../../core/mosque/resolved_timing.dart';
import '../../../core/time/prayer_calculation_config.dart';
import '../../../core/time/salah_prayer.dart';
import '../../../data/models/home_schedule_read_model.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeSchedule = ref.watch(homeScheduleProvider);

    return homeSchedule.when(
      data: (model) {
        if (model == null) {
          return _EmptyState(
            onRetry: () => ref.invalidate(homeScheduleProvider),
            onOpenMosques: () {
              AppScaffoldTabController.maybeOf(context)?.setCurrentIndex(1);
            },
            onOpenSettings: () {
              AppScaffoldTabController.maybeOf(context)?.setCurrentIndex(3);
            },
          );
        }

        final snapshot = model.computedSnapshot;
        final now = DateTime.now();
        final currentPrayer = _displayPrayerForDate(
          snapshot.currentWindowPrayerAt(now),
          snapshot.date,
        );
        final nextPrayer =
            _displayPrayerForDate(snapshot.nextPrayerAt(now), snapshot.date) ??
            SalahPrayer.fajr;
        var nextPrayerTime = snapshot.timeOf(
          nextPrayer == SalahPrayer.jummah ? SalahPrayer.dhuhr : nextPrayer,
        );
        if (nextPrayer == SalahPrayer.fajr &&
            now.isAfter(snapshot.timeOf(SalahPrayer.isha))) {
          nextPrayerTime = nextPrayerTime.add(const Duration(days: 1));
        }

        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          children: [
            _SummaryCard(
              model: model,
              currentPrayer: currentPrayer,
              nextPrayer: nextPrayer,
              nextPrayerTime: nextPrayerTime,
            ),
            const SizedBox(height: 16),
            _ConfigCard(model: model),
            const SizedBox(height: 16),
            _ScheduleCard(model: model, nextPrayer: nextPrayer),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => _LoadError(
        error: error,
        onRetry: () {
          ref.invalidate(appBootstrapProvider);
          ref.invalidate(homeScheduleProvider);
        },
      ),
    );
  }

  SalahPrayer? _displayPrayerForDate(SalahPrayer? prayer, DateTime date) {
    if (prayer == null) {
      return null;
    }
    if (date.weekday == DateTime.friday && prayer == SalahPrayer.dhuhr) {
      return SalahPrayer.jummah;
    }
    return prayer;
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.model,
    required this.currentPrayer,
    required this.nextPrayer,
    required this.nextPrayerTime,
  });

  final HomeScheduleReadModel model;
  final SalahPrayer? currentPrayer;
  final SalahPrayer nextPrayer;
  final DateTime nextPrayerTime;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final headline = Theme.of(context).textTheme.headlineSmall;
    final snapshot = model.computedSnapshot;
    final area = model.primaryMosque.area;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              model.primaryMosque.name,
              style: headline?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
            if (area != null && area.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                area,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ],
            const SizedBox(height: 8),
            Text(
              '${_weekdayName(snapshot.date.weekday)}, ${_monthName(snapshot.date.month)} ${snapshot.date.day}, ${snapshot.date.year}',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 4),
            Text(
              snapshot.hijriDate.shortLabel,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _StatusPill(
                  label: 'Current',
                  value: currentPrayer?.label ?? 'Between windows',
                  tone: currentPrayer == null
                      ? scheme.secondary
                      : scheme.primary,
                ),
                _StatusPill(
                  label: 'Next',
                  value: nextPrayer.label,
                  tone: scheme.tertiary,
                ),
                _CountdownPill(
                  label: 'Countdown',
                  target: nextPrayerTime,
                  tone: scheme.primary,
                ),
                _StatusPill(
                  label: 'Primary',
                  value: model.primaryMosque.isPrimary ? 'Yes' : 'No',
                  tone: scheme.secondary,
                ),
                _StatusPill(
                  label: 'Qibla',
                  value: '${snapshot.qiblaBearing.toStringAsFixed(1)}°',
                  tone: scheme.secondary,
                ),
                _StatusPill(
                  label: 'Ramadan',
                  value: snapshot.isRamadanActive ? 'On' : 'Off',
                  tone: snapshot.isRamadanActive
                      ? scheme.primary
                      : scheme.outline,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _weekdayName(int weekday) {
    const names = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    return names[weekday - 1];
  }

  String _monthName(int month) {
    const names = [
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
    return names[month - 1];
  }
}

class _ConfigCard extends StatelessWidget {
  const _ConfigCard({required this.model});

  final HomeScheduleReadModel model;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final config = model.calculationConfig;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Calculation settings',
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Today uses the persisted calculation profile and the primary mosque\'s resolved Jamaat rules. Update the method, offsets, or coordinates from the Settings tab.',
              style: textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            _InfoRow(label: 'Method', value: _methodLabel(config.method)),
            const SizedBox(height: 8),
            _InfoRow(label: 'Asr school', value: _asrSchoolLabel(config)),
            const SizedBox(height: 8),
            _InfoRow(
              label: 'Isha end',
              value: _ishaEndConventionLabel(config.ishaEndConvention),
            ),
            const SizedBox(height: 8),
            _InfoRow(
              label: 'Hijri',
              value:
                  '${model.computedSnapshot.hijriDate.weekdayName}, ${model.computedSnapshot.hijriDate.shortLabel}',
            ),
          ],
        ),
      ),
    );
  }

  String _methodLabel(PrayerCalculationMethodChoice method) {
    return switch (method) {
      PrayerCalculationMethodChoice.karachi => 'Karachi (Method 1)',
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

  String _asrSchoolLabel(PrayerCalculationConfig config) {
    return switch (config.asrSchool) {
      AsrJuristicSchool.hanafi => 'Hanafi',
      AsrJuristicSchool.shafi => 'Shafi',
    };
  }

  String _ishaEndConventionLabel(IshaEndConvention convention) {
    return switch (convention) {
      IshaEndConvention.midnight => 'Midnight',
      IshaEndConvention.fajr => 'Fajr',
    };
  }
}

class _ScheduleCard extends StatelessWidget {
  const _ScheduleCard({required this.model, required this.nextPrayer});

  final HomeScheduleReadModel model;
  final SalahPrayer nextPrayer;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Today\'s schedule',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 16),
            for (final prayer in model.displayPrayers) ...[
              _PrayerRow(
                prayer: prayer,
                model: model,
                emphasized: prayer == nextPrayer,
              ),
              if (prayer != model.displayPrayers.last)
                const Divider(height: 20),
            ],
          ],
        ),
      ),
    );
  }
}

class _PrayerRow extends StatelessWidget {
  const _PrayerRow({
    required this.prayer,
    required this.model,
    required this.emphasized,
  });

  final SalahPrayer prayer;
  final HomeScheduleReadModel model;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    final snapshot = model.computedSnapshot;
    final resolvedTiming = model.resolvedJamaatTimes[prayer];
    final computedPrayer = prayer == SalahPrayer.jummah
        ? SalahPrayer.dhuhr
        : prayer;
    final window = snapshot.windowFor(computedPrayer);
    final scheme = Theme.of(context).colorScheme;
    final titleStyle = Theme.of(context).textTheme.titleMedium?.copyWith(
      fontWeight: emphasized ? FontWeight.w700 : FontWeight.w600,
      color: emphasized ? scheme.primary : null,
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(prayer.label, style: titleStyle),
              if (window != null)
                Text(
                  'Window until ${_formatTime(context, window.end)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              if (resolvedTiming != null)
                Text(
                  _sourceLabel(resolvedTiming.source),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (resolvedTiming != null)
              Text(
                _formatTime(context, resolvedTiming.dateTime),
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              )
            else
              Text(
                _formatTime(context, snapshot.timeOf(computedPrayer)),
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
            if (resolvedTiming != null)
              Text(
                'Start ${_formatTime(context, snapshot.timeOf(computedPrayer))}',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
              ),
          ],
        ),
      ],
    );
  }

  String _sourceLabel(ResolvedTimingSource source) {
    return switch (source) {
      ResolvedTimingSource.computedFallback => 'Computed fallback',
      ResolvedTimingSource.offsetRule => 'Offset rule',
      ResolvedTimingSource.fixedRule => 'Fixed rule',
      ResolvedTimingSource.dateRangeRule => 'Seasonal date-range rule',
    };
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({
    required this.label,
    required this.value,
    required this.tone,
  });

  final String label;
  final String value;
  final Color tone;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: tone.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: tone,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _CountdownPill extends StatefulWidget {
  const _CountdownPill({
    required this.label,
    required this.target,
    required this.tone,
  });

  final String label;
  final DateTime target;
  final Color tone;

  @override
  State<_CountdownPill> createState() => _CountdownPillState();
}

class _CountdownPillState extends State<_CountdownPill> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final remaining = widget.target.difference(DateTime.now());

    return _StatusPill(
      label: widget.label,
      value: _formatCountdown(remaining),
      tone: widget.tone,
    );
  }

  String _formatCountdown(Duration duration) {
    if (duration.isNegative) {
      return '00:00:00';
    }

    final hours = duration.inHours.toString().padLeft(2, '0');
    final minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 92,
          child: Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
        Expanded(
          child: Text(value, style: Theme.of(context).textTheme.bodyMedium),
        ),
      ],
    );
  }
}

class _LoadError extends StatelessWidget {
  const _LoadError({required this.error, required this.onRetry});

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
              'Unable to load persisted mosque data.',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            FilledButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.onRetry,
    required this.onOpenMosques,
    required this.onOpenSettings,
  });

  final VoidCallback onRetry;
  final VoidCallback onOpenMosques;
  final VoidCallback onOpenSettings;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'No active primary mosque is available.',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Add or reactivate a mosque from the Mosques tab, then check calculation and notification defaults from Settings if needed.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              alignment: WrapAlignment.center,
              children: [
                FilledButton(
                  onPressed: onOpenMosques,
                  child: const Text('Open Mosques'),
                ),
                OutlinedButton(
                  onPressed: onOpenSettings,
                  child: const Text('Open Settings'),
                ),
                OutlinedButton(
                  onPressed: onRetry,
                  child: const Text('Refresh'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

String _formatTime(BuildContext context, DateTime value) {
  return MaterialLocalizations.of(
    context,
  ).formatTimeOfDay(TimeOfDay.fromDateTime(value), alwaysUse24HourFormat: true);
}
