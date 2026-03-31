import '../../core/ibadah/ibadah_task_prayer_link.dart';
import '../../core/ibadah/ibadah_task_repeat_type.dart';
import '../../core/time/salah_prayer.dart';
import '../models/ibadah_completion_record.dart';
import '../models/ibadah_planner_read_model.dart';
import '../models/ibadah_task.dart';

class IbadahPlannerService {
  const IbadahPlannerService();

  IbadahPlannerDayReadModel buildDay({
    required DateTime date,
    required List<IbadahTask> tasks,
    required List<IbadahCompletionRecord> completions,
    required Set<int> completedOneTimeTaskIds,
  }) {
    final completionByKey = <String, IbadahCompletionRecord>{
      for (final completion in completions)
        _completionKey(completion.taskId, completion.prayerInstance):
            completion,
    };

    final sections = <_SectionBucket>[
      _SectionBucket(title: 'Any time'),
      _SectionBucket(title: 'Any prayer'),
      for (final prayer in _displayPrayersFor(date))
        _SectionBucket(title: prayer.label, prayer: prayer),
    ];

    for (final task in tasks) {
      if (!task.isActive) {
        continue;
      }
      if (!_occursOn(task, date, oneTimeDone: completedOneTimeTaskIds)) {
        continue;
      }

      if (task.repeatType == IbadahTaskRepeatType.afterEveryPrayer) {
        for (final prayer in _displayPrayersFor(date)) {
          final prayerInstance = prayer.name;
          final completion =
              completionByKey[_completionKey(task.id, prayerInstance)];
          _bucketForPrayer(sections, prayer).items.add(
            IbadahPlannerItem(
              task: task,
              prayer: prayer,
              prayerInstance: prayerInstance,
              countDone: completion?.countDone ?? 0,
              completed: _isCompleted(task, completion),
              notes: completion?.notes,
            ),
          );
        }
        continue;
      }

      final prayer = task.prayerLink.toPrayerForDate(date);
      final prayerInstance =
          task.repeatType == IbadahTaskRepeatType.afterEveryPrayer
          ? prayer?.name
          : null;
      final completion =
          completionByKey[_completionKey(task.id, prayerInstance)];
      _bucketForTask(sections, task, date).items.add(
        IbadahPlannerItem(
          task: task,
          prayer: prayer,
          prayerInstance: prayerInstance,
          countDone: completion?.countDone ?? 0,
          completed: _isCompleted(task, completion),
          notes: completion?.notes,
        ),
      );
    }

    final visibleSections = sections
        .where((section) => section.items.isNotEmpty)
        .map(
          (section) => IbadahPlannerSection(
            title: section.title,
            prayer: section.prayer,
            items: section.items
              ..sort((left, right) {
                final order = left.task.sortOrder.compareTo(
                  right.task.sortOrder,
                );
                if (order != 0) {
                  return order;
                }
                return left.task.title.compareTo(right.task.title);
              }),
          ),
        )
        .toList(growable: false);

    final allItems = visibleSections.expand((section) => section.items);
    final totalItems = allItems.length;
    final completedItems = allItems.where((item) => item.completed).length;

    return IbadahPlannerDayReadModel(
      date: date,
      totalItems: totalItems,
      completedItems: completedItems,
      sections: visibleSections,
      allTasks: List<IbadahTask>.unmodifiable(tasks),
    );
  }

  bool _occursOn(
    IbadahTask task,
    DateTime date, {
    required Set<int> oneTimeDone,
  }) {
    return switch (task.repeatType) {
      IbadahTaskRepeatType.daily => true,
      IbadahTaskRepeatType.weekly => task.repeatDays.contains(date.weekday),
      IbadahTaskRepeatType.specificDays => task.repeatDays.contains(
        date.weekday,
      ),
      IbadahTaskRepeatType.afterEveryPrayer => true,
      IbadahTaskRepeatType.oneTime => !oneTimeDone.contains(task.id),
    };
  }

  bool _isCompleted(IbadahTask task, IbadahCompletionRecord? completion) {
    if (completion == null) {
      return false;
    }
    final target = task.countTarget;
    if (target != null && target > 0) {
      return completion.completed || completion.countDone >= target;
    }
    return completion.completed;
  }

  _SectionBucket _bucketForTask(
    List<_SectionBucket> sections,
    IbadahTask task,
    DateTime date,
  ) {
    return switch (task.prayerLink) {
      IbadahTaskPrayerLink.none => sections.first,
      IbadahTaskPrayerLink.anyPrayer => sections[1],
      _ => _bucketForPrayer(sections, task.prayerLink.toPrayerForDate(date)),
    };
  }

  _SectionBucket _bucketForPrayer(
    List<_SectionBucket> sections,
    SalahPrayer? prayer,
  ) {
    if (prayer == null) {
      return sections.first;
    }
    return sections.firstWhere((section) => section.prayer == prayer);
  }

  List<SalahPrayer> _displayPrayersFor(DateTime date) {
    return date.weekday == DateTime.friday
        ? const [
            SalahPrayer.fajr,
            SalahPrayer.jummah,
            SalahPrayer.asr,
            SalahPrayer.maghrib,
            SalahPrayer.isha,
          ]
        : const [
            SalahPrayer.fajr,
            SalahPrayer.dhuhr,
            SalahPrayer.asr,
            SalahPrayer.maghrib,
            SalahPrayer.isha,
          ];
  }

  String _completionKey(int taskId, String? prayerInstance) {
    return '$taskId::${prayerInstance ?? ''}';
  }
}

class _SectionBucket {
  _SectionBucket({required this.title, this.prayer});

  final String title;
  final SalahPrayer? prayer;
  final List<IbadahPlannerItem> items = <IbadahPlannerItem>[];
}
