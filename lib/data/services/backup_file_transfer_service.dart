import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class BackupFileTransferService {
  BackupFileTransferService({
    Future<Directory> Function()? tempDirectoryProvider,
    DateTime Function()? now,
  }) : _tempDirectoryProvider = tempDirectoryProvider ?? getTemporaryDirectory,
       _now = now ?? DateTime.now;

  final Future<Directory> Function() _tempDirectoryProvider;
  final DateTime Function() _now;

  Future<StagedBackupFile> stageBackupFile(
    String json, {
    required bool encrypted,
  }) async {
    final tempDirectory = await _tempDirectoryProvider();
    final timestamp = _formatTimestamp(_now().toUtc());
    final fileName = encrypted
        ? 'salahsync-backup-$timestamp-protected.json'
        : 'salahsync-backup-$timestamp.json';
    final file = File(p.join(tempDirectory.path, fileName));
    await file.writeAsString(json, flush: true);
    return StagedBackupFile(
      path: file.path,
      fileName: fileName,
      encrypted: encrypted,
    );
  }

  Future<String> readBackupFile(String path) async {
    return File(path).readAsString();
  }

  String _formatTimestamp(DateTime value) {
    final year = value.year.toString().padLeft(4, '0');
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');
    final second = value.second.toString().padLeft(2, '0');
    return '$year$month$day-$hour$minute$second';
  }
}

class StagedBackupFile {
  const StagedBackupFile({
    required this.path,
    required this.fileName,
    required this.encrypted,
  });

  final String path;
  final String fileName;
  final bool encrypted;
}
