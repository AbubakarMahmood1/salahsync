<!-- Generated from salah-sync-srs-v1.1.docx using scripts/convert-docx-to-markdown.ps1 -->

SalahSync

Software Requirements Specification

Local-Mosque Prayer Times Manager for Khanewal, Pakistan

Version 1.1

March 22, 2026

Author: SalahSync Development

Platform: Flutter (Android / iOS)

Table of Contents

# 1. PROJECT OVERVIEW

## 1.1 Purpose

SalahSync is a personal, offline-first Flutter mobile app for managing prayer times across multiple mosques in Khanewal, Pakistan. It combines astronomically-computed prayer windows with mosque-specific Jamaat/Iqamah schedules, personal ibadah planning (tasbih counters, dua checklists, daily spiritual routines), and Ramadan-specific features (Sehri/Iftar times).

The application is designed as the developer's personal tool, built solo by a BSSE graduate from FAST Faisalabad. This document serves as the single source of truth for the entire project — both for manual coding and for feeding sections to AI coding assistants (vibe-coding).

## 1.2 Problem Statement

Generic Azan apps (Muslim Pro, Athan, Prayer Now) compute prayer times from coordinates but do not support per-mosque Jamaat/Iqamah schedules, which are community decisions that vary between mosques on the same street.

Mosque-connected platforms (e.g., MAWAQIT) require mosques to register before their iqamah schedules are available to end users. At the time of writing, no Khanewal coverage was identified through MAWAQIT's publicly visible discovery flow; this should be treated as a point-in-time observation rather than a permanent fact.[CHANGED in v1.1: softened MAWAQIT claim from "verified via API" to point-in-time observation]

No existing app combines per-mosque schedule management + personal ibadah planner + ad-free/tracker-free operation.

## 1.3 Scope

In scope:Prayer time calculation, mosque CRUD with timing rules, notifications/alarms, Qibla compass, Ramadan mode, personal ibadah planner (tasbih, dua, daily checklist), data backup/restore.

Out of scope:Social features, mosque registration platforms, Quran reader, hadith database, cloud sync, multi-language support (v1 is English only).

## 1.4 Target Users

Primary:The developer himself (3 mosques in Khanewal).

Secondary:Family members who can add their own mosques via CRUD interface.

## 1.5 Glossary

| Term | Definition |
| --- | --- |
| Adhan | The Islamic call to prayer marking the start of a prayer window |
| Iqamah / Jamaat | The congregational prayer time set by the mosque (often differs from Adhan) |
| Fajr | Pre-dawn obligatory prayer |
| Dhuhr | Midday obligatory prayer |
| Asr | Afternoon obligatory prayer |
| Maghrib | Sunset obligatory prayer |
| Isha | Night obligatory prayer |
| Jummah | Friday congregational prayer replacing Dhuhr |
| Sehri / Suhoor | Pre-dawn meal before fasting begins (ends at Fajr start) |
| Iftar | Meal to break fast (begins at Maghrib start) |
| Imsak | Precautionary buffer before Fajr (typically 10 minutes) |
| Tasbih | Repeated glorification/dhikr phrases, often counted |
| Hanafi | Juristic school prevalent in Pakistan — affects Asr calculation (shadow ratio 2) |
| Karachi Method | Calculation convention by University of Islamic Sciences, Karachi (Fajr 18°, Isha 18°) — standard for Pakistan |
| Prayer Window | The valid time range for performing a prayer (start to end) |
| Notification Mosque | The single mosque designated as the source for Jamaat and pre-Jamaat notifications (v1 supports exactly one) |

<br>

# 2. FUNCTIONAL REQUIREMENTS

All requirements are organized in tables by development phase. Each requirement is assigned a unique identifier for traceability.

## 2.1 Phase 1: Core Engine (Week 1–2)

| ID | Requirement |
| --- | --- |
| FR-1.1 | The app SHALL calculate daily prayer times (Fajr, Sunrise, Dhuhr, Asr, Maghrib, Isha) for any given GPS coordinates and date using the adhan_dart library. |
| FR-1.2 | The default calculation method SHALL be University of Islamic Sciences, Karachi (method ID 1 in AlAdhan: Fajr 18°, Isha 18°). |
| FR-1.3 | The default Asr juristic school SHALL be Hanafi (shadow ratio 2). |
| FR-1.4 | The app SHALL display prayer windows with both start and end times: Fajr starts at computed Fajr and ends at Sunrise; Dhuhr starts at computed Dhuhr and ends at Asr start; Asr starts at computed Asr and ends at Maghrib start; Maghrib starts at computed Maghrib and ends at Isha start; Isha starts at computed Isha and ends at midnight (or Fajr, configurable). |
| FR-1.5 | The app SHALL compute and display Imsak time (Fajr minus 10 minutes, configurable offset). |
| FR-1.6 | The app SHALL display both Gregorian and Hijri dates. |
| FR-1.6a | [NEW in v1.1] The app SHALL use a documented local Hijri conversion package (hijri_calendar or equivalent) for offline Hijri date display. Because local moon-sighting announcements may differ from algorithmic conversion by ±1 day, the displayed Hijri date and Ramadan state SHALL support a user override. |
| FR-1.7 | The app SHALL allow the user to configure: calculation method, Asr juristic school, Isha end time convention, and per-prayer manual adjustments in minutes. |
| FR-1.7a | [NEW in v1.1] Manual per-prayer adjustments SHALL be applied consistently to all derived computed times used by the app, including prayer-window boundaries, next/current prayer status, Adhan notifications, Imsak, and offset-based mosque rules. Fixed-time and date-range-fixed mosque rules SHALL remain anchored to their explicit clock times. |
| FR-1.8 | All prayer time calculations SHALL work fully offline without internet connectivity. |

## 2.2 Phase 1: Mosque Management (Week 2)

