import '../../core/ibadah/ibadah_task_prayer_link.dart';
import '../../core/ibadah/ibadah_task_repeat_type.dart';
import '../../core/ibadah/ibadah_task_timing.dart';

class IbadahTask {
  const IbadahTask({
    required this.id,
    required this.title,
    required this.description,
    required this.prayerLink,
    required this.timing,
    required this.repeatType,
    required this.repeatDays,
    required this.countTarget,
    required this.isActive,
    required this.sortOrder,
  });

  final int id;
  final String title;
  final String? description;
  final IbadahTaskPrayerLink prayerLink;
  final IbadahTaskTiming timing;
  final IbadahTaskRepeatType repeatType;
  final Set<int> repeatDays;
  final int? countTarget;
  final bool isActive;
  final int sortOrder;

  bool get isCountBased => (countTarget ?? 0) > 0;
}
