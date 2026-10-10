import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:finchat/data/local/finchat_database.dart';
import 'package:finchat/data/repositories/sqlite_category_repository.dart';
import 'package:finchat/data/repositories/sqlite_transaction_repository.dart';
import 'package:finchat/data/update/github_release_update_provider.dart';
import 'package:finchat/domain/entities/transaction_entity.dart';
import 'package:finchat/domain/entities/category_entity.dart';

void main() {
  sqfliteFfiInit();
  test('release comparison detects build-only upgrades and preserves historical tags', () {
    expect(
      GitHubReleaseUpdateProvider.isNewerVersion('v0.3.4+20', '0.3.4+19'),
      isTrue,
    );
    expect(
      GitHubReleaseUpdateProvider.isNewerVersion('v0.3.4+19', '0.3.4+20'),
      isFalse,
    );
    expect(
      GitHubReleaseUpdateProvider.isNewerVersion('v0.3.4', '0.3.4+19'),
      isFalse,
    );
    expect(
      GitHubReleaseUpdateProvider.isNewerVersion('v0.3.5', '0.3.4+19'),
      isTrue,
    );
    expect(
      GitHubReleaseUpdateProvider.isNewerVersion('v0.3.4+19', '0.3.4+19'),
      isFalse,
    );
  });
  test('release comparison rejects malformed or ambiguous versions', () {
    expect(
      () => GitHubReleaseUpdateProvider.isNewerVersion(
        '0.3.4garbage',
        '0.3.4+19',
      ),
      throwsFormatException,
    );
  });
  test(
    'initial categories and repaired legacy categories use identical defaults',
    () async {
      final database = FinChatDatabase(
        factory: databaseFactoryFfi,
        databasePath: ':memory:',
      );
      addTearDown(database.close);
      final repository = SqliteCategoryRepository(database);
      final before = await repository.getById('makanan');
      final db = await database.database;
      expect(
        (await db.query(
          'categories',
          where: 'id = ?',
          whereArgs: ['makanan'],
        )).single['name'],
        systemCategoryDefaults['makanan']!.$1,
      );
      await db.delete('categories', where: 'id = ?', whereArgs: ['makanan']);
      final after = await repository.getById('makanan');
      expect(after!.name, before!.name);
      expect(after.type, before.type);
    },
  );
  test('editing a restored transaction retains history foreign keys', () async {
    final database = FinChatDatabase(
      factory: databaseFactoryFfi,
      databasePath: ':memory:',
    );
    addTearDown(database.close);
    await database.ensureUser(userId: 'u');
    final repository = SqliteTransactionRepository(database);
    final at = DateTime(2026, 10, 10);
    TransactionEntity transaction(double amount) => TransactionEntity(
      id: 'tx',
      userId: 'u',
      type: TransactionType.expense,
      amount: amount,
      description: 'Nasi',
      categoryId: 'makanan',
      transactionDate: at,
      inputSource: InputSource.text,
      processedBy: ProcessedBy.manual,
      confidence: 1,
      createdAt: at,
      updatedAt: at,
    );
    await repository.save(transaction(10000));
    final db = await database.database;
    await db.insert('category_history', {
      'id': 'history',
      'user_id': 'u',
      'transaction_id': 'tx',
      'keyword': 'nasi',
      'previous_category_id': null,
      'new_category_id': 'makanan',
      'source': 'user_correction',
      'created_at': at.millisecondsSinceEpoch,
    });
    await repository.update(transaction(12000));
    expect((await repository.getById('tx'))!.amount, 12000);
    expect(await db.query('category_history'), hasLength(1));
    expect(await db.rawQuery('PRAGMA foreign_key_check'), isEmpty);
  });
}
