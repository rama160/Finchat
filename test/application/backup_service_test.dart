import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:finchat/application/backup/backup_service.dart';
import 'package:finchat/data/local/finchat_database.dart';
import 'package:finchat/domain/backup/backup_models.dart';

void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  Future<FinChatDatabase> openDatabase() async {
    final database = FinChatDatabase(
      factory: databaseFactoryFfi,
      databasePath: ':memory:',
    );
    await database.database;
    return database;
  }

  test('exports all FinChat tables into a versioned backup', () async {
    final database = await openDatabase();
    addTearDown(database.close);
    final service = BackupService(database);

    final snapshot = await service.createSnapshot();

    expect(snapshot.formatVersion, BackupSnapshot.currentFormatVersion);
    expect(snapshot.tables.keys, containsAll([
      'users',
      'categories',
      'transactions',
      'category_mappings',
      'category_history',
      'app_settings',
    ]));
    expect(snapshot.tables['categories'], isNotEmpty);
  });

  test('backup JSON can be decoded without losing table rows', () async {
    final database = await openDatabase();
    addTearDown(database.close);
    final service = BackupService(database);

    final json = await service.exportJson();
    final decoded = BackupSnapshot.decode(json);

    expect(decoded.tables['categories']!.length, 9);
    expect(decoded.tables['users'], isEmpty);
  });

  test('restore replaces local data from a backup snapshot', () async {
    final database = await openDatabase();
    addTearDown(database.close);
    final db = await database.database;
    final service = BackupService(database);

    final now = DateTime.now().millisecondsSinceEpoch;
    await db.insert('users', {
      'id': 'user-1',
      'email': 'user@example.com',
      'display_name': 'User',
      'created_at': now,
      'updated_at': now,
    });

    final backup = await service.createSnapshot();
    await db.delete('users');
    expect((await db.query('users')), isEmpty);

    await service.restoreSnapshot(backup);

    final rows = await db.query('users');
    expect(rows, hasLength(1));
    expect(rows.single['id'], 'user-1');
  });


  test('restores the original FinChat backup format and maps it to the current user', () async {
    final database = await openDatabase();
    addTearDown(database.close);
    final service = BackupService(
      database,
      restoreUserId: 'user@example.com',
      restoreUserEmail: 'user@example.com',
    );

    const legacyJson = '''{
      "format": "finchat_backup",
      "version": 1,
      "created_at": "2026-10-03T06:15:24.836554",
      "transactions": [
        {
          "id": 246,
          "chat_id": "local_user",
          "transaction_date": "2026-10-02",
          "transaction_time": "18:07:56",
          "type": "expense",
          "category": "Lainnya",
          "description": "jajan",
          "amount": 50000.0,
          "payment_method": "Cash",
          "merchant": "",
          "notes": "",
          "source": "text",
          "is_synced": 1
        }
      ],
      "deleted_transaction_ids": [12]
    }''';

    await service.restoreJson(legacyJson);
    final db = await database.database;
    final users = await db.query('users');
    final transactions = await db.query('transactions');

    expect(users, hasLength(1));
    expect(users.single['id'], 'user@example.com');
    expect(transactions, hasLength(1));
    expect(transactions.single['user_id'], 'user@example.com');
    expect(transactions.single['description'], 'jajan');
    expect(transactions.single['category_id'], 'lainnya');
  });

  test('cloud backup requires an explicitly configured provider', () async {
    final database = await openDatabase();
    addTearDown(database.close);
    final service = BackupService(database);

    expect(service.backupToCloud, throwsStateError);
    expect(service.restoreFromCloud, throwsStateError);
  });

  test('cloud provider can upload and restore a snapshot', () async {
    final database = await openDatabase();
    addTearDown(database.close);
    final provider = _FakeCloudBackupProvider();
    final service = BackupService(database, cloudProvider: provider);

    await service.backupToCloud();
    expect(provider.uploaded, isNotNull);

    final restored = await service.restoreFromCloud();
    expect(restored, isTrue);
  });
}

class _FakeCloudBackupProvider implements CloudBackupProvider {
  BackupSnapshot? uploaded;

  @override
  Future<void> upload(BackupSnapshot snapshot) async {
    uploaded = snapshot;
  }

  @override
  Future<BackupSnapshot?> download() async => uploaded;
}
