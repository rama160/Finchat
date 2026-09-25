import '../entities/transaction_entity.dart';

abstract interface class TransactionRepository {
  Future<List<TransactionEntity>> getAll();
  Future<void> save(TransactionEntity transaction);
  Future<void> delete(String id);
}
