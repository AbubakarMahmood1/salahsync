import 'dart:convert';
import 'dart:isolate';

import 'package:crypto/crypto.dart';
import 'package:drift/drift.dart';

import '../../core/mosque/month_day.dart';
import '../../core/mosque/time_of_day_value.dart';
import '../../core/mosque/timing_rule.dart';
import '../../core/time/salah_prayer.dart';
import '../db/app_database.dart';

class BackupService {
  BackupService(this._db);

  final AppDatabase _db;

  Future<String> exportToJson({bool pretty = false}) async {
    final payload = await _buildPayload();
    return pretty
        ? const JsonEncoder.withIndent('  ').convert(payload)
        : jsonEncode(payload);
  }

  Future<BackupPreview> previewJsonAsync(String json) async {
    final payload = await Isolate.run(() => _decodeBackupPayload(json));
    return _buildPreview(payload);
  }

  BackupPreview previewJson(String json) {
    final payload = _decodeBackupPayload(json);
    return _buildPreview(payload);
  }

  BackupPreview _buildPreview(Map<String, dynamic> payload) {
    final backupSchemaVersion = _readInt(payload, 'backupSchemaVersion');
    if (backupSchemaVersion != kBackupSchemaVersion) {
      throw BackupFormatException(
        'Unsupported backup schema version $backupSchemaVersion.',
      );
    }

    final data = _readMap(payload, 'data');
    final integrity = _readBackupIntegrityInfo(payload);
    return BackupPreview(
      backupSchemaVersion: backupSchemaVersion,
      databaseSchemaVersion: _readInt(payload, 'databaseSchemaVersion'),
      exportedAt: _readString(payload, 'exportedAt'),
      integrity: integrity,
      summary: BackupSummary(
        appSettingsCount: _readList(data, 'appSettingsEntries').length,
        mosqueCount: _readList(data, 'mosques').length,
        timingRuleCount: _readList(data, 'timingRuleEntries').length,
        ibadahTaskCount: _readList(data, 'ibadahTaskEntries').length,
        ibadahCompletionCount: _readList(
          data,
          'ibadahCompletionEntries',
        ).length,
        prayerLogCount: _readList(data, 'prayerLogEntries').length,
      ),
    );
  }

