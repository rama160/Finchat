import 'package:finchat/application/backup/automatic_backup_service.dart';
import 'package:finchat/data/local/finchat_database.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUpAll(sqfliteFfiInit);

  test('does not contact Drive when automatic backup preference is disabled', () async {
    final database = FinChatDatabase(
      factory: databaseFactoryFfi,
      databasePath: inMemoryDatabasePath,
    );
    addTearDown(database.close);

    final service = AutomaticBackupService(database);
    expect(await service.runIfEnabled(), isFalse);
  });
}
