import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:salahsync/data/services/backup_file_transfer_service.dart';

void main() {
  late Directory tempDirectory;

  setUp(() async {
    tempDirectory = await Directory.systemTemp.createTemp('salahsync-backup-');
  });

  tearDown(() async {
    if (await tempDirectory.exists()) {
      await tempDirectory.delete(recursive: true);
    }
  });

  test('stageBackupFile writes a timestamped plaintext backup file', () async {
    final service = BackupFileTransferService(
      tempDirectoryProvider: () async => tempDirectory,
      now: () => DateTime.utc(2026, 3, 22, 12, 34, 56),
    );

    final staged = await service.stageBackupFile(
      '{"backupSchemaVersion":1}',
      encrypted: false,
    );

    expect(staged.encrypted, isFalse);
    expect(staged.fileName, 'salahsync-backup-20260322-123456.json');
    expect(await File(staged.path).readAsString(), '{"backupSchemaVersion":1}');
  });

  test('stageBackupFile marks protected exports in the file name', () async {
    final service = BackupFileTransferService(
      tempDirectoryProvider: () async => tempDirectory,
      now: () => DateTime.utc(2026, 3, 22, 12, 34, 56),
    );

    final staged = await service.stageBackupFile(
      '{"format":"encrypted"}',
      encrypted: true,
    );

    expect(staged.encrypted, isTrue);
    expect(staged.fileName, 'salahsync-backup-20260322-123456-protected.json');
  });

  test('readBackupFile reads a previously staged file', () async {
    final file = File(
      '${tempDirectory.path}${Platform.pathSeparator}import.json',
    );
    await file.writeAsString('{"backupSchemaVersion":1}', flush: true);
    final service = BackupFileTransferService(
      tempDirectoryProvider: () async => tempDirectory,
    );

    final json = await service.readBackupFile(file.path);

    expect(json, '{"backupSchemaVersion":1}');
  });
}