  Future<ImportResult> importFromJson(String json) async {
    final payload = await Isolate.run(() => _decodeBackupPayload(json));
    final preview = _buildPreview(payload);
    final data = _readMap(payload, 'data');

    final appSettingsEntries = _readList(
      data,
      'appSettingsEntries',
    ).map(_mapValue).toList(growable: false);
    final mosques = _readList(
      data,
      'mosques',
    ).map(_mapValue).toList(growable: false);
    final timingRules = _readList(
      data,
      'timingRuleEntries',
    ).map(_mapValue).toList(growable: false);
    final ibadahTasks = _readList(
      data,
      'ibadahTaskEntries',
    ).map(_mapValue).toList(growable: false);
    final ibadahCompletions = _readList(
      data,
      'ibadahCompletionEntries',
    ).map(_mapValue).toList(growable: false);
    final prayerLogs = _readList(
      data,
      'prayerLogEntries',
    ).map(_mapValue).toList(growable: false);

    await _db.transaction(() async {
      await (_db.delete(_db.prayerLogEntries)).go();
      await (_db.delete(_db.ibadahCompletionEntries)).go();
      await (_db.delete(_db.ibadahTaskEntries)).go();
      await (_db.delete(_db.timingRuleEntries)).go();
      await (_db.delete(_db.mosques)).go();
      await (_db.delete(_db.appSettingsEntries)).go();

      for (final row in appSettingsEntries) {
        await _db
            .into(_db.appSettingsEntries)
            .insert(
              AppSettingsEntriesCompanion(
                key: Value(_readString(row, 'key')),
                value: Value(_readString(row, 'value')),
              ),
            );
      }

      for (final row in mosques) {
        await _db
            .into(_db.mosques)
            .insert(
              MosquesCompanion(
                id: Value(_readInt(row, 'id')),
                name: Value(_readString(row, 'name')),
                area: Value(_readNullableString(row, 'area')),
                latitude: Value(_readNullableDouble(row, 'latitude')),
                longitude: Value(_readNullableDouble(row, 'longitude')),
                isPrimary: Value(_readBool(row, 'isPrimary')),
                isActive: Value(_readBool(row, 'isActive')),
                notes: Value(_readNullableString(row, 'notes')),
                createdAt: Value(_readString(row, 'createdAt')),
                updatedAt: Value(_readString(row, 'updatedAt')),
              ),
            );
      }

      for (final row in timingRules) {
        await _db
            .into(_db.timingRuleEntries)
            .insert(
              TimingRuleEntriesCompanion(
                id: Value(_readInt(row, 'id')),
                mosqueId: Value(_readInt(row, 'mosqueId')),
                prayer: Value(
                  _readEnumValue(row, 'prayer', SalahPrayer.values),
                ),
                mode: Value(_readEnumValue(row, 'mode', TimingRuleMode.values)),
                offsetMinutes: Value(_readNullableInt(row, 'offsetMinutes')),
                fixedTime: Value(_readNullableTimeOfDayValue(row, 'fixedTime')),
                rangeStart: Value(_readNullableMonthDay(row, 'rangeStart')),
                rangeEnd: Value(_readNullableMonthDay(row, 'rangeEnd')),
                priority: Value(_readInt(row, 'priority')),
                createdAt: Value(_readString(row, 'createdAt')),
              ),
            );
      }

      for (final row in ibadahTasks) {
        await _db
            .into(_db.ibadahTaskEntries)
            .insert(
              IbadahTaskEntriesCompanion(
                id: Value(_readInt(row, 'id')),
                title: Value(_readString(row, 'title')),
                description: Value(_readNullableString(row, 'description')),
                prayerLink: Value(_readNullableString(row, 'prayerLink')),
                timing: Value(_readString(row, 'timing')),
                repeatType: Value(_readString(row, 'repeatType')),
                repeatDays: Value(_readNullableString(row, 'repeatDays')),
                countTarget: Value(_readNullableInt(row, 'countTarget')),
                isActive: Value(_readBool(row, 'isActive')),
                sortOrder: Value(_readInt(row, 'sortOrder')),
              ),
            );
      }

      for (final row in ibadahCompletions) {
        await _db
            .into(_db.ibadahCompletionEntries)
            .insert(
              IbadahCompletionEntriesCompanion(
                id: Value(_readInt(row, 'id')),
                taskId: Value(_readInt(row, 'taskId')),
                date: Value(_readString(row, 'date')),
                prayerInstance: Value(
                  _readNullableString(row, 'prayerInstance'),
                ),
                countDone: Value(_readInt(row, 'countDone')),
                completed: Value(_readBool(row, 'completed')),
                notes: Value(_readNullableString(row, 'notes')),
              ),
            );
      }

      for (final row in prayerLogs) {
        await _db
            .into(_db.prayerLogEntries)
            .insert(
              PrayerLogEntriesCompanion(
                id: Value(_readInt(row, 'id')),
                date: Value(_readString(row, 'date')),
                prayer: Value(_readString(row, 'prayer')),
                status: Value(_readString(row, 'status')),
                mosqueId: Value(_readNullableInt(row, 'mosqueId')),
                notes: Value(_readNullableString(row, 'notes')),
                loggedAt: Value(_readString(row, 'loggedAt')),
              ),
            );
      }
    });

    return ImportResult(
      backupSchemaVersion: preview.backupSchemaVersion,
      databaseSchemaVersion: preview.databaseSchemaVersion,
      importedAt: DateTime.now().toUtc().toIso8601String(),
      summary: preview.summary,
    );
  }

