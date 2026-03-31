import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../core/time/prayer_calculation_config.dart';
import '../../../core/time/salah_prayer.dart';
import '../../../core/utils/date_key.dart';
import '../../../data/models/aladhan_verification_result.dart';

class AlAdhanVerificationScreen extends ConsumerStatefulWidget {
  const AlAdhanVerificationScreen({super.key});

  @override
  ConsumerState<AlAdhanVerificationScreen> createState() =>
      _AlAdhanVerificationScreenState();
}

class _AlAdhanVerificationScreenState
    extends ConsumerState<AlAdhanVerificationScreen> {
  late DateTime _selectedDate;
  AlAdhanVerificationResult? _result;
  Object? _error;
  var _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedDate = startOfDay(DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    final configAsync = ref.watch(prayerCalculationConfigProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Verify AlAdhan')),
      body: configAsync.when(
        data: (config) => ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Manual check only',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'This compares the unadjusted local engine against AlAdhan for one date. Saved manual offsets are intentionally ignored here so the warning only captures calculation drift.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final preset in _presetDatesForYear(
                          _selectedDate.year,
                        ))
                          ChoiceChip(
                            label: Text(_chipLabel(preset)),
                            selected: _selectedDate == preset,
                            onSelected: (_) {
                              setState(() {
                                _selectedDate = preset;
                              });
                            },
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Selected date'),
                      subtitle: Text(
                        '${_monthLabel(_selectedDate.month)} ${_selectedDate.day}, ${_selectedDate.year}',
                      ),
                      trailing: const Icon(Icons.calendar_today_rounded),
                      onTap: _pickDate,
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: _isLoading
                          ? null
                          : () => _runVerification(config),
                      child: Text(
                        _isLoading ? 'Checking...' : 'Run comparison',
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    _error.toString(),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
              ),
            ],
            if (_result != null) ...[
              const SizedBox(height: 16),
              _VerificationResultCard(result: _result!),
            ],
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Text(error.toString(), textAlign: TextAlign.center),
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

  Future<void> _runVerification(PrayerCalculationConfig config) async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final result = await ref
          .read(alAdhanVerificationServiceProvider)
          .verify(date: _selectedDate, config: config);
      if (!mounted) {
        return;
      }
      setState(() {
        _result = result;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _result = null;
        _error = error;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  List<DateTime> _presetDatesForYear(int year) {
    return [
      DateTime(year, 3, 21),
      DateTime(year, 6, 21),
      DateTime(year, 9, 22),
      DateTime(year, 12, 21),
    ];
  }

  String _chipLabel(DateTime date) {
    return '${_monthLabel(date.month).substring(0, 3)} ${date.day}';
  }
}

class _VerificationResultCard extends StatelessWidget {
  const _VerificationResultCard({required this.result});

  final AlAdhanVerificationResult result;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              result.hasWarning ? 'Check differences' : 'Within tolerance',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(result.locationLabel),
            const SizedBox(height: 4),
            Text(
              result.apiUrl,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
            ),
            const SizedBox(height: 16),
            DataTable(
              columns: const [
                DataColumn(label: Text('Prayer')),
                DataColumn(label: Text('Engine')),
                DataColumn(label: Text('AlAdhan')),
                DataColumn(label: Text('Diff')),
              ],
              rows: [
                for (final prayer in _verificationPrayers)
                  DataRow(
                    cells: [
                      DataCell(Text(prayer.label)),
                      DataCell(
                        Text(
                          _formatTime(
                            context,
                            result.engineSnapshot.timeOf(prayer),
                          ),
                        ),
                      ),
                      DataCell(
                        Text(_formatTime(context, result.apiTimes[prayer]!)),
                      ),
                      DataCell(
                        Text(
                          _formatDifference(result.differences[prayer]!),
                          style: TextStyle(
                            color:
                                result.differences[prayer]!.inMinutes.abs() > 2
                                ? scheme.error
                                : scheme.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDifference(Duration difference) {
    final totalMinutes = difference.inMinutes;
    if (totalMinutes == 0) {
      return '0m';
    }
    return totalMinutes > 0 ? '+${totalMinutes}m' : '${totalMinutes}m';
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

const _verificationPrayers = <SalahPrayer>[
  SalahPrayer.fajr,
  SalahPrayer.sunrise,
  SalahPrayer.dhuhr,
  SalahPrayer.asr,
  SalahPrayer.maghrib,
  SalahPrayer.isha,
];
