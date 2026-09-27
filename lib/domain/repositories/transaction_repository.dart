import '../entities/transaction_entity.dart';

abstract interface class TransactionRepository {
  Future<List<TransactionEntity>> getAll();
  Future<TransactionEntity?> getById(String id);
  Future<List<TransactionEntity>> getByUser(String userId);
  Future<List<TransactionEntity>> getByDateRange({
    required String userId,
    required DateTime start,
    required DateTime end,
  });
  Future<List<TransactionEntity>> getByCategory({
    required String userId,
    required String categoryId,
  });
  Future<void> save(TransactionEntity transaction);
  Future<void> update(TransactionEntity transaction);
  Future<void> delete(String id);
}
