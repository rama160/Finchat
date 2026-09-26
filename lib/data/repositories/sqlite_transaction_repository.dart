import 'package:sqflite/sqflite.dart';

import '../../domain/entities/transaction_entity.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../local/finchat_database.dart';

class SqliteTransactionRepository implements TransactionRepository {
  SqliteTransactionRepository(this.database);

  final FinChatDatabase database;

  @override
  Future<List<TransactionEntity>> getAll() async {
    final db = await database.database;
    final rows = await db.query(
      'transactions',
      where: 'deleted_at IS NULL',
      orderBy: 'transaction_date DESC, created_at DESC',
    );
    return rows.map(_fromRow).toList();
  }

  Future<List<TransactionEntity>> getByUser(String userId) async {
    final db = await database.database;
    final rows = await db.query(
      'transactions',
      where: 'user_id = ? AND deleted_at IS NULL',
      whereArgs: [userId],
      orderBy: 'transaction_date DESC, created_at DESC',
    );
    return rows.map(_fromRow).toList();
  }

  Future<TransactionEntity?> getById(String id) async {
    final db = await database.database;
    final rows = await db.query('transactions', where: 'id = ?', whereArgs: [id], limit: 1);
    if (rows.isEmpty) return null;
    return _fromRow(rows.first);
  }

  Future<List<TransactionEntity>> getByDateRange({
    required String userId,
    required DateTime start,
    required DateTime end,
  }) async {
    final db = await database.database;
    final rows = await db.query(
      'transactions',
      where: 'user_id = ? AND transaction_date >= ? AND transaction_date < ? AND deleted_at IS NULL',
      whereArgs: [userId, _day(start), _day(end)],
      orderBy: 'transaction_date ASC, created_at ASC',
    );
    return rows.map(_fromRow).toList();
  }

  Future<List<TransactionEntity>> getByCategory({required String userId, required String categoryId}) async {
    final db = await database.database;
    final rows = await db.query(
      'transactions',
      where: 'user_id = ? AND category_id = ? AND deleted_at IS NULL',
      whereArgs: [userId, categoryId],
      orderBy: 'transaction_date DESC',
    );
    return rows.map(_fromRow).toList();
  }

  @override
  Future<void> save(TransactionEntity transaction) async {
    final db = await database.database;
    await db.insert('transactions', _toRow(transaction), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> update(TransactionEntity transaction) => save(transaction);

  @override
  Future<void> delete(String id) async {
    final db = await database.database;
    await db.update(
      'transactions',
      {
        'deleted_at': DateTime.now().millisecondsSinceEpoch,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
        'sync_status': 'pending_delete',
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Map<String, Object?> _toRow(TransactionEntity value) => {
        'id': value.id,
        'user_id': value.userId,
        'type': value.type.name,
        'amount': value.amount,
        'description': value.description,
        'category_id': value.categoryId,
        'transaction_date': _day(value.transactionDate),
        'transaction_time': value.transactionTime?.millisecondsSinceEpoch,
        'input_source': value.inputSource.name,
        'processed_by': value.processedBy.name,
        'confidence': value.confidence,
        'created_at': value.createdAt.millisecondsSinceEpoch,
        'updated_at': value.updatedAt.millisecondsSinceEpoch,
        'deleted_at': value.deletedAt?.millisecondsSinceEpoch,
        'sync_status': value.syncStatus,
      };

  TransactionEntity _fromRow(Map<String, Object?> row) => TransactionEntity(
        id: row['id']! as String,
        userId: row['user_id']! as String,
        type: TransactionType.values.byName(row['type']! as String),
        amount: (row['amount']! as num).toDouble(),
        description: row['description']! as String,
        categoryId: row['category_id']! as String,
        transactionDate: DateTime.fromMillisecondsSinceEpoch(row['transaction_date']! as int),
        transactionTime: _date(row['transaction_time']),
        inputSource: InputSource.values.byName(row['input_source']! as String),
        processedBy: ProcessedBy.values.byName(row['processed_by']! as String),
        confidence: (row['confidence']! as num).toDouble(),
        createdAt: DateTime.fromMillisecondsSinceEpoch(row['created_at']! as int),
        updatedAt: DateTime.fromMillisecondsSinceEpoch(row['updated_at']! as int),
        deletedAt: _date(row['deleted_at']),
        syncStatus: row['sync_status']! as String,
      );

  DateTime? _date(Object? value) => value == null ? null : DateTime.fromMillisecondsSinceEpoch(value as int);
  int _day(DateTime value) => DateTime(value.year, value.month, value.day).millisecondsSinceEpoch;
}
