import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../data/models/ibadah_planner_read_model.dart';

class TasbihCounterScreen extends ConsumerStatefulWidget {
  const TasbihCounterScreen({
    super.key,
    required this.item,
    required this.date,
  });

  final IbadahPlannerItem item;
  final DateTime date;

  @override
  ConsumerState<TasbihCounterScreen> createState() =>
      _TasbihCounterScreenState();
}

class _TasbihCounterScreenState extends ConsumerState<TasbihCounterScreen> {
  late int _count;
  var _persisted = false;

  int get _target => widget.item.countTarget ?? 100;

  @override
  void initState() {
    super.initState();
    _count = widget.item.countDone;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) {
          unawaited(_persistProgress());
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.item.task.title),
          actions: [
            TextButton(
              onPressed: () async {
                final navigator = Navigator.of(context);
                await _persistProgress();
                if (context.mounted) {
                  navigator.pop();
                }
              },
              child: const Text('Done'),
            ),
          ],
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            child: Column(
              children: [
                Text(
                  'Tap anywhere to count.',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  'Target $_target',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(28),
                    onTap: _increment,
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(28),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _count.toString(),
                            style: Theme.of(context).textTheme.displayLarge
                                ?.copyWith(fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            _count >= _target
                                ? 'Target reached'
                                : 'Keep tapping',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          setState(() {
                            _count = 0;
                            _persisted = false;
                          });
                        },
                        child: const Text('Reset'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        onPressed: () async {
                          final navigator = Navigator.of(context);
                          await _persistProgress();
                          if (context.mounted) {
                            navigator.pop();
                          }
                        },
                        child: const Text('Save'),
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

  void _increment() {
    if (_count >= _target) {
      return;
    }

    setState(() {
      _count++;
      _persisted = false;
    });
    HapticFeedback.selectionClick();
    if (_count >= _target) {
      HapticFeedback.mediumImpact();
      SystemSound.play(SystemSoundType.alert);
    }
  }

  Future<void> _persistProgress() async {
    if (_persisted) {
      return;
    }

    await ref
        .read(ibadahCompletionRepositoryProvider)
        .upsert(
          taskId: widget.item.task.id,
          date: widget.date,
          prayerInstance: widget.item.prayerInstance,
          countDone: _count,
          completed: _count >= _target,
          notes: widget.item.notes,
        );
    _persisted = true;
  }
}
