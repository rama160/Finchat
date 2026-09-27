import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:finchat/data/local/finchat_database.dart';
import 'package:finchat/data/repositories/sqlite_category_repository.dart';
import 'package:finchat/data/repositories/sqlite_transaction_repository.dart';
import 'package:finchat/domain/entities/transaction_entity.dart';
import 'package:finchat/domain/services/category_learning_service.dart';

void main() {
  setUpAll(sqfliteFfiInit);

  late FinChatDatabase database;
  late SqliteTransactionRepository transactions;
  late SqliteCategoryRepository categories;

  setUp(() {
    database = FinChatDatabase(
      factory: databaseFactoryFfi,
      databasePath: inMemoryDatabasePath,
    );
    transactions = SqliteTransactionRepository(database);
    categories = SqliteCategoryRepository(database);
  });

  tearDown(() => database.close());

  Future<void> seedTestUser() async {
    final now = DateTime(2026, 9, 26, 8).millisecondsSinceEpoch;
    final db = await database.database;
    await db.insert('users', {
      'id': 'user-1',
      'email': 'test@example.com',
      'display_name': 'Test',
      'created_at': now,
      'updated_at': now,
    });
  }

  test('creates schema and seeds system categories', () async {
    final result = await categories.getCategories();
    expect(result.map((e) => e.id), containsAll(<String>['makanan', 'belanja_dapur', 'lainnya']));
  });

  test('saves, reads, updates and soft deletes transactions', () async {
    final now = DateTime(2026, 9, 26, 8);
    final transaction = TransactionEntity(
      id: 'tx-1',
      userId: 'user-1',
      type: TransactionType.expense,
      amount: 25000,
      description: 'Beli cabe',
      categoryId: 'belanja_dapur',
      transactionDate: now,
      inputSource: InputSource.text,
      processedBy: ProcessedBy.localParser,
      confidence: .95,
      createdAt: now,
      updatedAt: now,
    );
    final db = await database.database;
    await db.insert('users', {
      'id': 'user-1',
      'email': 'test@example.com',
      'display_name': 'Test',
      'created_at': now.millisecondsSinceEpoch,
      'updated_at': now.millisecondsSinceEpoch,
    });
    await transactions.save(transaction);

    final loaded = await transactions.getById('tx-1');
    expect(loaded?.amount, 25000);
    expect(loaded?.categoryId, 'belanja_dapur');

    await transactions.delete('tx-1');
    expect(await transactions.getById('tx-1'), isNotNull);
    expect((await transactions.getByUser('user-1')), isEmpty);
  });

  test('learns user category corrections and preserves history', () async {
    await seedTestUser();
    await categories.learnMapping(
      userId: 'user-1',
      keyword: 'Cabe',
      categoryId: 'belanja_dapur',
    );
    await categories.learnMapping(
      userId: 'user-1',
      keyword: 'Cabe',
      categoryId: 'makanan',
    );

    final mapping = await categories.findMapping('user-1', 'cabe');
    expect(mapping?.categoryId, 'makanan');
    expect(mapping?.usageCount, 2);

    final db = await database.database;
    final history = await db.query('category_history', where: 'user_id = ?', whereArgs: ['user-1']);
    expect(history, hasLength(2));
    expect(history.last['previous_category_id'], 'belanja_dapur');
  });

  test('category learning resolves exact user mapping before fallback', () async {
    await seedTestUser();
    await categories.learnMapping(
      userId: 'user-1',
      keyword: 'cabe',
      categoryId: 'belanja_dapur',
    );
    final service = CategoryLearningService(categories);

    final resolved = await service.resolve(
      userId: 'user-1',
      text: 'Beli cabe 25 rb',
      fallbackCategoryId: 'lainnya',
    );
    expect(resolved, 'belanja_dapur');
  });
}
