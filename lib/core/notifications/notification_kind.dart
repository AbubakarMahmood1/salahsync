enum NotificationKind { reminder, adhan, jamaat, sehri, iftar }

extension NotificationKindX on NotificationKind {
  String get label => switch (this) {
    NotificationKind.reminder => 'Reminder',
    NotificationKind.adhan => 'Adhan',
    NotificationKind.jamaat => 'Jamaat',
    NotificationKind.sehri => 'Sehri',
    NotificationKind.iftar => 'Iftar',
  };

  String get channelId => switch (this) {
    NotificationKind.reminder => 'salahsync_reminder',
    NotificationKind.adhan => 'salahsync_adhan',
    NotificationKind.jamaat => 'salahsync_jamaat',
    NotificationKind.sehri => 'salahsync_sehri',
    NotificationKind.iftar => 'salahsync_iftar',
  };

  String get channelName => switch (this) {
    NotificationKind.reminder => 'Prayer reminders',
    NotificationKind.adhan => 'Adhan alerts',
    NotificationKind.jamaat => 'Jamaat alerts',
    NotificationKind.sehri => 'Sehri alerts',
    NotificationKind.iftar => 'Iftar alerts',
  };

  String get channelDescription => switch (this) {
    NotificationKind.reminder =>
      'Pre-prayer reminders from the primary mosque Jamaat schedule.',
    NotificationKind.adhan =>
      'Computed prayer-start alerts based on coordinates and calculation settings.',
    NotificationKind.jamaat =>
      'Primary mosque Jamaat alerts resolved from mosque timing rules.',
    NotificationKind.sehri => 'Ramadan Sehri alerts at Imsak time.',
    NotificationKind.iftar => 'Ramadan Iftar alerts at Maghrib time.',
  };
}
