import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/app_scaffold.dart';
import '../../../app/providers.dart';
import '../../../core/mosque/resolved_timing.dart';
import '../../../core/time/prayer_calculation_config.dart';
import '../../../core/time/salah_prayer.dart';
import '../../../data/models/home_schedule_read_model.dart';
import '../../planner/presentation/planner_screen.dart';
import '../../planner/presentation/quick_tasbih_screen.dart';
import '../../prayer_log/presentation/prayer_log_screen.dart';
import '../../qibla/presentation/qibla_screen.dart';
import '../../timetable/presentation/monthly_timetable_screen.dart';
import '../../verification/presentation/aladhan_verification_screen.dart';
import 'home_prayer_status.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final refreshTick = ref.watch(scheduleRefreshTickProvider);
    final now = refreshTick.when(
      data: (value) => value,
      error: (_, _) => DateTime.now(),
      loading: DateTime.now,
    );
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

        final status = computeHomePrayerStatus(model: model, now: now);

        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          children: [
            _SummaryCard(
              model: model,
              currentPrayer: status.currentPrayer,
              nextPrayer: status.nextPrayer,
              nextPrayerTime: status.nextPrayerTime,
            ),
            const SizedBox(height: 16),
            const _UtilitiesCard(),
            const SizedBox(height: 16),
            _ScheduleCard(model: model, nextPrayer: status.nextPrayer),
            const SizedBox(height: 16),
            _ConfigCard(model: model),
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
            const SizedBox(height: 20),
            const _LiveClockReadout(),
            const SizedBox(height: 12),
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

class _ConfigCard extends ConsumerWidget {
  const _ConfigCard({required this.model});

  final HomeScheduleReadModel model;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final config = model.calculationConfig;

    return Card(
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
          childrenPadding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
          title: Text(
            'Profile details',
            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          subtitle: Text(
            'Method, offsets, Hijri profile, and mosque metadata',
            style: textTheme.bodySmall?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Today uses the persisted calculation profile and the primary mosque\'s resolved Jamaat rules.',
                style: textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
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
            const SizedBox(height: 8),
            _InfoRow(label: 'Primary', value: model.primaryMosque.name),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerLeft,
              child: FilledButton.tonalIcon(
                onPressed: () {
                  ref.read(homeWidgetSyncServiceProvider).requestPinWidget();
                },
                icon: const Icon(Icons.widgets_rounded),
                label: const Text('Pin widget'),
              ),
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

class _LiveClockReadout extends StatefulWidget {
  const _LiveClockReadout();

  @override
  State<_LiveClockReadout> createState() => _LiveClockReadoutState();
}

class _LiveClockReadoutState extends State<_LiveClockReadout> {
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
    final now = DateTime.now();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _formatClock(now),
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: -1.2,
          ),
        ),
        const SizedBox(height: 2),
        Text('Current time', style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }

  String _formatClock(DateTime value) {
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');
    final second = value.second.toString().padLeft(2, '0');
    return '$hour:$minute:$second';
  }
}

class _UtilitiesCard extends StatelessWidget {
  const _UtilitiesCard();

  @override
  Widget build(BuildContext context) {
    final items = [
      (
        label: 'Planner',
        subtitle: 'Today\'s checklist and recurring tasks',
        icon: Icons.checklist_rounded,
        builder: const PlannerScreen(),
      ),
      (
        label: 'Prayer Log',
        subtitle: 'Record Jamaat, alone, or missed prayers',
        icon: Icons.fact_check_rounded,
        builder: const PrayerLogScreen(),
      ),
      (
        label: 'Tasbih',
        subtitle: 'Standalone quick counter',
        icon: Icons.touch_app_rounded,
        builder: const QuickTasbihScreen(),
      ),
      (
        label: 'Qibla',
        subtitle: 'Compass plus numeric bearing',
        icon: Icons.explore_rounded,
        builder: const QiblaScreen(),
      ),
      (
        label: 'Timetable',
        subtitle: 'Monthly prayer times with Friday/Ramadan context',
        icon: Icons.calendar_month_rounded,
        builder: const MonthlyTimetableScreen(),
      ),
      (
        label: 'Verify',
        subtitle: 'Manual AlAdhan comparison',
        icon: Icons.verified_rounded,
        builder: const AlAdhanVerificationScreen(),
      ),
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            for (var index = 0; index < items.length; index++) ...[
              ListTile(
                leading: Icon(items[index].icon),
                title: Text(items[index].label),
                subtitle: Text(items[index].subtitle),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => items[index].builder),
                  );
                },
              ),
              if (index < items.length - 1) const Divider(height: 1),
            ],
          ],
        ),
      ),
    );
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
