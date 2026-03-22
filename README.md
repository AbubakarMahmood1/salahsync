# SalahSync

Offline-first Flutter app for managing prayer times and mosque-specific Jamaat schedules in Khanewal, Pakistan.

## Current State

The repository is now implemented through Milestone 5 from [docs/build-plan.md](docs/build-plan.md).

Implemented so far:

- Flutter app shell with `Today`, `Mosques`, `Compare`, and `Settings` tabs
- Pure-Dart prayer-time engine wrapper around `adhan_dart`
- Local Hijri date derivation with override support
- Qibla bearing calculation
- Timing-rule model and resolver for offset, fixed, and date-range-fixed rules
- Drift-backed mosque/settings persistence and seeded data
- Mosque CRUD, timing-rule editing, and comparison UI
- Local notification scheduling with a rolling 48-hour window, permissions, and exact-alarm fallback
- Notification runtime diagnostics, manual 48-hour window rebuild, and battery-optimization guidance
- Persisted theme mode (`system`, `light`, `dark`)
- JSON backup export/import for the local drift database from Settings
- Passphrase-protected backup exports/imports with file-share and file-import flows
- Release validation notes mapped to the SRS checklist in `docs/release-validation.md`
- Unit and widget tests for core domain logic, persistence, scheduling, and the app shell

Not implemented yet:

- Ibadah planner and prayer log flows
- Tasbih counter UI and haptics
- Monthly timetable, Qibla screen UI, and widgets
- Optional manual AlAdhan verification tooling

## Tooling

- Flutter `3.41.5`
- Dart `3.11.3`
- Android min SDK `26`
- iOS deployment target `14.0`

## Commands

```bash
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
flutter analyze
flutter test
```

## Notes

- The SRS defaults to Karachi calculation method and Hanafi Asr, which the domain layer currently uses.
- The original SRS sample for March 22, 2026 lists `Asr 15:46`, but AlAdhan's Hanafi response for that date is `16:41`. The tests follow the external Hanafi reference values and allow the `±1 minute` tolerance already defined in the SRS.
