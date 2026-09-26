import 'package:flutter_test/flutter_test.dart';
import 'package:finchat/application/reports/report_service.dart';
import 'package:finchat/data/local/finchat_database.dart';
import 'package:finchat/data/repositories/sqlite_category_repository.dart';
import 'package:finchat/data/repositories/sqlite_transaction_repository.dart';
import 'package:finchat/domain/entities/transaction_entity.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUpAll(sqfliteFfiInit);

  late FinChatDatabase database;
  late SqliteTransactionRepository transactions;
  late SqliteCategoryRepository categories;
  late ReportService reports;

  setUp(() {
    database = FinChatDatabase(factory: databaseFactoryFfi, databasePath: inMemoryDatabasePath);
    transactions = SqliteTransactionRepository(database);
    categories = SqliteCategoryRepository(database);
    reports = ReportService(transactions: transactions, categories: categories);
  });

  tearDown(() => database.close());

  Future<void> seedUser() async {
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

  Future<void> save({
    required String id,
    required DateTime date,
    required double amount,
    required String description,
    String categoryId = 'makanan',
    TransactionType type = TransactionType.expense,
  }) async {
    await transactions.save(
      TransactionEntity(
        id: id,
        userId: 'user-1',
        type: type,
        amount: amount,
        description: description,
        categoryId: categoryId,
        transactionDate: date,
        inputSource: InputSource.text,
        processedBy: ProcessedBy.localParser,
        confidence: .95,
        createdAt: date,
        updatedAt: date,
      ),
    );
  }

  test('groups transactions with the same detail and exposes transaction count', () async {
    await seedUser();
    await save(id: '1', date: DateTime(2026, 9, 26), amount: 15000, description: 'Nasi Goreng');
    await save(id: '2', date: DateTime(2026, 9, 26), amount: 20000, description: ' nasi   goreng ');
    await save(id: '3', date: DateTime(2026, 9, 26), amount: 5000, description: 'Es Teh');

    final report = await reports.forDay(userId: 'user-1', date: DateTime(2026, 9, 26));
    final nasi = report.groups.firstWhere((group) => group.description.toLowerCase() == 'nasi goreng');

    expect(nasi.transactionCount, 2);
    expect(nasi.totalAmount, 35000);
    expect(report.expenseCount, 3);
    expect(report.expenseTotal, 40000);
  });

  test('keeps same description separate when type or category differs', () async {
    await seedUser();
    await save(id: '1', date: DateTime(2026, 9, 26), amount: 10000, description: 'Bonus', type: TransactionType.expense);
    await save(id: '2', date: DateTime(2026, 9, 26), amount: 500000, description: 'Bonus', type: TransactionType.income, categoryId: 'bonus');

    final report = await reports.forDay(userId: 'user-1', date: DateTime(2026, 9, 26));

    expect(report.groups, hasLength(2));
    expect(report.incomeTotal, 500000);
    expect(report.expenseTotal, 10000);
  });

  test('range report includes both boundary dates', () async {
    await seedUser();
    await save(id: '1', date: DateTime(2026, 9, 1), amount: 10000, description: 'Awal');
    await save(id: '2', date: DateTime(2026, 9, 3), amount: 20000, description: 'Akhir');
    await save(id: '3', date: DateTime(2026, 9, 4), amount: 30000, description: 'Di luar');

    final report = await reports.forRange(
      userId: 'user-1',
      start: DateTime(2026, 9, 1),
      end: DateTime(2026, 9, 3),
    );

    expect(report.expenseTotal, 30000);
    expect(report.expenseCount, 2);
  });

  test('monthly report handles year boundary', () async {
    await seedUser();
    await save(id: '1', date: DateTime(2026, 12, 31), amount: 10000, description: 'Desember');
    await save(id: '2', date: DateTime(2027, 1, 1), amount: 20000, description: 'Januari');

    final report = await reports.forMonth(userId: 'user-1', year: 2026, month: 12);

    expect(report.expenseTotal, 10000);
    expect(report.expenseCount, 1);
  });
}
