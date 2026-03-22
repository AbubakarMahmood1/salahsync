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

Milestone 5 is treated as code-complete once the automated checks pass and the runtime diagnostics above are in place. The items in this section remain release sign-off steps for physical devices.
