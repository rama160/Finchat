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

/// Comparison points do not alter the report's filtered totals or PDF data.
List<DailyExpense> expenseChartPoints(ReportSummary report, {double? previousDayExpense}) {
  final points = dailyExpenses(report);
  if (points.length == 1 && previousDayExpense != null) {
    final selected = points.single;
    return [DailyExpense(DateTime(selected.date.year, selected.date.month, selected.date.day - 1), previousDayExpense), selected];
  }
  return points;
}
