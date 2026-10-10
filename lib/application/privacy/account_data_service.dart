import '../../data/local/finchat_database.dart';
import '../backup/backup_preference_service.dart';

/// Explicit deletion only. Never called from logout or normal navigation.
class AccountDataService {
  AccountDataService(this.database);
  final FinChatDatabase database;
  Future<void> deleteLocalUser(String userId) async {
    if (userId.trim().isEmpty) throw ArgumentError('Akun belum tersedia.');
    final db = await database.database;
    await db.transaction((txn) async {
      final owned = await txn.rawQuery('SELECT category_id AS id FROM transactions WHERE user_id = ? UNION SELECT category_id AS id FROM category_mappings WHERE user_id = ? UNION SELECT new_category_id AS id FROM category_history WHERE user_id = ? UNION SELECT previous_category_id AS id FROM category_history WHERE user_id = ?', [userId, userId, userId, userId]);
      for (final table in ['category_history', 'category_mappings', 'transactions']) {
        await txn.delete(table, where: 'user_id = ?', whereArgs: [userId]);
      }
      for (final row in owned) {
        await txn.rawDelete('DELETE FROM categories WHERE id = ? AND is_system = 0 AND NOT EXISTS (SELECT 1 FROM transactions WHERE category_id = categories.id) AND NOT EXISTS (SELECT 1 FROM category_mappings WHERE category_id = categories.id) AND NOT EXISTS (SELECT 1 FROM category_history WHERE new_category_id = categories.id OR previous_category_id = categories.id)', [row['id']]);
      }
      await txn.delete('users', where: 'id = ?', whereArgs: [userId]);
      // Prevent deleted data being uploaded again by this device.
      await txn.update('app_settings', {'value': 'false', 'updated_at': DateTime.now().millisecondsSinceEpoch},
        where: 'key = ?', whereArgs: [BackupPreferenceService.automaticBackupKey]);
    });
  }
}
