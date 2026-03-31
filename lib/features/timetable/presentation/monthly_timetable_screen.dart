import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../core/time/salah_prayer.dart';
import '../../../data/models/monthly_timetable_read_model.dart';

class MonthlyTimetableScreen extends ConsumerStatefulWidget {
  const MonthlyTimetableScreen({super.key});

  @override
  ConsumerState<MonthlyTimetableScreen> createState() =>
      _MonthlyTimetableScreenState();
}

class _MonthlyTimetableScreenState
    extends ConsumerState<MonthlyTimetableScreen> {
  late DateTime _month;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _month = DateTime(now.year, now.month);
  }

  @override
  Widget build(BuildContext context) {
    final modelAsync = ref.watch(monthlyTimetableProvider(_month));

    return Scaffold(
      appBar: AppBar(title: const Text('Monthly timetable')),
      body: modelAsync.when(
        data: (model) => ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            _TimetableHeader(
              month: _month,
              mosqueName: model.primaryMosque?.name ?? 'Calculation profile',
              onPrevious: () {
                setState(() {
                  _month = DateTime(_month.year, _month.month - 1);
                });
              },
              onNext: () {
                setState(() {
                  _month = DateTime(_month.year, _month.month + 1);
                });
              },
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    headingRowHeight: 52,
                    columns: const [
                      DataColumn(label: Text('Day')),
                      DataColumn(label: Text('Imsak')),
                      DataColumn(label: Text('Fajr')),
                      DataColumn(label: Text('Sunrise')),
                      DataColumn(label: Text('Dhuhr')),
                      DataColumn(label: Text('Jummah')),
                      DataColumn(label: Text('Asr')),
                      DataColumn(label: Text('Maghrib')),
                      DataColumn(label: Text('Isha')),
                    ],
                    rows: [
                      for (final day in model.days)
                        DataRow(
                          cells: [
                            DataCell(_dayCell(context, day)),
                            DataCell(
                              _timeCell(context, day, SalahPrayer.imsak),
                            ),
                            DataCell(_timeCell(context, day, SalahPrayer.fajr)),
                            DataCell(
                              _timeCell(context, day, SalahPrayer.sunrise),
                            ),
                            DataCell(
                              _timeCell(context, day, SalahPrayer.dhuhr),
                            ),
                            DataCell(_jummahCell(context, day)),
                            DataCell(_timeCell(context, day, SalahPrayer.asr)),
                            DataCell(
                              _timeCell(context, day, SalahPrayer.maghrib),
                            ),
                            DataCell(_timeCell(context, day, SalahPrayer.isha)),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Text(error.toString()),
          ),
        ),
      ),
    );
  }

  Widget _dayCell(BuildContext context, MonthlyTimetableDay day) {
    final snapshot = day.snapshot;
    final isFriday = snapshot.date.weekday == DateTime.friday;
    final scheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '${snapshot.date.day}',
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 4),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            if (isFriday) _Tag(label: 'Fri', color: scheme.primary),
            if (snapshot.isRamadanActive)
              _Tag(label: 'Ramadan', color: scheme.tertiary),
          ],
        ),
      ],
    );
  }

  Widget _timeCell(
    BuildContext context,
    MonthlyTimetableDay day,
    SalahPrayer prayer,
  ) {
    final emphasized =
        day.snapshot.isRamadanActive &&
        (prayer == SalahPrayer.imsak || prayer == SalahPrayer.maghrib);

    return Text(
      _formatTime(context, day.snapshot.timeOf(prayer)),
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
        fontWeight: emphasized ? FontWeight.w700 : FontWeight.w500,
        color: emphasized ? Theme.of(context).colorScheme.primary : null,
      ),
    );
  }

  Widget _jummahCell(BuildContext context, MonthlyTimetableDay day) {
    if (day.snapshot.date.weekday != DateTime.friday) {
      return const Text('—');
    }

    final value =
        day.jummahTiming?.dateTime ?? day.snapshot.timeOf(SalahPrayer.dhuhr);
    return Text(
      _formatTime(context, value),
      style: Theme.of(
        context,
      ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
    );
  }
}

class _TimetableHeader extends StatelessWidget {
  const _TimetableHeader({
    required this.month,
    required this.mosqueName,
    required this.onPrevious,
    required this.onNext,
  });

  final DateTime month;
  final String mosqueName;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

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
              child: Column(
                children: [
                  Text(
                    '${_monthLabel(month.month)} ${month.year}',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    mosqueName,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
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

class _Tag extends StatelessWidget {
  const _Tag({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
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
