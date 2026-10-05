import 'package:flutter_test/flutter_test.dart';
import 'package:finchat/domain/reports/daily_expenses.dart';
import 'package:finchat/domain/reports/report_models.dart';
import 'package:finchat/domain/entities/transaction_entity.dart';

void main() {
  test('daily range includes empty days, aggregates expenses and excludes income', () {
    final start = DateTime(2026, 10, 1);
    TransactionEntity item(String id, int day, double amount, TransactionType type) => TransactionEntity(id: id, userId: 'u', type: type, amount: amount, description: id, categoryId: 'lainnya', transactionDate: DateTime(2026, 10, day), inputSource: InputSource.text, processedBy: ProcessedBy.localParser, confidence: 1, createdAt: start, updatedAt: start);
    final report = ReportSummary(start: start, endExclusive: DateTime(2026, 10, 4), incomeTotal: 500, expenseTotal: 35, incomeCount: 1, expenseCount: 3, groups: const [], categories: const [], transactions: [item('a', 1, 10, TransactionType.expense), item('b', 1, 20, TransactionType.expense), item('c', 3, 5, TransactionType.expense), item('d', 2, 500, TransactionType.income)]);
    final points = dailyExpenses(report);
    expect(points.map((point) => point.amount), [30, 0, 5]);
    expect(points.fold<double>(0, (sum, point) => sum + point.amount), report.expenseTotal);
    expect(points.last.date, DateTime(2026, 10, 3));
  });
  test('one-day comparison crosses year boundary without changing selected total', () {
    final report = ReportSummary(start: DateTime(2027, 1, 1), endExclusive: DateTime(2027, 1, 2), incomeTotal: 0, expenseTotal: 0, incomeCount: 0, expenseCount: 0, groups: const [], categories: const [], transactions: const []);
    final points = expenseChartPoints(report, previousDayExpense: 15000);
    expect(points.map((point) => point.amount), [15000, 0]);
    expect(points.first.date, DateTime(2026, 12, 31));
    expect(points.last.date, DateTime(2027, 1, 1));
    expect(report.expenseTotal, 0);
    expect(report.transactions, isEmpty);
  });

}
