import '../../domain/entities/transaction_entity.dart';
import '../../domain/repositories/category_repository.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../../domain/reports/report_models.dart';

class ReportService {
  ReportService({required this.transactions, required this.categories});

  final TransactionRepository transactions;
  final CategoryRepository categories;

  Future<ReportSummary> generate({
    required String userId,
    required DateTime start,
    required DateTime endExclusive,
  }) async {
    final normalizedStart = _day(start);
    final normalizedEnd = _day(endExclusive);
    if (!normalizedEnd.isAfter(normalizedStart)) {
      throw ArgumentError.value(endExclusive, 'endExclusive', 'Must be after start.');
    }

    final items = await transactions.getByDateRange(
      userId: userId,
      start: normalizedStart,
      end: normalizedEnd,
    );
    final categoryList = await categories.getCategories();
    final categoryNames = <String, String>{
      for (final category in categoryList) category.id: category.name,
    };

    var incomeTotal = 0.0;
    var expenseTotal = 0.0;
    var incomeCount = 0;
    var expenseCount = 0;
    final grouped = <String, _MutableGroup>{};
    final categoryGrouped = <String, _MutableCategory>{};

    for (final transaction in items) {
      if (transaction.type == TransactionType.income) {
        incomeTotal += transaction.amount;
        incomeCount++;
      } else {
        expenseTotal += transaction.amount;
        expenseCount++;
      }

      final normalizedDescription = _normalizeDescription(transaction.description);
      final key = '${transaction.type.name}|${transaction.categoryId}|$normalizedDescription';
      final existing = grouped[key];
      if (existing == null) {
        grouped[key] = _MutableGroup(
          type: transaction.type,
          categoryId: transaction.categoryId,
          categoryName: categoryNames[transaction.categoryId] ?? transaction.categoryId,
          description: transaction.description.trim(),
          transactionCount: 1,
          totalAmount: transaction.amount,
        );
      } else {
        existing.transactionCount++;
        existing.totalAmount += transaction.amount;
      }

      final categoryKey = '${transaction.type.name}|${transaction.categoryId}';
      final category = categoryGrouped[categoryKey];
      if (category == null) {
        categoryGrouped[categoryKey] = _MutableCategory(
          categoryId: transaction.categoryId,
          categoryName: categoryNames[transaction.categoryId] ?? transaction.categoryId,
          type: transaction.type,
          transactionCount: 1,
          totalAmount: transaction.amount,
        );
      } else {
        category.transactionCount++;
        category.totalAmount += transaction.amount;
      }
    }

    final resultGroups = grouped.values
        .map((group) => ReportTransactionGroup(
              type: group.type,
              categoryId: group.categoryId,
              categoryName: group.categoryName,
              description: group.description,
              transactionCount: group.transactionCount,
              totalAmount: group.totalAmount,
            ))
        .toList()
      ..sort((a, b) {
        final amount = b.totalAmount.compareTo(a.totalAmount);
        if (amount != 0) return amount;
        return a.description.toLowerCase().compareTo(b.description.toLowerCase());
      });

    final resultCategories = categoryGrouped.values
        .map((item) => ReportCategorySummary(
              categoryId: item.categoryId,
              categoryName: item.categoryName,
              type: item.type,
              transactionCount: item.transactionCount,
              totalAmount: item.totalAmount,
            ))
        .toList()
      ..sort((a, b) => b.totalAmount.compareTo(a.totalAmount));

    return ReportSummary(
      start: normalizedStart,
      endExclusive: normalizedEnd,
      incomeTotal: incomeTotal,
      expenseTotal: expenseTotal,
      incomeCount: incomeCount,
      expenseCount: expenseCount,
      groups: List.unmodifiable(resultGroups),
      transactions: List.unmodifiable(items),
      categories: List.unmodifiable(resultCategories),
    );
  }

  Future<ReportSummary> forDay({required String userId, required DateTime date}) {
    final start = _day(date);
    return generate(userId: userId, start: start, endExclusive: start.add(const Duration(days: 1)));
  }

  Future<ReportSummary> forRange({required String userId, required DateTime start, required DateTime end}) {
    final normalizedStart = _day(start);
    final normalizedEnd = _day(end);
    return generate(userId: userId, start: normalizedStart, endExclusive: normalizedEnd.add(const Duration(days: 1)));
  }

  Future<ReportSummary> forMonth({required String userId, required int year, required int month}) {
    if (month < 1 || month > 12) throw ArgumentError.value(month, 'month', 'Must be between 1 and 12.');
    final start = DateTime(year, month);
    return generate(userId: userId, start: start, endExclusive: DateTime(year, month + 1));
  }

  static String _normalizeDescription(String value) => value.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
  static DateTime _day(DateTime value) => DateTime(value.year, value.month, value.day);
}

class _MutableGroup {
  _MutableGroup({required this.type, required this.categoryId, required this.categoryName, required this.description, required this.transactionCount, required this.totalAmount});
  final TransactionType type;
  final String categoryId;
  final String categoryName;
  final String description;
  int transactionCount;
  double totalAmount;
}

class _MutableCategory {
  _MutableCategory({required this.categoryId, required this.categoryName, required this.type, required this.transactionCount, required this.totalAmount});
  final String categoryId;
  final String categoryName;
  final TransactionType type;
  int transactionCount;
  double totalAmount;
}
