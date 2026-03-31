# Release Validation

This file tracks the Milestone 5 hardening pass against Section 10.2 of the SRS.

## Automated / Reviewed

- Offset-based Jamaat rules vs fixed/date-range-fixed anchoring:
  - Covered in `test/core/mosque/timing_rule_resolver_test.dart`
- Date-range inclusivity, year wrapping, overlap rejection, deterministic tie-breaks:
  - Covered in `test/core/mosque/timing_rule_resolver_test.dart`
  - Repository validation covered in `test/data/repositories/timing_rule_repository_test.dart`
- Computed fallback behavior when no rule matches:
  - Covered in `test/core/mosque/timing_rule_resolver_test.dart`
- Single notification mosque scope and deterministic IDs:
  - Covered in `test/data/services/notification_schedule_builder_test.dart`
- Friday Jummah behavior in UI/scheduling:
  - Covered in `test/core/mosque/timing_rule_resolver_test.dart`
  - Covered in `test/data/services/notification_schedule_builder_test.dart`
- Prayer engine reference dates and Qibla bearing:
  - Covered in `test/core/time/prayer_time_service_test.dart`
- Drift migration and uniqueness constraints:
  - Covered in `test/data/db/app_database_test.dart`
- JSON backup/import round-trip with Unicode:
  - Covered in `test/data/services/backup_service_test.dart`
- Notification count safety cap for the 48-hour window:
  - Covered in `test/data/services/notification_schedule_builder_test.dart`
- Ibadah task validation and repeat metadata persistence:
  - Covered in `test/data/repositories/ibadah_task_repository_test.dart`
- Planner expansion for Friday/Jummah and one-time task completion behavior:
  - Covered in `test/data/services/ibadah_planner_service_test.dart`
- Prayer-log persistence and Friday/Jummah read-model behavior:
  - Covered in `test/data/repositories/prayer_log_repository_test.dart`
  - Covered in `test/data/services/prayer_log_read_service_test.dart`
- Manual AlAdhan verification parsing and per-prayer diff computation:
  - Covered in `test/data/services/aladhan_verification_service_test.dart`
- Home widget sync payload generation and platform channel update calls:
  - Covered in `test/data/services/home_widget_sync_service_test.dart`

## Runtime Hardening Added In Milestone 5

- Settings now exposes notification runtime diagnostics:
  - notification permission state
  - exact vs inexact scheduling state
  - managed pending notification count against the 50/64 safety caps
  - manual `Rebuild 48h Window` action
- Settings shows explicit warning banners for:
  - notifications disabled at the OS level
  - Android exact-alarm fallback mode
  - aggressive battery optimization guidance
- Empty states no longer dead-end:
  - Home can jump to `Mosques` or `Settings`
  - Comparison can jump to `Mosques`
- Direct package versions are pinned in `pubspec.yaml`

## Manual Device Validation Still Required

These cannot be completed inside desktop automation and must be run on hardware:

- Android exact-alarm denial/grant flow on Android 14
- Notification rescheduling after reboot
- Manufacturer battery-management behavior on at least one Xiaomi/HyperOS or Samsung device
- iOS notification authorization, pending-count behavior, and sound behavior
- Android home-screen widget placement, refresh cadence, and next-prayer rollover
- Qibla compass heading accuracy and calibration prompt behavior on at least one Android and one iPhone
- Live-device check that AlAdhan verification handles network loss and API success cleanly
- iOS app-group / WidgetKit integration signoff if a native widget extension is added to the Xcode project

Milestone 5 is treated as code-complete once the automated checks pass and the runtime diagnostics above are in place. The items in this section remain release sign-off steps for physical devices.