| ID | Requirement |
| --- | --- |
| FR-2.1 | The app SHALL support CRUD operations for mosques (Create, Read, Update, Delete). |
| FR-2.2 | Each mosque record SHALL store: name, area/address (text), GPS coordinates (optional), active/inactive toggle, and notes. |
| FR-2.3 | Each mosque SHALL support per-prayer Jamaat timing rules with THREE modes: Mode A — Offset: Jamaat time = computed prayer start + N minutes (e.g., Maghrib Jamaat = Maghrib + 5 min). Mode B — Fixed Time: Jamaat at a fixed clock time regardless of season (e.g., Jummah always at 13:30). Mode C — Date-Range Fixed: Jamaat at a fixed clock time within a date range (e.g., Isha at 20:30 from May 1 to Aug 31, then 19:00 from Sep 1 to Apr 30) — this is how most Khanewal mosques actually operate: 5-minute seasonal jumps, not 1-minute daily shifts. |
| FR-2.4 | A mosque SHALL support multiple timing rules per prayer (to cover different seasonal ranges in Mode C). The app resolves which rule is active based on today's date. |
| FR-2.5 | The app SHALL support a Jummah timing field separate from Dhuhr. |
| FR-2.5a | [NEW in v1.1] Jummah Model: On Fridays, the Home Screen SHALL display Jummah instead of Dhuhr in the prayer list. The timing_rules table already supports prayer="jummah" as a distinct entry. Prayer log records Friday congregational prayer as prayer="jummah" (not Dhuhr). The monthly timetable shows Dhuhr times for all days but adds a Jummah row for Fridays only. |
| FR-2.6 | The user SHALL be able to set one mosque as "primary" for the home screen display. |
| FR-2.6a | [NEW in v1.1] Notification Mosque: The app SHALL support a single designated "notification mosque" for Jamaat and pre-Jamaat notifications. In v1, this is the same as the primary mosque and is the only option — notifications are not multiplied across stored mosques. Adhan notifications remain coordinate-based and are independent of which mosque is selected. Users can check other mosques' Jamaat times via the Comparison screen without receiving notifications for them. |
| FR-2.7 | The app SHALL display a comparison view showing today's Jamaat times across all active mosques side by side. |

<br>

## 2.3 Phase 2: Notifications & Alarms (Week 3)

| ID | Requirement |
| --- | --- |
| FR-3.1 | The app SHALL schedule local notifications for Adhan times (computed prayer start) and/or Jamaat times (from the notification mosque only) per user preference. |
| FR-3.2 | The user SHALL be able to toggle notifications independently per prayer and per type (Adhan vs. Jamaat). |
| FR-3.3 | The app SHALL support a configurable pre-prayer reminder offset (e.g., "notify me 15 minutes before Jamaat"). |
| FR-3.4 | The app SHALL use a 48-hour rolling notification window: schedule notifications for today and tomorrow only, then reschedule via background task and app lifecycle events. |
| FR-3.5 | [REVISED in v1.1] Rescheduling triggers: The app SHALL recalculate and refresh the next 48 hours of notifications on app launch, on foreground resume after date/time changes, after device reboot (via RECEIVE_BOOT_COMPLETED), after notification-permission changes, and during best-effort background execution via workmanager. Background execution is advisory and OS-scheduled; the system does not guarantee an exact midnight run on Android or iOS. |
| FR-3.6 | The app SHALL request POST_NOTIFICATIONS permission on Android 13+ at runtime with a clear explanation dialog. |
| FR-3.6a | [NEW in v1.1] On iOS, the app SHALL request notification authorization (alert, sound, badge) through an explicit in-app explanation flow rather than relying on an automatic permission prompt during plugin initialization. |
| FR-3.7 | The app SHALL handle Android 14's SCHEDULE_EXACT_ALARM restriction gracefully: check canScheduleExactAlarms(), attempt exact alarms if available, fall back to inexact scheduling if denied, and explain to the user via settings how to grant the permission manually. |
| FR-3.7a | [NEW in v1.1] If exact alarm access is unavailable, the app SHALL schedule notifications using the notification plugin's inexact scheduling mode. The app SHALL also detect permission grant/revoke changes and reschedule pending exact alarms accordingly. If exact-alarm access is revoked, the system cancels future exact alarms, so the app must detect this and reschedule as inexact. |
| FR-3.8 | The app SHALL respect iOS's 64 pending notification limit by only scheduling the next 48 hours. With one notification mosque, the worst-case count is approximately 35 notifications in a 48-hour window (5 prayers × 3 types × 2 days + Sehri + Iftar + Jummah), well under the 64 cap. |
| FR-3.9 | The app SHALL support custom notification sounds (Azan audio) with a default built-in Azan clip. |
| FR-3.9a | [NEW in v1.1] On iOS, any custom notification sound used for Azan SHALL comply with platform restrictions: bundled resource, supported audio format, and duration under 30 seconds. If the preferred Azan audio exceeds platform limits, the app SHALL use a short alert clip for the notification and MAY offer fuller in-app audio playback separately. |
| FR-3.10 | Ramadan mode: The app SHALL provide Sehri alarm (at Imsak time) and Iftar alert (at Maghrib) with distinct notification channels. |
| FR-3.10a | [NEW in v1.1] Ramadan mode SHOULD default from Hijri month detection, but SHALL remain user-overridable (because algorithmic Hijri dates may differ from local moon sighting by ±1 day). |

## 2.4 Phase 3: Ibadah Planner (Week 4)

| ID | Requirement |
| --- | --- |
| FR-4.1 | The app SHALL support a daily checklist of ibadah tasks (e.g., "Morning Adhkar", "Read Surah Mulk after Isha", "Tasbih 33×33×34 after each prayer"). |
| FR-4.2 | Each ibadah task SHALL have: title, optional description, optional prayer linkage (e.g., "after Fajr"), repeat pattern (daily, weekly, specific days, after every prayer, one-time). |
| FR-4.3 | The app SHALL provide a tasbih counter screen: tap to count, with a configurable target (e.g., 100), vibration/haptic feedback on each tap, and a notification/sound when target is reached. |
| FR-4.4 | The app SHALL track completion status per day (checkbox-style). |
| FR-4.5 | The app SHALL allow per-mosque notes (free text). |
| FR-4.6 | The app SHALL support a prayer log: mark each prayer as "prayed in Jamaat at [mosque]", "prayed alone", or "missed", with optional notes. On Fridays, the Dhuhr slot is replaced by Jummah in the prayer log. |

## 2.5 Phase 4: Polish & Extras (Week 5+)

| ID | Requirement |
| --- | --- |
| FR-5.1 | The app SHALL display Qibla direction using device compass/magnetometer, showing a visual compass arrow pointing toward the Kaaba (21.4225°N, 39.8262°E). |
| FR-5.2 | The Qibla screen SHALL show the bearing in degrees as a numeric fallback (e.g., "260.5° W") alongside the compass. |
| FR-5.3 | The Qibla screen SHALL display a "Calibrate: move your phone in a figure-8 pattern" prompt when sensor accuracy is low. |
| FR-5.4 | The app SHALL display a monthly prayer timetable view (calendar grid showing all prayer times for the month). |
| FR-5.5 | During Ramadan, the monthly view SHALL highlight Sehri and Iftar times prominently. On Fridays, the timetable SHALL show a Jummah row in addition to Dhuhr. |
| FR-5.6 | The app SHALL support data export (JSON) and import for backup/restore/sharing between family members. |
| FR-5.7 | The app SHALL support a home screen widget showing next prayer name + scheduled time for the primary mosque. |
| FR-5.7a | [NEW in v1.1] Home-screen widget support SHALL be treated as a native-platform feature requiring platform-specific code (WidgetKit on iOS, AppWidgetProvider on Android). On iOS, the widget SHALL display "next prayer + scheduled time" or a coarse timeline-based countdown, not a guaranteed live second-by-second countdown. On Android, more frequent updates are possible but should remain battery-conscious. |
| FR-5.8 | The app SHALL support dark/light theme toggle. |
| FR-5.9 | [REVISED in v1.1] The app MAY optionally verify computed times against AlAdhan API when internet is available. This verification SHALL be manual/user-initiated only (not automatic background calls), showing a comparison indicator if times differ by more than 2 minutes. API verification SHALL compare unadjusted engine output to unadjusted API output so that user manual offsets do not create false discrepancy warnings. |

