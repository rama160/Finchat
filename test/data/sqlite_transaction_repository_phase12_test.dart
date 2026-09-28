import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:finchat/data/local/finchat_database.dart';
import 'package:finchat/data/repositories/sqlite_transaction_repository.dart';
import 'package:finchat/domain/entities/transaction_entity.dart';

void main() {
  sqfliteFfiInit(); databaseFactory = databaseFactoryFfi;
  TransactionEntity tx(String id, DateTime now, {double amount=10000}) => TransactionEntity(id:id,userId:'u1',type:TransactionType.expense,amount:amount,description:'Nasi',categoryId:'makanan',transactionDate:now,inputSource:InputSource.text,processedBy:ProcessedBy.localParser,confidence:.9,createdAt:now,updatedAt:now);
  test('saveAll persists multiple transactions atomically', () async { final db=FinChatDatabase(factory:databaseFactoryFfi,databasePath:':memory:'); addTearDown(db.close); await db.ensureUser(userId:'u1',email:'u1@example.com'); final repo=SqliteTransactionRepository(db); final now=DateTime(2026,9,28); await repo.saveAll([tx('1',now),tx('2',now,amount:20000)]); expect(await repo.getByUser('u1'),hasLength(2)); });
  test('saveAll rejects duplicate IDs before changing database', () async { final db=FinChatDatabase(factory:databaseFactoryFfi,databasePath:':memory:'); addTearDown(db.close); await db.ensureUser(userId:'u1',email:'u1@example.com'); final repo=SqliteTransactionRepository(db); final now=DateTime(2026,9,28); expect(repo.saveAll([tx('same',now),tx('same',now)]),throwsStateError); expect(await repo.getByUser('u1'),isEmpty); });
}