  Future<Map<String, dynamic>> _buildPayload() async {
    final appSettingsEntries = await _db.select(_db.appSettingsEntries).get();
    final mosques = await _db.select(_db.mosques).get();
    final timingRuleEntries = await _db.select(_db.timingRuleEntries).get();
    final ibadahTaskEntries = await _db.select(_db.ibadahTaskEntries).get();
    final ibadahCompletionEntries = await _db
        .select(_db.ibadahCompletionEntries)
        .get();
    final prayerLogEntries = await _db.select(_db.prayerLogEntries).get();

    final payload = <String, dynamic>{
      'backupSchemaVersion': kBackupSchemaVersion,
      'databaseSchemaVersion': _db.schemaVersion,
      'exportedAt': DateTime.now().toUtc().toIso8601String(),
      'data': {
        'appSettingsEntries': appSettingsEntries
            .map((row) => {'key': row.key, 'value': row.value})
            .toList(growable: false),
        'mosques': mosques
            .map(
              (row) => {
                'id': row.id,
                'name': row.name,
                'area': row.area,
                'latitude': row.latitude,
                'longitude': row.longitude,
                'isPrimary': row.isPrimary,
                'isActive': row.isActive,
                'notes': row.notes,
                'createdAt': row.createdAt,
                'updatedAt': row.updatedAt,
              },
            )
            .toList(growable: false),
        'timingRuleEntries': timingRuleEntries
            .map(
              (row) => {
                'id': row.id,
                'mosqueId': row.mosqueId,
                'prayer': row.prayer.name,
                'mode': row.mode.name,
                'offsetMinutes': row.offsetMinutes,
                'fixedTime': row.fixedTime?.toString(),
                'rangeStart': row.rangeStart?.toString(),
                'rangeEnd': row.rangeEnd?.toString(),
                'priority': row.priority,
                'createdAt': row.createdAt,
              },
            )
            .toList(growable: false),
        'ibadahTaskEntries': ibadahTaskEntries
            .map(
              (row) => {
                'id': row.id,
                'title': row.title,
                'description': row.description,
                'prayerLink': row.prayerLink,
                'timing': row.timing,
                'repeatType': row.repeatType,
                'repeatDays': row.repeatDays,
                'countTarget': row.countTarget,
                'isActive': row.isActive,
                'sortOrder': row.sortOrder,
              },
            )
            .toList(growable: false),
        'ibadahCompletionEntries': ibadahCompletionEntries
            .map(
              (row) => {
                'id': row.id,
                'taskId': row.taskId,
                'date': row.date,
                'prayerInstance': row.prayerInstance,
                'countDone': row.countDone,
                'completed': row.completed,
                'notes': row.notes,
              },
            )
            .toList(growable: false),
        'prayerLogEntries': prayerLogEntries
            .map(
              (row) => {
                'id': row.id,
                'date': row.date,
                'prayer': row.prayer,
                'status': row.status,
                'mosqueId': row.mosqueId,
                'notes': row.notes,
                'loggedAt': row.loggedAt,
              },
            )
            .toList(growable: false),
      },
    };

    payload['integrity'] = {
      'algorithm': kBackupIntegrityAlgorithm,
      'scope': kBackupIntegrityScope,
      'digest': _computeBackupDigest(payload),
    };
    return payload;
  }
}

class BackupPreview {
  const BackupPreview({
    required this.backupSchemaVersion,
    required this.databaseSchemaVersion,
    required this.exportedAt,
    required this.integrity,
    required this.summary,
  });

  final int backupSchemaVersion;
  final int databaseSchemaVersion;
  final String exportedAt;
  final BackupIntegrityInfo integrity;
  final BackupSummary summary;
}

class ImportResult {
  const ImportResult({
    required this.backupSchemaVersion,
    required this.databaseSchemaVersion,
    required this.importedAt,
    required this.summary,
  });

  final int backupSchemaVersion;
  final int databaseSchemaVersion;
  final String importedAt;
  final BackupSummary summary;
}

