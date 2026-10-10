import 'dart:convert';
import 'dart:typed_data';
import 'package:googleapis/drive/v3.dart' as drive;
import '../../data/backup/google_drive_backup_provider.dart';
import '../../domain/backup/backup_models.dart';

BackupSnapshot removeUserFromBackup(BackupSnapshot snapshot, String userId) {
  final ids = {userId, if (snapshot.isLegacy) 'local_user'};
  final tables = <String, List<Map<String, Object?>>>{};
  for (final entry in snapshot.tables.entries) {
    tables[entry.key] = entry.value.where((row) => entry.key == 'users'
        ? !ids.contains(row['id'])
        : !['transactions', 'category_mappings', 'category_history'].contains(entry.key) || !ids.contains(row['user_id']))
      .map((row) => Map<String, Object?>.from(row)).toList();
  }
  final retained = <Object?>{
    for (final row in tables['transactions'] ?? <Map<String, Object?>>[]) row['category_id'],
    for (final row in tables['category_mappings'] ?? <Map<String, Object?>>[]) row['category_id'],
    for (final row in tables['category_history'] ?? <Map<String, Object?>>[]) ...[row['new_category_id'], row['previous_category_id']],
  };
  final removed = <Object?>{
    for (final row in snapshot.tables['transactions'] ?? <Map<String, Object?>>[]) if (ids.contains(row['user_id'])) row['category_id'],
    for (final row in snapshot.tables['category_mappings'] ?? <Map<String, Object?>>[]) if (ids.contains(row['user_id'])) row['category_id'],
    for (final row in snapshot.tables['category_history'] ?? <Map<String, Object?>>[]) if (ids.contains(row['user_id'])) ...[row['new_category_id'], row['previous_category_id']],
  };
  tables['categories'] = (tables['categories'] ?? <Map<String, Object?>>[]).where((row) => row['is_system'] == 1 || !removed.contains(row['id']) || retained.contains(row['id'])).toList();
  // Global preferences contain no user data; remove automatic re-upload config.
  tables['app_settings'] = [];
  return BackupSnapshot(formatVersion: snapshot.formatVersion, createdAt: DateTime.now(), tables: tables);
}

class DriveDataDeletion {
  DriveDataDeletion(this.api);
  final drive.DriveApi api;
  Future<void> deleteUser(String userId) async {
    // Enumerate before changing files so pagination cannot skip duplicates.
    final ids = <String>[];
    String? token;
    do {
      final result = await api.files.list(q: "name = '${GoogleDriveBackupProvider.fileName}' and 'appDataFolder' in parents and trashed = false",
        spaces: 'appDataFolder', pageToken: token, $fields: 'files(id),nextPageToken');
      ids.addAll((result.files ?? <drive.File>[]).map((file) => file.id).whereType<String>());
      token = result.nextPageToken;
    } while (token != null);
    for (final id in ids) {
      final media = await api.files.get(id, downloadOptions: drive.DownloadOptions.fullMedia);
      if (media is! drive.Media) throw StateError('Backup tidak dapat dibaca.');
      final bytes = <int>[];
      await for (final chunk in media.stream) { bytes.addAll(chunk); }
      final clean = removeUserFromBackup(BackupSnapshot.decode(utf8.decode(bytes)), userId);
      if (clean.tables['users']?.isNotEmpty == true) {
        final content = Uint8List.fromList(utf8.encode(clean.encode()));
        await api.files.update(drive.File()..mimeType = 'application/json', id,
          uploadMedia: drive.Media(Stream<List<int>>.value(content), content.length));
      } else {
        await api.files.delete(id);
      }
    }
  }
}
