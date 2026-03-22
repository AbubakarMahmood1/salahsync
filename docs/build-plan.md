# SalahSync Build Plan

This file turns the SRS in [srs.md](C:/Users/theab/Compressed/salahsync/docs/srs.md) into an implementation order that is realistic for a solo build.

## Recommended MVP

Ship the first usable version with these slices only:

- Core prayer calculation and prayer windows: `FR-1.1` to `FR-1.8`
- Mosque CRUD and timing-rule resolution: `FR-2.1` to `FR-2.7`
- One primary/notification mosque only: `FR-2.6`, `FR-2.6a`
- Local Adhan and Jamaat notifications: `FR-3.1` to `FR-3.8`
- Settings required to support the above: method, madhab, offsets, notification toggles

Defer these until the app is stable on real devices:

- Ibadah planner and tasbih features: `FR-4.x`
- Qibla, widgets, monthly timetable, backup/restore, API verification, and other polish features from `FR-5.x`

Reason: the real engineering risk is not UI volume. It is correctness around prayer calculations, rule resolution, timezone handling, and notification rescheduling on Android and iOS.

## Delivery Order

### Milestone 0: Project Setup

Goal: create a repo that can be built, tested, and extended safely.

- Initialize the Flutter project and commit the base app
- Add packages from the SRS that are needed for MVP only: `adhan_dart`, `drift`, `drift_dev`, `sqlite3_flutter_libs`, `flutter_riverpod`, `flutter_local_notifications`, `timezone`, `workmanager`, `hijri_calendar`, `geolocator`
- Set up `build_runner` and drift code generation
- Create a simple app shell with tabs or routes for Home, Mosques, Comparison, and Settings
- Add analysis options and a minimal test harness

Exit criteria:

- `flutter analyze` passes
- `flutter test` passes
- Drift code generation is wired and repeatable

### Milestone 1: Pure Domain Layer

Goal: make prayer-time and rule-resolution logic correct before tying it to UI.

- Implement a pure Dart `PrayerTimeService`
- Implement settings-driven calculation config: Karachi method, Hanafi madhab, Isha end convention, manual per-prayer offsets
- Implement derived values: prayer windows, next prayer, current prayer, Imsak, Ramadan toggle input, Hijri date with override support
- Implement timing-rule resolution for `offset`, `fixed`, and `date_range_fixed`
- Define a structured resolver result like `resolvedTime`, `source`, `ruleId`, `fallbackUsed`

Exit criteria:

- Unit tests cover the 4 seasonal Khanewal reference dates from the SRS
- Offset propagation matches `FR-1.7a`
- No-rule fallback is explicit and tested
- Date-range wrapping and overlap handling are tested

### Milestone 2: Persistence Layer

Goal: lock in the schema and repositories before building feature screens.

- Implement the drift schema from Section 3 of the SRS
- Create repositories for mosques, timing rules, settings, and lightweight read models for home/comparison views
- Enforce single-primary-mosque behavior in repository logic
- Seed one example mosque for development

Exit criteria:

- CRUD works for mosques and timing rules
- Unique constraints and migrations are tested
- Dev data can be reset and reseeded without manual DB edits

### Milestone 3: MVP UI

Goal: make the app usable without notifications first.

- Home screen: today's prayers, active mosque, next prayer countdown, Jummah-on-Friday behavior
- Mosque list and mosque editor: create, update, archive/disable, set primary
- Timing rule editor for all three rule modes
- Comparison screen for all active mosques
- Settings screen for calculation and offset configuration

Exit criteria:

- A user can fully configure three mosques in-app
- Today's computed and resolved Jamaat times are visible and understandable
- Friday behavior is correct in the main flow

### Milestone 4: Notification Engine

Goal: add reliable notifications without destabilizing the rest of the app.

- Implement notification preferences by prayer and type
- Generate deterministic notification IDs
- Schedule only the next 48 hours
- Reschedule on launch, resume, settings changes, and data changes
- Add Android permission flows for `POST_NOTIFICATIONS`, exact alarms, and reboot restore
- Add iOS authorization flow and inexact scheduling fallback behavior

Exit criteria:

- Duplicate notifications are not created during repeated refreshes
- Exact-alarm denial and fallback flow works on Android 14
- Pending notification count stays under the SRS cap
- Reboot restore is verified on Android hardware

### Milestone 5: First Release Hardening

Goal: turn the MVP into a stable personal-use release.

- Run the validation checklist from Section 10.2 of the SRS
- Improve error handling, empty states, and permission explanations
- Add backup/export if you need device migration early
- Freeze package versions after one clean build/test pass on Android and iOS

Exit criteria:

- Real-device validation passes for at least one Android phone and one iPhone
- No open correctness bugs in prayer math, rule resolution, or scheduling
- The app is usable offline for at least a week of normal use

## Post-MVP Sequence

Add later features in this order:

1. Prayer log and ibadah planner
2. Tasbih counter and haptics
3. Monthly timetable
4. Backup/restore
5. Qibla screen
6. Widgets
7. Optional AlAdhan verification tooling

This order keeps data-entry and daily-use features ahead of hardware-sensitive features like Qibla and widgets.

## Suggested App Structure

Use a structure that keeps domain logic testable:

```text
lib/
  app/
  core/
    time/
    settings/
    notifications/
  features/
    home/
    mosques/
    comparison/
    settings/
    planner/
  data/
    db/
    repositories/
    models/
  services/
```

Keep prayer calculation and timing-rule resolution in pure Dart modules under `core/` so they can be tested without Flutter bindings.

## Immediate Next Step

Build Milestone 0 and Milestone 1 before touching widgets, Qibla, or planner features. If you want the first coding pass to move fast, the next concrete artifact should be a Flutter scaffold plus pure-Dart tests for prayer calculation and timing-rule resolution.