<br>

# 3. DATA MODEL

The following relational schema defines the SQLite database structure managed by the drift ORM. All tables, column types, constraints, and relationships are specified below.

## 3.1 Table: mosques

| Column | Type | Constraints | Description |
| --- | --- | --- | --- |
| id | INTEGER | PK, AUTO | Unique identifier |
| name | TEXT | NOT NULL | Mosque name (e.g., "Masjid Al-Noor") |
| area | TEXT | NULLABLE | Area or address description |
| latitude | REAL | NULLABLE | GPS latitude |
| longitude | REAL | NULLABLE | GPS longitude |
| is_primary | INTEGER | DEFAULT 0 | 1 if this is the home screen and notification mosque |
| is_active | INTEGER | DEFAULT 1 | 0 to hide without deleting |
| notes | TEXT | NULLABLE | Free-form notes about this mosque |
| created_at | TEXT | NOT NULL | ISO 8601 timestamp |
| updated_at | TEXT | NOT NULL | ISO 8601 timestamp |

Note: In v1, is_primary serves double duty as both the home screen mosque and the notification mosque. Only one mosque may have is_primary=1 at a time (enforced in application logic).

## 3.2 Table: timing_rules

| Column | Type | Constraints | Description |
| --- | --- | --- | --- |
| id | INTEGER | PK, AUTO | Unique identifier |
| mosque_id | INTEGER | FK → mosques.id, NOT NULL | Which mosque this rule belongs to |
| prayer | TEXT | NOT NULL | One of: fajr, dhuhr, asr, maghrib, isha, jummah |
| mode | TEXT | NOT NULL | One of: offset, fixed, date_range_fixed |
| offset_minutes | INTEGER | NULLABLE | For mode=offset: minutes after computed start |
| fixed_time | TEXT | NULLABLE | For mode=fixed or date_range_fixed: "HH:MM" in 24h |
| range_start | TEXT | NULLABLE | For mode=date_range_fixed: "MM-DD" start |
| range_end | TEXT | NULLABLE | For mode=date_range_fixed: "MM-DD" end |
| priority | INTEGER | DEFAULT 0 | Higher priority wins when multiple rules match |
| created_at | TEXT | NOT NULL | ISO 8601 timestamp |

## 3.3 Table: ibadah_tasks

| Column | Type | Constraints | Description |
| --- | --- | --- | --- |
| id | INTEGER | PK, AUTO | Unique identifier |
| title | TEXT | NOT NULL | Task name (e.g., "Ayat al-Kursi") |
| description | TEXT | NULLABLE | Optional detailed description |
| prayer_link | TEXT | NULLABLE | Which prayer this is linked to (fajr/dhuhr/etc, or null for general) |
| timing | TEXT | DEFAULT 'after' | 'before' or 'after' the linked prayer |
| repeat_type | TEXT | NOT NULL | daily, weekly, specific_days, after_each_prayer, one_time |
| repeat_days | TEXT | NULLABLE | JSON array for specific_days, e.g., ["mon","thu"] |
| count_target | INTEGER | NULLABLE | Target count for tasbih-type tasks (e.g., 100) |
| is_active | INTEGER | DEFAULT 1 | Active toggle |
| sort_order | INTEGER | DEFAULT 0 | Display ordering |

## 3.4 Table: ibadah_completions

| Column | Type | Constraints | Description |
| --- | --- | --- | --- |
| id | INTEGER | PK, AUTO | Unique identifier |
| task_id | INTEGER | FK → ibadah_tasks.id, NOT NULL | Which task |
| date | TEXT | NOT NULL | "YYYY-MM-DD" |
| prayer_instance | TEXT | NULLABLE | Which prayer instance if applicable |
| count_done | INTEGER | DEFAULT 0 | Actual count achieved (for tasbih tasks) |
| completed | INTEGER | DEFAULT 0 | 1 if fully completed |
| notes | TEXT | NULLABLE | Optional notes for this completion |

Unique constraint:(task_id, date, prayer_instance) — prevents duplicate completion rows for the same logical event.[NEW in v1.1]

## 3.5 Table: prayer_log

| Column | Type | Constraints | Description |
| --- | --- | --- | --- |
| id | INTEGER | PK, AUTO | Unique identifier |
| date | TEXT | NOT NULL | "YYYY-MM-DD" |
| prayer | TEXT | NOT NULL | fajr, dhuhr, asr, maghrib, isha, jummah |
| status | TEXT | NOT NULL | jamaat, alone, missed |
| mosque_id | INTEGER | NULLABLE | FK → mosques.id (if status=jamaat) |
| notes | TEXT | NULLABLE | Optional notes |
| logged_at | TEXT | NOT NULL | ISO 8601 timestamp |

Unique constraint:(date, prayer) — one log entry per prayer per day. On Fridays, "jummah" replaces "dhuhr" as the prayer value.[NEW in v1.1]

## 3.6 Table: app_settings

| Column | Type | Constraints | Description |
| --- | --- | --- | --- |
| key | TEXT | PK | Setting identifier |
| value | TEXT | NOT NULL | JSON-encoded value |

Settings keys include: calculation_method, asr_school, imsak_offset, isha_end_convention, theme_mode, notification_prefs (JSON object with per-prayer toggles), ramadan_mode_enabled, ramadan_mode_override (user manual toggle), hijri_date_offset (integer, for manual ±1 day correction), default_coordinates.

## 3.7 Resolution Logic for timing_rules

1. Filter rules for the given mosque_id and prayer.

2. For mode=date_range_fixed: check if today's MM-DD falls within range_start and range_end (handle year-wrapping: if range_start > range_end, it spans across Dec–Jan).

3. Among matching rules, pick the one with highest priority. If priorities are equal, prefer the most specific mode (date_range_fixed > fixed > offset) as the deterministic tie-break.[REFINED in v1.1]

4. If no rules match, fall back to computed astronomical time (this is explicit fallback behavior, not an error).[CLARIFIED in v1.1]

