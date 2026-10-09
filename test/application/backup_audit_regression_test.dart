import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:finchat/application/backup/backup_service.dart';
import 'package:finchat/data/local/finchat_database.dart';
import 'package:finchat/domain/backup/backup_models.dart';

void main() {
  setUpAll(sqfliteFfiInit);
  late FinChatDatabase database;
  late BackupService service;
  setUp(() async {
    database = FinChatDatabase(
      factory: databaseFactoryFfi,
      databasePath: inMemoryDatabasePath,
    );
    service = BackupService(database);
    await database.ensureUser(userId: 'u');
    final db = await database.database;
    await db.insert('transactions', {
      'id': 't',
      'user_id': 'u',
      'type': 'expense',
      'amount': 1000,
      'description': 'Kopi café ☕',
      'category_id': 'makanan',
      'transaction_date': 1,
      'transaction_time': null,
      'input_source': 'text',
      'processed_by': 'localParser',
      'confidence': 1.0,
      'created_at': 1,
      'updated_at': 1,
      'deleted_at': null,
      'sync_status': 'local',
    });
  });
  tearDown(() => database.close());
  test('UTF-8 bytes restore names, accents and emoji intact', () async {
    final bytes = await service.exportBytes();
    expect(utf8.decode(bytes), contains('café ☕'));
    await service.restoreBytes(bytes);
    expect(
      (await (await database.database).query('transactions'))
          .single['description'],
      'Kopi café ☕',
    );
  });
  for (final scenario in ['duplicate', 'enum', 'reference', 'timestamp']) {
    test('rejects $scenario before replacing original data', () async {
      final snapshot = BackupSnapshot.decode(await service.exportJson());
      final rows = snapshot.tables['transactions']!;
      switch (scenario) {
        case 'duplicate':
          rows.add(Map<String, Object?>.from(rows.single));
        case 'enum':
          rows.single['input_source'] = 'unknown';
        case 'reference':
          rows.single['category_id'] = 'missing';
        case 'timestamp':
          rows.single['transaction_date'] = 'broken';
      }
      await expectLater(
        service.restoreSnapshot(snapshot),
        throwsA(isA<FormatException>()),
      );
      expect(
        (await (await database.database).query('transactions'))
            .single['description'],
        'Kopi café ☕',
      );
    });
  }
  test('transactional snapshot validates after a regular export', () async {
    final snapshot = await service.createSnapshot();
    expect(snapshot.validateForRestore, returnsNormally);
    expect(snapshot.tables['transactions'], hasLength(1));
  });
}
