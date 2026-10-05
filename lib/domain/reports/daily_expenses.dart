import '../entities/transaction_entity.dart';
import 'report_models.dart';

class DailyExpense {
  const DailyExpense(this.date, this.amount);
  final DateTime date;
  final double amount;
}

List<DailyExpense> dailyExpenses(ReportSummary report) {
  final totals = <DateTime, double>{};
  for (final transaction in report.transactions) {
    if (transaction.type != TransactionType.expense) continue;
    final date = transaction.transactionDate;
    final day = DateTime(date.year, date.month, date.day);
    totals[day] = (totals[day] ?? 0) + transaction.amount;
  }
  final result = <DailyExpense>[];
  for (var day = report.start; day.isBefore(report.endExclusive); day = DateTime(day.year, day.month, day.day + 1)) {
    result.add(DailyExpense(day, totals[day] ?? 0));
  }
  return result;
}