The resolver SHALL return a structured result: resolvedTime, source (computed | offset | fixed | date_range_fixed), sourceRuleId (nullable), fallbackUsed (boolean). This supports debugging, comparison screens, tests, and future migrations.[NEW in v1.1]

<br>

# 4. API CONTRACTS

## 4.1 AlAdhan Prayer Times API (Optional — Verification Only)

Base URL:https://api.aladhan.com/v1

### 4.1.1 Get Daily Timings by City

GET /timingsByCity/{date}

Query Parameters:

city: "Khanewal"

country: "Pakistan"

method: 1 (University of Islamic Sciences, Karachi)

school: 1 (Hanafi)

Sample Response (captured 22 March 2026):

{

"data": {

"timings": {

"Fajr": "04:54",

"Sunrise": "06:14",

"Dhuhr": "12:19",

"Asr": "15:46",

"Maghrib": "18:25",

"Isha": "19:45",

"Imsak": "04:44",

"Midnight": "00:19"

},

"date": {

"hijri": { "date": "03-10-1447", "month": {"en": "Shawwal"}, "year": "1447" },

"gregorian": { "date": "22-03-2026" }

}

}

}

[CHANGED in v1.1: "verified live" changed to "sample response captured" to accurately represent evidence level]

### 4.1.2 Get Monthly Calendar

GET /calendarByCity/{year}/{month}

Query Parameters: same as above

Returns: array of daily timings for the entire month

Notes:

No API key required for basic use.

Community guidance mentions an approximate per-IP rate limit — cache responses; one call per day is sufficient.[REFINED in v1.1]

The API does NOT return Jamaat/Iqamah times — those are mosque-specific and must come from local data.

AlAdhan itself warns that computed timings may not match a local mosque or authority exactly.

Timezone is auto-detected from city/country (Asia/Karachi).

## 4.2 Internal Service Interfaces (Dart)

The following abstract service contracts define the internal API surface for the app's business logic:

PrayerTimeService:

calculateDailyTimes(coordinates, date, settings) -> PrayerTimesResult

calculateMonthlyTimes(coordinates, year, month, settings) -> List<PrayerTimesResult>

getCurrentPrayer(times) -> Prayer

getNextPrayer(times) -> (Prayer, DateTime)

getTimeUntilNext(times) -> Duration

MosqueScheduleService:

getJamaatTimes(mosqueId, date) -> Map<Prayer, ResolvedJamaatTime?>

resolveActiveRule(mosqueId, prayer, date) -> TimingRuleResult?

// returns structured result with source info

getComparisonTable(date) -> Map<Mosque, Map<Prayer, ResolvedJamaatTime>>

NotificationScheduler:

scheduleNext48Hours(mosqueId, settings) -> void

cancelAllForMosque(mosqueId) -> void

// NOT blanket cancelAll() — targeted cancellation

rescheduleDaily() -> void

// Called by workmanager and lifecycle events

getScheduledCount() -> int

// For debugging and cap verification

Notification IDs: Use deterministic IDs based on (mosqueId, localDate, prayer, notificationKind) to enable idempotent scheduling and targeted cancellation without races.[NEW in v1.1]

QiblaService:

calculateBearing(userLat, userLng) -> double // degrees from north

getCompassStream() -> Stream<CompassEvent>

BackupService:

exportToJson() -> String

importFromJson(String json) -> ImportResult

<br>

# 5. NOTIFICATION & ALARM STRATEGY

## 5.1 The Problem

Mobile OS notification systems are designed for generic use and actively fight against "schedule many alarms upfront" patterns:

iOS limits apps to 64 pending local notifications. The system keeps the last 64 scheduled requests on newer iOS versions, so deterministic scheduling matters.

Android 13+ requires runtime POST_NOTIFICATIONS permission.

Android 12+ requires SCHEDULE_EXACT_ALARM permission. Android 14 denies this by default for newly installed apps targeting API 33+. If exact-alarm access is revoked, the system cancels all future exact alarms.

Battery optimization on Android (Doze mode, manufacturer-specific optimizations like MIUI, ColorOS, etc.) can kill background processes.

iOS background fetch timing is OS-controlled and typically about once per day based on usage patterns — not exact-wall-clock scheduling.

## 5.2 The Strategy: 48-Hour Rolling Window with Multi-Trigger Rescheduling

[REVISED in v1.1: removed "midnight wakeup" assumption, replaced with multi-trigger approach]

1. On app launch, on foreground resume after date/time changes, after device reboot, after notification-permission changes, and during best-effort background execution: recalculate prayer times for today and tomorrow.

2. Schedule local notifications for only these 2 days (approximately 35 notifications worst-case: see calculation below).

3. This stays well under iOS's 64 limit.

4. Background execution (workmanager) provides an additional refresh opportunity but is NOT the sole rescheduling mechanism.

5. Use deterministic notification IDs and diff desired vs. already-scheduled notifications instead of blanket cancelAll(). This reduces races when foreground and background refreshes run close together.

## 5.3 Notification Types Per Prayer

For each of the 5 daily prayers, up to 3 notifications (all independently toggleable per prayer). All Jamaat/pre-Jamaat notifications come from the single notification mosque only:

1. Pre-Jamaat Reminder: N minutes before notification mosque's Jamaat time (default: 15 min)

2. Adhan Alert: At computed prayer start time (coordinate-based, mosque-independent)

3. Jamaat Alert: At notification mosque's specific Jamaat time

## 5.4 Special Notifications

Sehri Alarm: At Imsak time during Ramadan (separate notification channel, higher priority)

Iftar Alert: At Maghrib during Ramadan

Jummah Reminder: Configurable time on Fridays (e.g., 30 min before Jummah)

## 5.5 Worst-Case Notification Count (48-hour window)

[NEW in v1.1]

Base: 5 prayers × 3 types × 2 days = 30

Ramadan extras: +2 per day (Sehri + Iftar) × 2 days = +4

Friday in window: +1 (Jummah reminder)

Total worst case: 35 notifications — well under iOS's 64 cap.

This math holds ONLY because v1 limits Jamaat notifications to one mosque. Supporting multiple notification mosques would require revisiting this calculation.

## 5.6 Android-Specific Handling

1. Request POST_NOTIFICATIONS at startup (Android 13+) with explanation dialog.

2. Check canScheduleExactAlarms().

3. If exact alarms available: use flutterLocalNotificationsPlugin.zonedSchedule().

4. If denied: use inexact scheduling with allowWhileIdle: true.

5. Show in-app banner: "For precise prayer alarms, grant exact alarm permission in Settings".

6. Link directly to Settings.ACTION_REQUEST_SCHEDULE_EXACT_ALARM intent.

7. Detect permission grant/revoke changes and reschedule accordingly.

## 5.7 iOS-Specific Handling

