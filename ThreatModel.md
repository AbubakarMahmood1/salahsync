\## 1. Overview

\- SalahSync is an offline-first Flutter mobile app that manages prayer times and mosque-specific Jamaat schedules for a single device user in Khanewal, Pakistan.

\- Core components:

&#x20; - Domain/time calculation engine using `adhan\_dart`, `timezone`, and `hijri\_calendar` (`lib/core/time/\*`).

&#x20; - Local persistence with Drift/SQLite (`lib/data/db/\*`), storing mosques, timing rules, settings, and prayer logs.

&#x20; - Local notification scheduling with `flutter\_local\_notifications` and background refresh via `workmanager` (`lib/data/services/notification\_sync\_service.dart`, `lib/notifications/background\_refresh.dart`).

&#x20; - JSON backup import/export via copy/paste (`lib/data/services/backup\_service.dart`, Settings UI).

\- There is no backend, networking, or authentication; data is local to the device. The main assets are the integrity of prayer schedules/notifications and confidentiality of stored mosque notes, coordinates, and any prayer log or ibadah data.



\## 2. Threat model, Trust boundaries and assumptions

\*\*Security goals\*\*

\- Preserve correctness/integrity of prayer schedule calculations and notification timing.

\- Protect confidentiality of user-entered data (mosque metadata, notes, logs, coordinates).

\- Ensure availability of notification scheduling and the local database.



\*\*Trust boundaries\*\*

\- \*\*App sandbox vs. device/OS\*\*: SQLite database is stored in the app support directory (`AppDatabase.local`), relying on OS sandboxing/encryption. A rooted or compromised device breaks this boundary.

\- \*\*User/backup input vs. app logic\*\*: UI text fields and JSON backup import are attacker-controlled if a user pastes untrusted content.

\- \*\*App vs. platform services\*\*: Notifications and background tasks require OS permissions and OS scheduling; permission checks gate behavior.

\- \*\*App vs. third‑party packages\*\*: calculation, notifications, background execution, and persistence rely on external packages; supply-chain trust assumed.



\*\*Explicit input ownership\*\*

\- \*\*Attacker-controlled\*\*: values entered in Settings/Mosque forms (names, notes, coordinates, timezone), JSON pasted into the backup import dialog, any data written into the SQLite file if the device is compromised.

\- \*\*Operator-controlled\*\*: app distribution settings, device time/timezone, notification/exact-alarm permissions, OS-level backup/restore mechanisms.

\- \*\*Developer-controlled\*\*: seeded data (`AppSeedService`), migration logic, build scripts/tests.



\*\*Assumptions\*\*

\- The app runs without a network backend; no remote sync or API secrets.

\- The user initiates backup import/export manually.

\- OS sandboxing prevents other apps from reading the DB unless the device is compromised.

\- Single-user use case; no multi-tenancy or role-based access control.



\## 3. Attack surface, mitigations and attacker stories

\*\*Attack surfaces \& mitigations\*\*

1\. \*\*Backup import/export (Settings UI, `BackupService`)\*\*

&#x20;  - Surface: Copy/paste JSON import; untrusted payloads can replace the entire DB.

&#x20;  - Mitigations: schema version checks, strict type validation (`\_read\*` helpers), a maximum copy/paste backup size limit, parsing errors surfaced to the user, asynchronous preview parsing to reduce UI stalls, unsigned SHA-256 checksum metadata on new exports to detect corruption or naive tampering during copy/paste, transactional import to avoid partial writes, and preview/confirmation dialogs.

&#x20;  - Gaps: checksum metadata is not a signature and offers no real authenticity against an attacker who can recompute it, and clipboard usage can leak sensitive data to other apps despite the in-app warning and manual clear option.



2\. \*\*Local persistence (Drift/SQLite)\*\*

&#x20;  - Surface: unencrypted SQLite file with mosque notes, coordinates, and logs.

&#x20;  - Mitigations: foreign-key enforcement and unique indexes (`AppDatabase`, `IbadahCompletionEntries`), use of Drift prepared statements to reduce SQL injection risk, and transactions around updates.

&#x20;  - Gaps: confidentiality depends solely on device OS; no application-level encryption.



3\. \*\*User input forms (Settings/Mosques/Timing rules)\*\*

&#x20;  - Surface: text fields for names, notes, coordinates, timezone, and rule configuration.

