import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:finchat/application/backup/backup_service.dart';
import 'package:finchat/data/local/finchat_database.dart';
import 'package:finchat/domain/backup/backup_models.dart';

class _Cloud implements CloudBackupProvider {
  _Cloud(this.onUpload);
  final Future<void> Function() onUpload;
  @override
  Future<void> upload(BackupSnapshot snapshot) => onUpload();
  @override
  Future<BackupSnapshot?> download() async => null;
}

void main() {
  setUpAll(sqfliteFfiInit);
  test('only acknowledges successful uploaded versions; failed or changed rows stay local', () async {
    final database = FinChatDatabase(factory: databaseFactoryFfi, databasePath: inMemoryDatabasePath);
    addTearDown(database.close);
    await database.ensureUser(userId: 'u');
    final db = await database.database;
    await db.insert('transactions', {'id': 't', 'user_id': 'u', 'type': 'expense', 'amount': 10000, 'description': 'nasi', 'category_id': 'makanan', 'transaction_date': 1, 'input_source': 'text', 'processed_by': 'localParser', 'confidence': 1.0, 'created_at': 1, 'updated_at': 1, 'sync_status': 'local'});
    Future<String> status() async => (await db.query('transactions')).single['sync_status'] as String;
    await expectLater(BackupService(database, cloudProvider: _Cloud(() async => throw StateError('offline'))).backupToCloud(), throwsStateError);
    expect(await status(), 'local');
    await BackupService(database, cloudProvider: _Cloud(() async {
      await db.update('transactions', {'amount': 20000});
    })).backupToCloud();
    expect(await status(), 'local');
    await BackupService(database, cloudProvider: _Cloud(() async {})).backupToCloud();
    expect(await status(), 'backed_up');
  });
}
