import 'package:sqflite/sqflite.dart';

import '../../data/local/finchat_database.dart';

class BackupPreferenceService {
  BackupPreferenceService(this.database);
  final FinChatDatabase database;
  static const automaticBackupKey = 'backup.automatic_enabled';

  Future<bool> isAutomaticBackupEnabled() async {
    final db = await database.database;
    final rows = await db.query('app_settings', where: 'key = ?', whereArgs: [automaticBackupKey], limit: 1);
    return rows.isNotEmpty && rows.first['value'] == 'true';
  }

  Future<void> setAutomaticBackupEnabled(bool enabled) async {
    final db = await database.database;
    await db.insert('app_settings', {
      'key': automaticBackupKey,
      'value': enabled ? 'true' : 'false',
      'updated_at': DateTime.now().millisecondsSinceEpoch,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }
}
