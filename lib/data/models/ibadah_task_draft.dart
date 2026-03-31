import '../../core/ibadah/ibadah_task_prayer_link.dart';
import '../../core/ibadah/ibadah_task_repeat_type.dart';
import '../../core/ibadah/ibadah_task_timing.dart';

class IbadahTaskDraft {
  const IbadahTaskDraft({
    this.id,
    required this.title,
    this.description,
    required this.prayerLink,
    required this.timing,
    required this.repeatType,
    this.repeatDays = const <int>{},
    this.countTarget,
    this.isActive = true,
    this.sortOrder = 0,
  });

  final int? id;
  final String title;
  final String? description;
  final IbadahTaskPrayerLink prayerLink;
  final IbadahTaskTiming timing;
  final IbadahTaskRepeatType repeatType;
  final Set<int> repeatDays;
  final int? countTarget;
  final bool isActive;
  final int sortOrder;
}
