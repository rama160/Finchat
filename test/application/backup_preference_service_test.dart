import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:finchat/application/backup/backup_preference_service.dart';
import 'package:finchat/data/local/finchat_database.dart';

void main() {
  sqfliteFfiInit();
  test('automatic backup preference persists in app_settings', () async {
    final database = FinChatDatabase(factory: databaseFactoryFfi, databasePath: inMemoryDatabasePath);
    addTearDown(database.close);
    final service = BackupPreferenceService(database);
    expect(await service.isAutomaticBackupEnabled(), isFalse);
    await service.setAutomaticBackupEnabled(true);
    expect(await service.isAutomaticBackupEnabled(), isTrue);
    await service.setAutomaticBackupEnabled(false);
    expect(await service.isAutomaticBackupEnabled(), isFalse);
  });
}
