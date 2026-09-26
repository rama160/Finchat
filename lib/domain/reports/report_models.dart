import '../entities/transaction_entity.dart';

class ReportTransactionGroup {
  const ReportTransactionGroup({
    required this.type,
    required this.categoryId,
    required this.categoryName,
    required this.description,
    required this.transactionCount,
    required this.totalAmount,
  });

  final TransactionType type;
  final String categoryId;
  final String categoryName;
  final String description;
  final int transactionCount;
  final double totalAmount;
}

class ReportSummary {
  const ReportSummary({
    required this.start,
    required this.endExclusive,
    required this.incomeTotal,
    required this.expenseTotal,
    required this.incomeCount,
    required this.expenseCount,
    required this.groups,
  });

  final DateTime start;
  final DateTime endExclusive;
  final double incomeTotal;
  final double expenseTotal;
  final int incomeCount;
  final int expenseCount;
  final List<ReportTransactionGroup> groups;

  double get balance => incomeTotal - expenseTotal;
  int get transactionCount => incomeCount + expenseCount;
}