&#x20;  - Mitigations: basic validators for required fields and numeric parsing; timezone names are validated against the TZ database before save and invalid persisted values are sanitized back to the default timezone before calculation/scheduling; `TimingRuleRepository` checks for required fields and overlapping date ranges.

&#x20;  - Gaps: extreme strings or misleading but valid timezone values can still create confusing schedules or unwieldy notifications.



4\. \*\*Notification scheduling and background execution\*\*

&#x20;  - Surface: scheduling local notifications with user-provided strings and times, background refresh dispatcher.

&#x20;  - Mitigations: permission checks, safe fallback for missing plugins, limiting the scheduled window to 50 notifications, managed payload prefix for cleanup, non-exported receivers in AndroidManifest.

&#x20;  - Gaps: malformed data can still produce misleading schedules; notifications may appear on lock screens and leak mosque names/notes.



5\. \*\*Platform configuration\*\*

&#x20;  - Surface: Android permissions (`POST\_NOTIFICATIONS`, `SCHEDULE\_EXACT\_ALARM`, `RECEIVE\_BOOT\_COMPLETED`) and background task identifiers.

&#x20;  - Mitigations: receivers are `exported=false`; minimal permissions required for app functionality.

&#x20;  - Gaps: adding new exported components or permissions without review could open new attack vectors.



6\. \*\*Third‑party dependencies\*\*

&#x20;  - Surface: `flutter\_local\_notifications`, `workmanager`, `adhan\_dart`, `timezone`, `drift`.

&#x20;  - Mitigations: version pinning via `pubspec.lock`, no dynamic code loading.

&#x20;  - Gaps: supply-chain or dependency vulnerabilities could impact local integrity or allow code execution.



\*\*Attacker stories\*\*

\- \*\*Malicious backup\*\*: A user imports a backup received from the internet. It contains misleading mosque names or extreme offsets that spam notifications or skew schedules. New exports include checksum metadata that can catch corruption or unsophisticated edits, but backups are still unauthenticated and can fully replace the DB if an attacker recomputes the checksum. Impact is mainly integrity/availability; confidentiality is affected if the backup is exported back out.

\- \*\*Clipboard exfiltration\*\*: After exporting a JSON backup, another app reads the clipboard and exfiltrates mosque details or prayer logs. This is a privacy risk; mitigated only by OS clipboard protections.

\- \*\*Device compromise/physical access\*\*: An attacker with rooted access extracts `salahsync.sqlite` to learn mosque attendance patterns or prayer logs. The app relies on OS encryption and has no app-level at‑rest protection.

\- \*\*Invalid timezone or corrupt settings\*\*: A user or malicious backup sets an invalid timezone string. The app now sanitizes invalid timezone values to the default timezone before calculation and scheduling, so the remaining risk is silent fallback to the default timezone rather than a crash.

\- \*\*Tampered database entries\*\*: On a compromised device, an attacker inserts many timing rules. The scheduler caps notifications to 50 and operates in a 48‑hour window, reducing but not eliminating annoyance or performance impact.



\*\*Out‑of‑scope or low‑relevance classes\*\*

\- Network-driven attacks (SSRF, CSRF, XSS, injection into server endpoints) are not relevant because the app has no network services or webviews.

\- Traditional authentication/authorization flaws are out of scope given the single-user, offline model; device unlock acts as the main access control.



\## 4. Criticality calibration (critical, high, medium, low)

\*\*Critical\*\*

\- Vulnerabilities that enable code execution or sandbox escape on the device, or allow a remote attacker to trigger actions without user involvement.

&#x20; - Examples: a crafted backup causing arbitrary file write/exec via a plugin bug; an exported Android component that allows another app to execute privileged code or run background tasks.



\*\*High\*\*

\- Unauthorized access to sensitive local data without device compromise, or abuse of platform integrations.

&#x20; - Examples: exporting backups to world-readable storage; an exported broadcast receiver or activity that lets another app read/modify the DB or schedule notifications; leakage of prayer logs/notes across apps.



\*\*Medium\*\*

\- Integrity/availability issues that mislead users or prevent timely notifications, but require local interaction or compromised input.

&#x20; - Examples: malicious backup importing misleading schedules; notification spam by malformed timing rules.



\*\*Low\*\*

\- Minor logic or validation issues with limited impact.

&#x20; - Examples: edge‑case calculation errors, minor UI crashes on malformed inputs, or overly verbose error messages revealing internal state.