[NEW in v1.1]

1. Request notification authorization (alert, sound, badge) through explicit in-app explanation flow.

2. Custom Azan sounds MUST be under 30 seconds and in a supported format (AIFF, WAV, CAF). If the preferred audio exceeds this, use a short alert clip for the notification and offer full playback in-app.

3. Widget updates use WidgetKit timeline entries — coarse, not real-time.

## 5.8 Notification Channels (Android)

| Channel ID | Name | Sound | Importance |
| --- | --- | --- | --- |
| prayer_adhan | Prayer Time Alerts | Azan audio clip | HIGH |
| prayer_jamaat | Jamaat Reminders | Default | HIGH |
| prayer_pre_reminder | Pre-Prayer Reminders | Default | DEFAULT |
| ramadan_sehri | Sehri Alarm | Custom alarm | MAX |
| ramadan_iftar | Iftar Alert | Default | HIGH |

## 5.9 Background Task Configuration (workmanager)

[REVISED in v1.1]

Workmanager().registerPeriodicTask(

"daily_prayer_reschedule",

"reschedule_notifications",

frequency: Duration(hours: 12), // twice daily for better coverage

constraints: Constraints(networkType: NetworkType.not_required),

existingWorkPolicy: ExistingWorkPolicy.replace,

)

Note: This is a best-effort background refresh. The primary rescheduling mechanism is app lifecycle events (launch, resume). Background execution provides additional coverage for users who don't open the app daily. Exact timing of background execution is OS-controlled on both Android and iOS.

<br>

# 6. SCREEN INVENTORY & NAVIGATION

## 6.1 Navigation Structure

Bottom navigation bar with 4 tabs:

| Tab | Label | Primary Content |
| --- | --- | --- |
| 1 | Home | Today's prayer schedule |
| 2 | Mosques | List + CRUD |
| 3 | Ibadah | Planner + Tasbih |
| 4 | Settings | App configuration |

## 6.2 Screen Definitions

### S-1: Home Screen (Today)

Header: Current date (Gregorian + Hijri with manual offset indicator if active), current location/mosque name.

Primary card: Next prayer name + countdown timer (live updating).

Prayer list: All 5 prayers (or 4 + Jummah on Fridays) showing: prayer name, prayer window (start – end), selected mosque's Jamaat time, status indicator (upcoming / current / passed).

During Ramadan: Sehri and Iftar times prominently shown at top.

Quick action: Tap a prayer to log it (prayed in jamaat / alone / missed).

### S-2: Mosque List Screen

List of all mosques with name, area, active/inactive badge.

Primary/notification mosque indicated with a star icon.

Swipe actions: Edit, Delete (with confirmation).

FAB: Add new mosque.

### S-3: Mosque Detail / Edit Screen

Mosque info fields: name, area, coordinates (auto-detect from GPS or manual), notes.

Jamaat Rules section: per-prayer rule editor.

Select prayer (including Jummah as a separate option) → Select mode (Offset / Fixed / Date-Range Fixed).

Mode-specific inputs: Offset: number picker for minutes; Fixed: time picker; Date-Range: time picker + date range picker (MM-DD to MM-DD).

List of all rules for this mosque with edit/delete.

Validation: warn on overlapping date ranges for the same prayer.

Toggle: Set as primary mosque (and notification mosque).

### S-4: Mosque Comparison Screen

Table view: rows = prayers, columns = mosques.

Shows today's Jamaat time for each mosque side by side.

Indicates source of each time (offset/fixed/date-range/computed fallback).

Tap a cell to see rule details.

### S-5: Ibadah Planner Screen

Today's checklist: all active ibadah tasks for today, grouped by prayer.

Checkbox to mark complete.

Tasbih tasks show count progress (e.g., "67/100").

Tap tasbih task to open counter.

FAB: Add new ibadah task.

### S-6: Ibadah Task Editor

Title, description, prayer link (dropdown: none/fajr/dhuhr/asr/maghrib/isha/any), before/after toggle.

Repeat type: daily, weekly, specific days (day picker), after each prayer, one-time.

Count target (for tasbih): number input, or null for checkbox-only tasks.

Active toggle.

### S-7: Tasbih Counter Screen

Full-screen counter display (large number).

Tap anywhere to increment.

Haptic feedback on each tap.

Sound/vibration on reaching target.

Progress ring around the counter.

Reset button.

### S-8: Prayer Log Screen

Calendar view: tap a date to see that day's log.

Per-prayer status: colored indicators (green=jamaat, yellow=alone, red=missed, gray=not logged) PLUS text labels (never color alone).

Weekly/monthly summary stats.

On Fridays: Jummah shown instead of Dhuhr.

### S-9: Qibla Screen

Compass visualization with arrow pointing toward Kaaba.

Bearing number display (e.g., "260.5°") — always visible as primary fallback.

Compass accuracy indicator (low/medium/high).

Calibration prompt when accuracy is low: animated figure-8 guide.

GPS coordinates display.

### S-10: Monthly Timetable Screen

Calendar grid for selected month.

Each day shows: Fajr, Sunrise, Dhuhr, Asr, Maghrib, Isha times.

On Fridays: additional Jummah row.

Ramadan overlay: Sehri (Imsak) and Iftar (Maghrib) highlighted.

Swipe between months.

### S-11: Settings Screen

Calculation method (dropdown: Karachi, MWL, ISNA, Umm al-Qura, etc.)

Asr school (Hanafi / Shafi)

Isha end time (Midnight / Fajr)

Imsak offset (number, default 10 minutes)

Manual adjustments per prayer (±minutes)

Hijri date offset (±1 day for moon sighting correction)

Notification preferences: per-prayer toggles for each notification type

Pre-reminder offset (minutes before Jamaat)

Ramadan mode: auto-detect from Hijri / manual override toggle

Theme: Light / Dark / System

Backup: Export JSON, Import JSON

AlAdhan verification: manual check button (user-initiated only)

About: version, credits, open-source attribution

### S-12: Data Backup/Restore Screen

Export button: generates JSON file, share via system share sheet.

Import button: file picker, validates JSON, shows preview of what will be imported, confirm to import.

JSON includes schema version for forward compatibility.

Clear all data option (with double confirmation).

<br>

# 7. NON-FUNCTIONAL REQUIREMENTS

