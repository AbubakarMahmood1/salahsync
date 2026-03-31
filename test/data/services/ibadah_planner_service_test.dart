import 'package:flutter_test/flutter_test.dart';

import 'package:salahsync/core/ibadah/ibadah_task_prayer_link.dart';
import 'package:salahsync/core/ibadah/ibadah_task_repeat_type.dart';
import 'package:salahsync/core/ibadah/ibadah_task_timing.dart';
import 'package:salahsync/core/time/salah_prayer.dart';
import 'package:salahsync/data/models/ibadah_completion_record.dart';
import 'package:salahsync/data/models/ibadah_task.dart';
import 'package:salahsync/data/services/ibadah_planner_service.dart';

void main() {
  const service = IbadahPlannerService();

  test('afterEveryPrayer expands to Friday jummah-aware sections', () {
    const task = IbadahTask(
      id: 1,
      title: '33x tasbih',
      description: null,
      prayerLink: IbadahTaskPrayerLink.anyPrayer,
      timing: IbadahTaskTiming.after,
      repeatType: IbadahTaskRepeatType.afterEveryPrayer,
      repeatDays: {},
      countTarget: 33,
      isActive: true,
      sortOrder: 0,
    );

    final model = service.buildDay(
      date: DateTime(2026, 4, 3),
      tasks: const [task],
      completions: const [],
      completedOneTimeTaskIds: const {},
    );

    expect(model.totalItems, 5);
    expect(
      model.sections.map((section) => section.title),
      containsAll(['Fajr', 'Jummah', 'Asr', 'Maghrib', 'Isha']),
    );
    final jummahSection = model.sections.firstWhere(
      (section) => section.prayer == SalahPrayer.jummah,
    );
    expect(jummahSection.items.single.prayerInstance, SalahPrayer.jummah.name);
  });

  test('one-time count task stays visible until target is reached', () {
    const task = IbadahTask(
      id: 8,
      title: 'One-off zikr',
      description: null,
      prayerLink: IbadahTaskPrayerLink.none,
      timing: IbadahTaskTiming.after,
      repeatType: IbadahTaskRepeatType.oneTime,
      repeatDays: {},
      countTarget: 100,
      isActive: true,
      sortOrder: 0,
    );

    final incomplete = service.buildDay(
      date: DateTime(2026, 4, 1),
      tasks: const [task],
      completions: [
        IbadahCompletionRecord(
          id: 1,
          taskId: 8,
          date: DateTime(2026, 4, 1),
          prayerInstance: null,
          countDone: 40,
          completed: false,
          notes: null,
        ),
      ],
      completedOneTimeTaskIds: const {},
    );
    expect(incomplete.totalItems, 1);

    final completed = service.buildDay(
      date: DateTime(2026, 4, 2),
      tasks: const [task],
      completions: const [],
      completedOneTimeTaskIds: const {8},
    );
    expect(completed.totalItems, 0);
  });
}
