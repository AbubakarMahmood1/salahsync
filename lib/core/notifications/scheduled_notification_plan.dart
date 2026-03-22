import '../time/salah_prayer.dart';
import 'notification_kind.dart';

class ScheduledNotificationPlan {
  const ScheduledNotificationPlan({
    required this.id,
    required this.mosqueId,
    required this.prayer,
    required this.kind,
    required this.scheduledAt,
    required this.title,
    required this.body,
    required this.payload,
  });

  factory ScheduledNotificationPlan.create({
    required int mosqueId,
    required SalahPrayer prayer,
    required NotificationKind kind,
    required DateTime scheduledAt,
    required String title,
    required String body,
  }) {
    final dateKey = _dateKey(scheduledAt);
    final payload =
        'salahsync:v1|$mosqueId|$dateKey|${prayer.name}|${kind.name}';

    return ScheduledNotificationPlan(
      id: _stableId(payload),
      mosqueId: mosqueId,
      prayer: prayer,
      kind: kind,
      scheduledAt: scheduledAt,
      title: title,
      body: body,
      payload: payload,
    );
  }

  final int id;
  final int mosqueId;
  final SalahPrayer prayer;
  final NotificationKind kind;
  final DateTime scheduledAt;
  final String title;
  final String body;
  final String payload;
}

String _dateKey(DateTime value) {
  final year = value.year.toString().padLeft(4, '0');
  final month = value.month.toString().padLeft(2, '0');
  final day = value.day.toString().padLeft(2, '0');
  return '$year$month$day';
}

int _stableId(String input) {
  var hash = 0x811C9DC5;
  for (final codeUnit in input.codeUnits) {
    hash ^= codeUnit;
    hash = (hash * 0x01000193) & 0xFFFFFFFF;
  }
  return hash & 0x7FFFFFFF;
}