| ID | Requirement |
| --- | --- |
| NFR-1 | Offline-First: All core features (prayer calculation, mosque schedules, ibadah planner, tasbih counter) SHALL function without internet connectivity. |
| NFR-2 | Privacy: The app SHALL NOT include any analytics SDKs, ad networks, or third-party trackers. No data leaves the device except optional AlAdhan API calls which are manual/user-initiated only. [REFINED in v1.1] |
| NFR-3 | Performance: Prayer time calculation SHALL complete in under 50ms. App cold start SHALL be under 2 seconds on mid-range Android devices. |
| NFR-4 | Storage: The SQLite database SHALL remain under 5MB for typical usage (50 mosques, 1 year of prayer logs). |
| NFR-5 | Correctness: Prayer time calculations SHALL be verified against AlAdhan API output for Khanewal coordinates (30.3017°N, 71.9321°E) for at least 4 dates across seasons (equinoxes and solstices). Maximum acceptable deviation: ±1 minute. |
| NFR-6 | [REVISED in v1.1] Permissions: Minimum required: POST_NOTIFICATIONS (Android 13+ runtime permission), SCHEDULE_EXACT_ALARM (Android 12+ special app access, with graceful degradation), RECEIVE_BOOT_COMPLETED (Android manifest permission for restoring scheduled notifications after reboot), iOS notification authorization (alert/sound/badge), Location (optional, for auto-coordinates and Qibla), Sensors (for compass). NO storage, camera, contacts, or unnecessary network permissions. Note: On Android, exact alarms are special app access, not a normal runtime permission. |
| NFR-7 | Compatibility: Minimum Android API 26 (Android 8.0). Minimum iOS 14. Target Android API 34+ and latest iOS. |
| NFR-8 | Accessibility: Minimum touch target size 48dp. Support system font scaling. Color is never the sole indicator of state (always paired with icons/text). |
| NFR-9 | Data Integrity: All database writes SHALL use transactions. Backup export SHALL include a schema version for forward compatibility. Unique constraints on (task_id, date, prayer_instance) in ibadah_completions and (date, prayer) in prayer_log prevent duplicate entries. |
| NFR-10 | Testability: Prayer calculation logic SHALL be in a pure Dart layer with no Flutter dependencies, enabling unit testing without a device/emulator. |

<br>

# 8. PHASED ROADMAP WITH SUB-TASKS

## 8.1 Phase 1: Core Engine & Mosque Management (Week 1–2)

### Week 1: Foundation

☐ Initialize Flutter project with folder structure (lib/models, lib/services, lib/screens, lib/widgets, lib/database)

☐ Add dependencies: adhan_dart, drift + drift_dev + sqlite3_flutter_libs, hijri_calendar (or equivalent Hijri package), state management package

☐ Implement PrayerTimeService: wrapper around adhan_dart with configurable CalculationMethod and Madhab

☐ Implement manual-adjustment propagation logic (FR-1.7a): adjustments affect computed times but not fixed rules

☐ Write unit tests: verify Khanewal times for 4 seasonal dates against AlAdhan API reference values

☐ Set up drift database: define all tables (mosques, timing_rules, ibadah_tasks, ibadah_completions, prayer_log, app_settings) with unique constraints

☐ Run drift code generation, verify migrations work

☐ Implement MosqueRepository: CRUD operations for mosques table with is_primary enforcement (only one primary at a time)

☐ Implement TimingRuleRepository: CRUD for timing_rules with overlap validation on date ranges

### Week 2: Mosque UI + Home Screen

☐ Build Mosque List screen with add/edit/delete

☐ Build Mosque Detail/Edit screen with Jamaat rule editor (all 3 modes)

☐ Implement timing rule resolution engine with structured result (resolvedTime, source, sourceRuleId, fallbackUsed)

☐ Build Home Screen: next prayer countdown, today's full schedule for primary mosque, Jummah on Fridays

☐ Implement live countdown timer (StreamBuilder or Riverpod timer)

☐ Build Mosque Comparison screen: table of all mosques × today's Jamaat times

☐ Implement Hijri date display with manual offset setting

☐ Manual testing pass: add 3 real Khanewal mosques, verify all timing modes work

## 8.2 Phase 2: Notifications & Alarms (Week 3)

☐ Add dependencies: flutter_local_notifications, workmanager

☐ Configure Android notification channels (5 channels as specified in Section 5.8)

☐ Implement NotificationScheduler with deterministic IDs: (mosqueId, localDate, prayer, notificationKind)

☐ Implement 48-hour rolling window logic with diff-based scheduling (not cancelAll)

☐ Implement rescheduling triggers: app launch, foreground resume, date/time change detection

☐ Add RECEIVE_BOOT_COMPLETED to Android manifest and implement BroadcastReceiver that triggers reschedule on device reboot [NEW in v1.1]

☐ Handle Android 13+ POST_NOTIFICATIONS permission request with explanation dialog

☐ Handle Android 14 SCHEDULE_EXACT_ALARM: check, request, fallback to inexact, detect grant/revoke changes

☐ Implement iOS notification authorization flow with in-app explanation

☐ Prepare iOS-safe Azan audio clip (under 30 seconds, supported format)

☐ Test notification count: verify worst-case 48-hour window stays under 50 (buffer below 64)

☐ Test on physical Android device: verify notifications fire in Doze mode

☐ Add per-prayer notification toggles in Settings screen

☐ Add Ramadan-specific notification channels (Sehri/Iftar) with user-overridable Ramadan mode

## 8.3 Phase 3: Ibadah Planner (Week 4)

☐ Implement IbadahTaskRepository: CRUD for ibadah_tasks

☐ Implement IbadahCompletionRepository: daily completion tracking with unique constraint enforcement

☐ Build Ibadah Planner screen: today's tasks grouped by prayer, checkboxes

☐ Build Ibadah Task Editor screen: all fields + repeat configuration

☐ Build Tasbih Counter screen: full-screen tap counter with haptics

☐ Implement prayer log: per-prayer status logging with Jummah on Fridays

☐ Build Prayer Log screen: calendar view with colored indicators + text labels + stats

☐ Add per-mosque notes (already in mosque model, just add UI)

## 8.4 Phase 4: Polish & Extras (Week 5+)

☐ Add flutter_qiblah dependency

☐ Build Qibla screen: compass + bearing (260.5° for Khanewal) + calibration prompt

☐ Build Monthly Timetable screen: calendar grid with prayer times, Jummah rows on Fridays

☐ Add Ramadan mode: highlight Sehri/Iftar, auto-detect from Hijri with manual override

☐ Implement BackupService: JSON export/import with schema version and Unicode preservation

☐ Build Backup/Restore screen

☐ Add dark/light theme toggle

☐ Add home screen widget (home_widget package + native platform code): next prayer + scheduled time

☐ Optional: AlAdhan API manual verification with unadjusted comparison

☐ Polish: loading states, error handling, empty states, edge cases

☐ Final testing pass on physical devices (Android + iOS if available)

<br>

# 9. TECH STACK & PACKAGE REGISTRY

