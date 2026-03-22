class NotificationRuntimeStatus {
  const NotificationRuntimeStatus({
    required this.platformAvailable,
    required this.notificationsEnabled,
    required this.exactAlarmsSupported,
    required this.exactAlarmsEnabled,
    required this.managedPendingCount,
  });

  const NotificationRuntimeStatus.unavailable()
    : platformAvailable = false,
      notificationsEnabled = false,
      exactAlarmsSupported = false,
      exactAlarmsEnabled = false,
      managedPendingCount = 0;

  final bool platformAvailable;
  final bool notificationsEnabled;
  final bool exactAlarmsSupported;
  final bool exactAlarmsEnabled;
  final int managedPendingCount;

  static const int recommendedPendingCap = 50;
  static const int iosHardPendingCap = 64;

  bool get isUsingExactScheduling {
    if (!platformAvailable) {
      return false;
    }
    if (!exactAlarmsSupported) {
      return true;
    }
    return exactAlarmsEnabled;
  }

  String get notificationsLabel {
    if (!platformAvailable) {
      return 'Unavailable in this environment';
    }
    return notificationsEnabled ? 'Enabled' : 'Disabled';
  }

  String get exactAlarmLabel {
    if (!platformAvailable) {
      return 'Unavailable in this environment';
    }
    if (!exactAlarmsSupported) {
      return 'Not required on this platform';
    }
    return exactAlarmsEnabled
        ? 'Exact alarms enabled'
        : 'Inexact fallback active';
  }

  String get pendingCountLabel {
    if (!platformAvailable) {
      return 'Unavailable in this environment';
    }
    return '$managedPendingCount scheduled (target <= $recommendedPendingCap, iOS hard limit $iosHardPendingCap)';
  }
}
