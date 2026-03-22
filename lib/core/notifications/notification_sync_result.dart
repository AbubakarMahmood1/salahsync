import 'notification_runtime_status.dart';

class NotificationSyncResult {
  const NotificationSyncResult({
    required this.platformAvailable,
    required this.scheduledCount,
    required this.cancelledCount,
    required this.runtimeStatus,
  });

  factory NotificationSyncResult.unavailable() {
    return const NotificationSyncResult(
      platformAvailable: false,
      scheduledCount: 0,
      cancelledCount: 0,
      runtimeStatus: NotificationRuntimeStatus.unavailable(),
    );
  }

  final bool platformAvailable;
  final int scheduledCount;
  final int cancelledCount;
  final NotificationRuntimeStatus runtimeStatus;
}