| Category | Package | Purpose | Notes |
| --- | --- | --- | --- |
| Framework | Flutter 3.x (latest stable) | Cross-platform mobile framework |  |
| Language | Dart 3.x (latest stable) | Primary language |  |
| Prayer Times | adhan_dart | Astronomical prayer time calculation | [DECIDED in v1.1] Based on Batoul Apps Adhan library; supports Karachi method + Hanafi. More recently published than the "adhan" package. |
| Hijri Calendar | hijri_calendar (or hijri) | Offline Hijri date conversion and display | [NEW in v1.1] Needed for FR-1.6/FR-1.6a. Prayer time packages do not include Hijri conversion. |
| Database | drift | Type-safe SQLite ORM with reactive queries | Generates code via build_runner; supports migrations |
| Database (build) | drift_dev | Code generation for drift | Dev dependency only |
| SQLite Engine | sqlite3_flutter_libs | Bundled SQLite for all platforms | Required by drift |
| State Mgmt | flutter_riverpod (or provider) | Reactive state management | Riverpod preferred for streams (countdown timers); Provider acceptable for MVP |
| Notifications | flutter_local_notifications | Local notification scheduling | Handles Android channels, iOS categories |
| Background | workmanager | Best-effort periodic background task | [REFINED in v1.1] |
| Qibla | flutter_qiblah | Compass + Qibla direction | Requires device magnetometer; does NOT work on iOS simulator |
| Location | geolocator | GPS coordinates for auto-detection | Used for initial coordinate setup and Qibla |
| Timezone | timezone | Timezone-aware DateTime operations | Required for correct notification scheduling |
| JSON | dart:convert | JSON serialization for backup/export | Built-in |
| Home Widget | home_widget | Android/iOS home screen widget | Phase 4; requires native platform widget code |
| Haptics | flutter/services | HapticFeedback for tasbih counter | Built-in |
| HTTP (optional) | http or dio | AlAdhan API calls (manual verification only) | Only used if user triggers API verification |

<br>

# 10. KNOWN RISKS, GOTCHAS & VALIDATION CHECKLIST

## 10.1 Known Risks

| Risk | Impact | Likelihood | Mitigation |
| --- | --- | --- | --- |
| Android manufacturer battery optimization kills background tasks (Xiaomi/MIUI, Oppo/ColorOS, Samsung) | Missed prayer notifications | HIGH in Pakistan (most phones are Xiaomi/Samsung) | Show in-app guide linking to dontkillmyapp.com; use workmanager with OS-level backing; primary rescheduling via app lifecycle events |
| adhan_dart calculation differs from local mosque's "standard" timetable by 1–2 minutes | User confusion | MEDIUM | Clearly label computed vs mosque Jamaat times; allow per-prayer ± minute adjustments |
| iOS 64 notification limit silently drops older notifications | Some prayers get no notification | LOW (48-hour window keeps count at ~35) | Monitor scheduled count via getScheduledCount(); never exceed 50; math holds only for single notification mosque |
| Compass/magnetometer inaccurate inside buildings | Wrong Qibla direction shown | HIGH (concrete buildings, metal nearby) | Always show numeric bearing alongside compass; show accuracy warning; calibration prompt |
| drift code generation breaks on Flutter/Dart version updates | Build failures | MEDIUM | Pin dependency versions in pubspec.yaml; test builds before upgrading Flutter SDK |
| AlAdhan API changes or goes down | Verification feature breaks | LOW | This is optional and manual-only; core app is offline-first |
| User enters conflicting timing rules (overlapping date ranges) | Unpredictable Jamaat times | MEDIUM | Validate for overlapping ranges on save; show warning; use priority field; deterministic tie-break |
| Multi-mosque notification ambiguity [NEW in v1.1] | Notification counts can exceed platform limits if Jamaat alerts are scheduled for more than one mosque | MEDIUM | Explicitly support one notification mosque in v1; compute notification-count assertions against that scope |
| iOS custom Azan sound exceeds local-notification limit [NEW in v1.1] | System falls back to default notification sound | MEDIUM | Ship a short iOS-safe alert clip (under 30s); treat full-length Azan playback as separate in-app behavior |
| Offline Hijri conversion differs from local moon sighting [NEW in v1.1] | Ramadan mode / Hijri date may appear off by one day | MEDIUM | Use a documented conversion source; allow manual Hijri date offset and Ramadan mode override |
| iOS widget refresh cadence is OS-budgeted and timeline-based [NEW in v1.1] | Home-screen countdown may not stay "live" | HIGH on iOS | Show next prayer time reliably; avoid promising real-time updates; use coarse timeline entries |

## 10.2 Validation Checklist

[REPLACED in v1.1: split into three actionable buckets]

### A. Design / Code Review (review before or during implementation)

☐ REVIEW: Offset-based Jamaat rules use the final adjusted computed prayer start, while fixed and date-range-fixed rules remain anchored to explicit wall-clock times.

☐ REVIEW: Date-range rule resolution is inclusive, handles year-wrapping correctly, rejects overlapping ranges on save, and defines a deterministic tie-break order when priorities are equal.

☐ REVIEW: No-rule behavior is explicit: when no timing rule matches a mosque-prayer-date combination, the resolver returns a computed fallback result without crashing.

☐ REVIEW: Jamaat notifications and pre-Jamaat reminders are sourced from one notification mosque only in v1.

☐ REVIEW: Jummah behavior is explicitly modeled: Jummah replaces Dhuhr in Friday UI and prayer log; monthly timetable shows both Dhuhr times (all days) and Jummah row (Fridays only).

☐ REVIEW: Notification scheduling is idempotent and race-safe: uses deterministic notification IDs based on (mosqueId, localDate, prayer, notificationKind), avoids cancelAll() as the default strategy, prevents duplicate scheduling if foreground and background refresh run close together.

☐ REVIEW: API verification compares unadjusted engine output to unadjusted API output so user manual offsets do not create false discrepancy warnings.

### B. Unit / Integration Tests (write during implementation)

☐ TEST: Selected prayer engine output (Karachi method, Hanafi) matches AlAdhan reference values for Khanewal on March 21, June 21, September 22, and December 21 within ±1 minute tolerance.

☐ TEST: Notification count stays within the chosen cap for every 48-hour window under the v1 single-notification-mosque scope, including Ramadan extras and a Friday window.

☐ TEST: Qibla calculation for Khanewal (30.3017°N, 71.9321°E) to Kaaba (21.4225°N, 39.8262°E) resolves to approximately 260.5° true bearing.

☐ TEST: Drift migrations succeed from at least one prior seeded schema version and preserve user data.

☐ TEST: JSON backup/import round-trips all entities and preserves Unicode / special characters in notes.

☐ TEST: Prayer-log uniqueness (date, prayer) and ibadah-completion uniqueness (task_id, date, prayer_instance) prevent duplicate rows for the same logical event.

