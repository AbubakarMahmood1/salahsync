import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class QuickTasbihScreen extends StatefulWidget {
  const QuickTasbihScreen({super.key});

  @override
  State<QuickTasbihScreen> createState() => _QuickTasbihScreenState();
}

class _QuickTasbihScreenState extends State<QuickTasbihScreen> {
  int _count = 0;
  int _target = 100;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tasbih')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final target in const [33, 99, 100])
                    ChoiceChip(
                      label: Text('Target $target'),
                      selected: _target == target,
                      onSelected: (_) {
                        setState(() {
                          _target = target;
                          if (_count > _target) {
                            _count = _target;
                          }
                        });
                      },
                    ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: InkWell(
                  borderRadius: BorderRadius.circular(28),
                  onTap: _increment,
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerHigh,
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
                              : 'Tap anywhere to count',
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
                        });
                      },
                      child: const Text('Reset'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('Done'),
                    ),
                  ),
                ],
              ),
            ],
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
    });
    HapticFeedback.selectionClick();
    if (_count >= _target) {
      HapticFeedback.mediumImpact();
      SystemSound.play(SystemSoundType.alert);
    }
  }
}
