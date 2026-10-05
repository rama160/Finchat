import 'package:flutter_test/flutter_test.dart';
import 'package:finchat/domain/reports/report_insights.dart';
import 'package:finchat/domain/reports/report_models.dart';
import 'package:finchat/domain/reports/daily_expenses.dart';
import 'package:finchat/domain/entities/transaction_entity.dart';

void main() {
  TransactionEntity expense(String id, DateTime day, double amount) => TransactionEntity(id: id,
    userId: 'u', type: TransactionType.expense, amount: amount, description: 'Nasi', categoryId: 'makanan',
    transactionDate: day, inputSource: InputSource.text, processedBy: ProcessedBy.localParser, confidence: 1,
    createdAt: day, updatedAt: day);
  ReportSummary report({bool singleDay = false, double income = 100000}) => ReportSummary(
    start: DateTime(2026, 10, 2), endExclusive: DateTime(2026, 10, singleDay ? 3 : 4), incomeTotal: income,
    expenseTotal: 50000, incomeCount: 1, expenseCount: 2,
    groups: const [ReportTransactionGroup(type: TransactionType.expense, categoryId: 'makanan', categoryName: 'Makanan', description: 'Nasi', transactionCount: 2, totalAmount: 50000)],
    transactions: [expense('1', DateTime(2026, 10, 2), 20000), expense('2', DateTime(2026, 10, 2), 30000)],
    categories: const [ReportCategorySummary(categoryId: 'makanan', categoryName: 'Makanan', type: TransactionType.expense, transactionCount: 2, totalAmount: 50000)],
  );
  test('insights derive cash flow, zero-day average, peak and repeat totals from selected data', () {
    final r = report();
    final insights = reportInsights(r, dailyExpenses(r));
    expect(insights.map((i) => i.title), containsAll(['Arus kas periode ini', 'Ritme belanja', 'Puncak pengeluaran', 'Belanja berulang']));
    expect(insights[0].text, contains('50.0%'));
    expect(insights[1].text, contains('Rp 25.000 per hari'));
    expect(insights[1].text, contains('1 hari tanpa pengeluaran'));
    expect(insights.last.text, contains('2 kali'));
    expect(categoryChartCaption(r), contains('100.0% (Rp 50.000)'));
  });
  test('single-day caption compares two bars while period total excludes prior day', () {
    final r = report(singleDay: true);
    final points = expenseChartPoints(r, previousDayExpense: 82000);
    final caption = dailyChartCaption(r, points);
    expect(caption, contains('1/10/2026: Rp 82.000'));
    expect(caption, contains('Turun 39.0%'));
    expect(caption, contains('Total periode terpilih: Rp 50.000'));
    expect(reportInsights(r, points).any((i) => i.title == 'Perubahan harian'), isTrue);
    expect(expenseComparison(0, 50000), isNot(contains('Infinity')));
    expect(reportInsights(report(income: 0), []).first.text, contains('Belum ada pemasukan tercatat'));
  });
}
