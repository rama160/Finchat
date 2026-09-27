import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:finchat/application/transactions/transaction_intelligence_service.dart';
import 'package:finchat/data/local/finchat_database.dart';
import 'package:finchat/data/repositories/sqlite_category_repository.dart';
import 'package:finchat/data/repositories/sqlite_transaction_repository.dart';
import 'package:finchat/domain/ai/ai_category_fallback.dart';
import 'package:finchat/domain/entities/transaction_entity.dart';
import 'package:finchat/domain/services/category_learning_service.dart';

class _NoOpProvider implements AiCategoryProvider {
  @override
  Future<AiCategorySuggestion?> suggestCategory(AiCategoryRequest request) async => null;
}

void main() {
  setUpAll(sqfliteFfiInit);

  late FinChatDatabase database;
  late SqliteCategoryRepository categories;
  late SqliteTransactionRepository transactions;

  setUp(() {
    database = FinChatDatabase(factory: databaseFactoryFfi, databasePath: inMemoryDatabasePath);
    categories = SqliteCategoryRepository(database);
    transactions = SqliteTransactionRepository(database);
  });

  tearDown(() => database.close());

  test('parses multiple transactions, saves them, and preserves category correction', () async {
    await database.ensureUser(userId: 'user-1', email: 'test@example.com');
    final learning = CategoryLearningService(categories);
    final service = TransactionIntelligenceService(
      categoryLearning: learning,
      aiFallback: AiCategoryFallback(
        provider: _NoOpProvider(),
        categoryExists: (id) => categories.getById(id).then((value) => value != null),
      ),
    );

    final drafts = await service.process(
      userId: 'user-1',
      input: 'Beli nasi 25rb dan bensin 50k',
    );

    expect(drafts, hasLength(2));
    expect(drafts[0].amount, 25000);
    expect(drafts[1].amount, 50000);
    expect(drafts[0].categoryId, 'makanan');
    expect(drafts[1].categoryId, 'transportasi');

    final now = DateTime(2026, 9, 27);
    await transactions.save(TransactionEntity(
      id: 'tx-1',
      userId: 'user-1',
      type: TransactionType.expense,
      amount: drafts[0].amount,
      description: drafts[0].description,
      categoryId: 'belanja_dapur',
      transactionDate: now,
      inputSource: InputSource.text,
      processedBy: ProcessedBy.manual,
      confidence: 1,
      createdAt: now,
      updatedAt: now,
    ));
    await learning.recordCorrection(
      userId: 'user-1',
      text: drafts[0].description,
      categoryId: 'belanja_dapur',
    );

    final resolved = await learning.resolve(
      userId: 'user-1',
      text: 'Beli nasi 25rb',
      fallbackCategoryId: 'lainnya',
    );
    expect(resolved, 'belanja_dapur');
    expect(await transactions.getByUser('user-1'), hasLength(1));
  });
}
