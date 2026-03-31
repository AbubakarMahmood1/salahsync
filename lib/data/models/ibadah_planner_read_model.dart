import '../../core/time/salah_prayer.dart';
import 'ibadah_task.dart';

class IbadahPlannerDayReadModel {
  const IbadahPlannerDayReadModel({
    required this.date,
    required this.totalItems,
    required this.completedItems,
    required this.sections,
    required this.allTasks,
  });

  final DateTime date;
  final int totalItems;
  final int completedItems;
  final List<IbadahPlannerSection> sections;
  final List<IbadahTask> allTasks;
}

class IbadahPlannerSection {
  const IbadahPlannerSection({
    required this.title,
    required this.items,
    this.prayer,
  });

  final String title;
  final SalahPrayer? prayer;
  final List<IbadahPlannerItem> items;
}

class IbadahPlannerItem {
  const IbadahPlannerItem({
    required this.task,
    required this.prayer,
    required this.prayerInstance,
    required this.countDone,
    required this.completed,
    required this.notes,
  });

  final IbadahTask task;
  final SalahPrayer? prayer;
  final String? prayerInstance;
  final int countDone;
  final bool completed;
  final String? notes;

  bool get isCountBased => task.isCountBased;

  int? get countTarget => task.countTarget;

  String get progressLabel {
    final target = task.countTarget;
    if (target == null || target <= 0) {
      return completed ? 'Done' : 'Pending';
    }
    return '$countDone/$target';
  }
}
