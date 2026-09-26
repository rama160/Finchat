import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:googleapis/drive/v3.dart' as drive;

import '../../domain/backup/backup_models.dart';

class GoogleDriveBackupProvider implements CloudBackupProvider {
  GoogleDriveBackupProvider(this.driveApi);

  final drive.DriveApi driveApi;

  static const fileName = 'finchat_backup.json';
  static const _mimeType = 'application/json';

  @override
  Future<void> upload(BackupSnapshot snapshot) async {
    final bytes = Uint8List.fromList(utf8.encode(snapshot.encode()));
    final existing = await _findBackupFile();
    final metadata = drive.File()
      ..name = fileName
      ..mimeType = _mimeType
      ..parents = ['appDataFolder'];
    final media = drive.Media(
      Stream<List<int>>.value(bytes),
      bytes.length,
    );

    if (existing == null) {
      await driveApi.files.create(
        metadata,
        uploadMedia: media,
        $fields: 'id,name,modifiedTime',
      );
      return;
    }

    await driveApi.files.update(
      drive.File()
        ..name = fileName
        ..mimeType = _mimeType,
      existing,
      uploadMedia: media,
      $fields: 'id,name,modifiedTime',
    );
  }

  @override
  Future<BackupSnapshot?> download() async {
    final fileId = await _findBackupFile();
    if (fileId == null) return null;

    final response = await driveApi.files.get(
      fileId,
      downloadOptions: drive.DownloadOptions.fullMedia,
    );
    if (response is! drive.Media) {
      throw StateError('Google Drive mengembalikan metadata, bukan isi backup.');
    }

    final chunks = <int>[];
    await for (final chunk in response.stream) {
      chunks.addAll(chunk);
    }
    return BackupSnapshot.decode(utf8.decode(chunks));
  }

  Future<String?> _findBackupFile() async {
    final result = await driveApi.files.list(
      q: "name = '$fileName' and 'appDataFolder' in parents and trashed = false",
      spaces: 'appDataFolder',
      pageSize: 10,
      $fields: 'files(id,name,modifiedTime)',
    );
    final files = result.files ?? const <drive.File>[];
    return files.isEmpty ? null : files.first.id;
  }
}