class BackupSummary {
  const BackupSummary({
    required this.appSettingsCount,
    required this.mosqueCount,
    required this.timingRuleCount,
    required this.ibadahTaskCount,
    required this.ibadahCompletionCount,
    required this.prayerLogCount,
  });

  final int appSettingsCount;
  final int mosqueCount;
  final int timingRuleCount;
  final int ibadahTaskCount;
  final int ibadahCompletionCount;
  final int prayerLogCount;
}

enum BackupIntegrityStatus { verified, unsignedLegacy }

class BackupIntegrityInfo {
  const BackupIntegrityInfo({
    required this.status,
    required this.algorithm,
    required this.digest,
  });

  final BackupIntegrityStatus status;
  final String? algorithm;
  final String? digest;

  bool get isVerified => status == BackupIntegrityStatus.verified;

  String get label {
    return switch (status) {
      BackupIntegrityStatus.verified => 'Checksum verified ($algorithm)',
      BackupIntegrityStatus.unsignedLegacy => 'Legacy backup (unsigned)',
    };
  }
}

class BackupFormatException implements Exception {
  BackupFormatException(this.message);

  final String message;

  @override
  String toString() => 'BackupFormatException: $message';
}

const kBackupSchemaVersion = 1;
const kMaxBackupCharacters = 2 * 1024 * 1024;
const kBackupIntegrityAlgorithm = 'sha256';
const kBackupIntegrityScope = 'full-payload-v1';

Map<String, dynamic> _decodeBackupPayload(String json) {
  final trimmed = json.trim();
  if (trimmed.isEmpty) {
    throw BackupFormatException('Backup JSON cannot be empty.');
  }
  if (trimmed.length > kMaxBackupCharacters) {
    throw BackupFormatException(
      'Backup JSON is too large for the current copy/paste flow. '
      'Keep it under ${kMaxBackupCharacters ~/ 1024} KB.',
    );
  }

  try {
    final decoded = jsonDecode(trimmed);
    if (decoded is! Map) {
      throw BackupFormatException('Backup JSON must be an object.');
    }
    return decoded.map((key, value) => MapEntry(key.toString(), value));
  } on FormatException catch (error) {
    throw BackupFormatException('Invalid JSON: ${error.message}');
  }
}

BackupIntegrityInfo _readBackupIntegrityInfo(Map<String, dynamic> payload) {
  final rawIntegrity = payload['integrity'];
  if (rawIntegrity == null) {
    return const BackupIntegrityInfo(
      status: BackupIntegrityStatus.unsignedLegacy,
      algorithm: null,
      digest: null,
    );
  }

  final integrity = _mapValue(rawIntegrity);
  final algorithm = _readString(integrity, 'algorithm');
  final scope = _readString(integrity, 'scope');
  final digest = _readString(integrity, 'digest');

  if (algorithm != kBackupIntegrityAlgorithm ||
      scope != kBackupIntegrityScope) {
    throw BackupFormatException(
      'Unsupported backup integrity metadata: $algorithm / $scope.',
    );
  }

  final actualDigest = _computeBackupDigest(payload);
  if (digest != actualDigest) {
    throw BackupFormatException(
      'Backup integrity check failed. The pasted JSON appears corrupted or modified.',
    );
  }

  return BackupIntegrityInfo(
    status: BackupIntegrityStatus.verified,
    algorithm: algorithm,
    digest: digest,
  );
}

String _computeBackupDigest(Map<String, dynamic> payload) {
  final digestPayload = <String, dynamic>{
    'backupSchemaVersion': payload['backupSchemaVersion'],
    'databaseSchemaVersion': payload['databaseSchemaVersion'],
    'exportedAt': payload['exportedAt'],
    'data': payload['data'],
  };
  final canonicalJson = _canonicalJsonEncode(digestPayload);
  return sha256.convert(utf8.encode(canonicalJson)).toString();
}

