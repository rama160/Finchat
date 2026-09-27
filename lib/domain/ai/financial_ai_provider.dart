import '../entities/transaction_entity.dart';

class FinancialAiRequest {
  const FinancialAiRequest({required this.question, required this.start, required this.endExclusive, required this.transactions, required this.incomeTotal, required this.expenseTotal, required this.balance});
  final String question;
  final DateTime start;
  final DateTime endExclusive;
  final List<TransactionEntity> transactions;
  final double incomeTotal;
  final double expenseTotal;
  final double balance;
}

abstract interface class FinancialAiProvider {
  Future<String?> answer(FinancialAiRequest request);
}
