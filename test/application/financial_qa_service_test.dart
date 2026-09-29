import 'package:finchat/application/ai/financial_qa_service.dart';
import 'package:finchat/application/reports/report_service.dart';
import 'package:finchat/data/local/finchat_database.dart';
import 'package:finchat/data/repositories/sqlite_category_repository.dart';
import 'package:finchat/data/repositories/sqlite_transaction_repository.dart';
import 'package:finchat/domain/ai/financial_ai_provider.dart';
import 'package:finchat/domain/entities/transaction_entity.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class _NeverAi implements FinancialAiProvider {
  var calls = 0;

  @override
  Future<String?> answer(FinancialAiRequest request) async {
    calls++;
    return 'AI';
  }
}

void main() {
  setUpAll(sqfliteFfiInit);

  test('answers common finance question locally before AI fallback', () async {
    final database = FinChatDatabase(
      factory: databaseFactoryFfi,
      databasePath: inMemoryDatabasePath,
    );
    addTearDown(database.close);
    await database.ensureUser(userId: 'u1', email: 'u1@example.com');

    final transactions = SqliteTransactionRepository(database);
    final now = DateTime(2026, 9, 29);
    await transactions.save(
      TransactionEntity(
        id: 't1',
        userId: 'u1',
        type: TransactionType.expense,
        amount: 25000,
        description: 'Nasi',
        categoryId: 'makanan',
        transactionDate: now,
        inputSource: InputSource.text,
        processedBy: ProcessedBy.localParser,
        confidence: .95,
        createdAt: now,
        updatedAt: now,
      ),
    );

    final provider = _NeverAi();
    final service = FinancialQaService(
      reports: ReportService(
        transactions: transactions,
        categories: SqliteCategoryRepository(database),
      ),
      provider: provider,
    );

    final answer = await service.ask(
      userId: 'u1',
      question: 'Berapa total pengeluaran saya?',
      start: now,
      end: now,
    );

    expect(answer, contains('Rp 25.000'));
    expect(provider.calls, 0);
  });
}
