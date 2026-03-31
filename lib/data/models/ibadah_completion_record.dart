class IbadahCompletionRecord {
  const IbadahCompletionRecord({
    required this.id,
    required this.taskId,
    required this.date,
    required this.prayerInstance,
    required this.countDone,
    required this.completed,
    required this.notes,
  });

  final int id;
  final int taskId;
  final DateTime date;
  final String? prayerInstance;
  final int countDone;
  final bool completed;
  final String? notes;
}