☐ TEST: Date-range year-wrapping: a rule with range_start="11-01" and range_end="02-28" correctly matches dates in November, December, January, and February.

### C. Physical Device / Emulator Validation (test on real hardware)

☐ DEVICE TEST: Android 14 exact-alarm denial flow works end-to-end: detect denial, inform the user, deep-link to settings, detect grant, reschedule.

☐ DEVICE TEST: Workmanager-based refresh behavior is validated on at least one Xiaomi/MIUI or HyperOS device and one Samsung device.

☐ DEVICE TEST: RECEIVE_BOOT_COMPLETED triggers notification rescheduling after device reboot on Android.

☐ DEVICE TEST: Tasbih haptic feedback is validated on real Android and iOS hardware.

☐ DEVICE TEST: Qibla compass behavior is validated on real devices (flutter_qiblah does not work on iOS simulator), including low-accuracy calibration prompts.

☐ DEVICE TEST: iOS notification behavior remains within pending-notification limits and produces the expected sound fallback behavior for the chosen audio assets (under 30 seconds).

☐ DEVICE TEST: iOS Azan audio clip plays correctly as notification sound; full-length Azan plays correctly as in-app audio.

☐ DEVICE TEST: Home screen widget updates correctly on both Android (AppWidgetProvider) and iOS (WidgetKit timeline-based).

<br>

# A. APPENDIX A: REFERENCE DATA

## A.1 Khanewal Coordinates

Latitude: 30.3017°N

Longitude: 71.9321°E

Timezone: Asia/Karachi (UTC+5, no DST)

## A.2 AlAdhan Calculation Methods (method parameter)

| ID | Name | Fajr Angle | Isha Angle | Notes |
| --- | --- | --- | --- | --- |
| 1 | University of Islamic Sciences, Karachi | 18° | 18° | RECOMMENDED for Pakistan |
| 2 | Islamic Society of North America (ISNA) | 15° | 15° |  |
| 3 | Muslim World League (MWL) | 18° | 17° |  |
| 4 | Umm al-Qura, Makkah | 18.5° | 90 min after Maghrib |  |
| 5 | Egyptian General Authority | 19.5° | 17.5° |  |

## A.3 Asr Juristic Schools

| ID | Name | Shadow Ratio | Notes |
| --- | --- | --- | --- |
| 0 | Shafi/Maliki/Hanbali | 1 | Earlier Asr time |
| 1 | Hanafi | 2 | Later Asr time — RECOMMENDED for Pakistan |

## A.4 Sample AlAdhan Response for Khanewal

Captured 22 March 2026, Method 1 (Karachi), School 1 (Hanafi):

| Prayer | Time |
| --- | --- |
| Fajr | 04:54 |
| Sunrise | 06:14 |
| Dhuhr | 12:19 |
| Asr | 15:46 |
| Maghrib | 18:25 |
| Isha | 19:45 |
| Imsak | 04:44 |
| Midnight | 00:19 |

Note: This is a sample response captured on 22 March 2026. Archive the raw response if preserving as test fixture.

## A.5 Qibla Bearing Reference

[CORRECTED in v1.1]

From Khanewal (30.3017°N, 71.9321°E) to Kaaba (21.4225°N, 39.8262°E):

Great-circle initial bearing: approximately 260.5° true bearing (roughly west, slightly south of due west).

Corrected from v1.0's "257–260° (roughly WSW)" estimate.

<br>

# B. APPENDIX B: KHANEWAL MOSQUE EXAMPLE DATA

For initial testing and seeding. These are example entries — the developer should verify and update with actual mosque data.

## B.1 Mosque 1: [Your Primary Mosque]

Timing rules (example pattern reflecting how many Khanewal mosques operate — Maghrib tracks sunset closely via offset mode, but Isha and Dhuhr shift in seasonal blocks):

| Prayer | Mode | Configuration |
| --- | --- | --- |
| Fajr | Offset | +10 minutes after computed Fajr |
| Dhuhr | Date-Range Fixed | 13:00 (Oct–Mar), 13:30 (Apr–Sep) |
| Asr | Offset | +15 minutes after computed Asr |
| Maghrib | Offset | +5 minutes after computed Maghrib |
| Isha | Date-Range Fixed | 20:30 (May–Aug), 20:00 (Sep–Oct), 19:30 (Nov–Feb), 19:00 (Mar–Apr) |
| Jummah | Fixed | 13:30 |

<br>

# C. APPENDIX C: CHANGELOG

[NEW in v1.1]

## v1.1 (March 22, 2026) — Post-Review Patches

Changes from v1.0 based on validation review:

1. Softened MAWAQIT claim from "verified via API" to point-in-time observation (Section 1.2)

2. Added notification mosque concept: one mosque for Jamaat notifications, same as primary (FR-2.6a)

3. Added Jummah model decision: Jummah replaces Dhuhr on Fridays in UI and prayer log (FR-2.5a)

4. Added manual adjustment propagation rule (FR-1.7a)

5. Added offline Hijri conversion requirement with moon-sighting override (FR-1.6a)

6. Added Ramadan mode user-override requirement (FR-3.10a)

7. Revised background scheduling: multi-trigger approach instead of "midnight wakeup" (FR-3.5, Section 5.2)

8. Added iOS notification authorization flow (FR-3.6a)

9. Added iOS 30-second sound limit for Azan notifications (FR-3.9a)

10. Added exact-alarm revocation detection (FR-3.7a)

11. Refined AlAdhan API verification as manual/user-initiated only (FR-5.9)

12. Added RECEIVE_BOOT_COMPLETED to permissions and roadmap (NFR-6, Phase 2)

13. Made widget requirement realistic for iOS WidgetKit (FR-5.7a)

14. Resolved adhan package ambiguity: chose adhan_dart (Section 9)

15. Added hijri_calendar package to tech stack (Section 9)

16. Corrected Qibla bearing from "257–260° WSW" to "260.5°" (Appendix A.5)

17. Added unique constraints on ibadah_completions and prayer_log (Section 3.4, 3.5)

18. Added structured resolver result requirement (Section 3.7)

19. Added deterministic notification ID scheme (Section 4.2)

20. Added notification count analysis with worst-case math (Section 5.5)

21. Replaced Section 10.2 with three-bucket validation checklist (Design Review / Unit Tests / Device Tests)

22. Added 4 new risk rows to Section 10.1 (multi-mosque notifications, iOS sound limit, Hijri conversion, iOS widget refresh)

23. Refined AlAdhan rate limit wording from "no strict rate limits" to "approximate per-IP rate limit" (Section 4.1)

## v1.0 (March 22, 2026) — Initial Release

Original SRS compiled from research across ChatGPT, Claude (Sonnet 4.6), and Gemini.