String _canonicalJsonEncode(Object? value) {
  if (value is Map) {
    final keys = value.keys.map((key) => key.toString()).toList()..sort();
    final entries = keys
        .map((key) {
          return '${jsonEncode(key)}:${_canonicalJsonEncode(value[key])}';
        })
        .join(',');
    return '{$entries}';
  }
  if (value is List) {
    return '[${value.map(_canonicalJsonEncode).join(',')}]';
  }
  return jsonEncode(value);
}

Map<String, dynamic> _mapValue(Object? value) {
  if (value is Map<String, dynamic>) {
    return value;
  }
  if (value is Map) {
    return value.map((key, entry) => MapEntry(key.toString(), entry));
  }
  throw BackupFormatException('Backup row must be a JSON object.');
}

Map<String, dynamic> _readMap(Map<String, dynamic> source, String key) {
  final value = source[key];
  if (value is Map<String, dynamic>) {
    return value;
  }
  if (value is Map) {
    return value.map((entryKey, entryValue) {
      return MapEntry(entryKey.toString(), entryValue);
    });
  }
  throw BackupFormatException('Expected "$key" to be an object.');
}

List<dynamic> _readList(Map<String, dynamic> source, String key) {
  final value = source[key];
  if (value is List<dynamic>) {
    return value;
  }
  throw BackupFormatException('Expected "$key" to be a list.');
}

String _readString(Map<String, dynamic> source, String key) {
  final value = source[key];
  if (value is String) {
    return value;
  }
  throw BackupFormatException('Expected "$key" to be a string.');
}

String? _readNullableString(Map<String, dynamic> source, String key) {
  final value = source[key];
  if (value == null) {
    return null;
  }
  if (value is String) {
    return value;
  }
  throw BackupFormatException('Expected "$key" to be a string or null.');
}

T _readEnumValue<T extends Enum>(
  Map<String, dynamic> source,
  String key,
  List<T> values,
) {
  final value = source[key];
  if (value is String && value.isNotEmpty) {
    for (final candidate in values) {
      if (candidate.name == value) {
        return candidate;
      }
    }
  }
  throw BackupFormatException('Expected "$key" to contain valid enum text.');
}

int _readInt(Map<String, dynamic> source, String key) {
  final value = source[key];
  if (value is int) {
    return value;
  }
  if (value is num) {
    return value.toInt();
  }
  throw BackupFormatException('Expected "$key" to be an integer.');
}

int? _readNullableInt(Map<String, dynamic> source, String key) {
  final value = source[key];
  if (value == null) {
    return null;
  }
  if (value is int) {
    return value;
  }
  if (value is num) {
    return value.toInt();
  }
  throw BackupFormatException('Expected "$key" to be an integer or null.');
}

double? _readNullableDouble(Map<String, dynamic> source, String key) {
  final value = source[key];
  if (value == null) {
    return null;
  }
  if (value is double) {
    return value;
  }
  if (value is num) {
    return value.toDouble();
  }
  throw BackupFormatException('Expected "$key" to be a number or null.');
}

bool _readBool(Map<String, dynamic> source, String key) {
  final value = source[key];
  if (value is bool) {
    return value;
  }
  throw BackupFormatException('Expected "$key" to be a boolean.');
}

TimeOfDayValue? _readNullableTimeOfDayValue(
  Map<String, dynamic> source,
  String key,
) {
  final value = _readNullableString(source, key);
  if (value == null) {
    return null;
  }

  try {
    return TimeOfDayValue.parse(value);
  } on FormatException catch (error) {
    throw BackupFormatException('Invalid "$key" value: ${error.message}');
  }
}

MonthDay? _readNullableMonthDay(Map<String, dynamic> source, String key) {
  final value = _readNullableString(source, key);
  if (value == null) {
    return null;
  }

  try {
    return MonthDay.parse(value);
  } on FormatException catch (error) {
    throw BackupFormatException('Invalid "$key" value: ${error.message}');
  }
}
