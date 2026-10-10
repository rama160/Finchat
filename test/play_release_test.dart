import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:finchat/application/billing/plan_catalog.dart';
import 'package:finchat/application/privacy/account_data_service.dart';
import 'package:finchat/application/privacy/data_operation_gate.dart';
import 'package:finchat/application/privacy/drive_data_deletion.dart';
import 'package:finchat/core/release/play_release_config.dart';
import 'package:finchat/data/ai/openai_compatible_ai_provider.dart';
import 'package:finchat/data/local/finchat_database.dart';
import 'package:finchat/domain/backup/backup_models.dart';
import 'package:finchat/domain/ai/ai_category_fallback.dart';
import 'package:finchat/domain/entities/transaction_entity.dart';

void main() {
  test('invalid account, expired and client-only purchase cannot grant AI', () {
    final valid={'active':true,'tier':'pro','accountId':'one','expiresAt':DateTime.now().add(const Duration(days:1)).toIso8601String()};
    expect(VerifiedEntitlement.fromServer(valid,'one'),isNotNull);
    expect(VerifiedEntitlement.fromServer(valid,'two'),isNull);
    expect(VerifiedEntitlement.fromServer({...valid,'active':false},'one'),isNull);
    expect(VerifiedEntitlement.fromServer({...valid,'expiresAt':'2020-01-01'},'one'),isNull);
    expect(VerifiedEntitlement.fromServer({...valid,'tier':'free'},'one'),isNull);
  });
  test('Play Free profile never sends financial data to pilot gateway', () async {
    if (!PlayReleaseConfig.isPlay) return;
    int calls=0;
    final provider=OpenAiCompatibleAiProvider(client:MockClient((_)async{calls++;return http.Response('{"text":"unsafe"}',200);}),idTokenProvider:()async=>'token');
    final suggestion=await provider.suggestCategory(AiCategoryRequest(userId:'one',description:'Test',originalText:'Test',type:TransactionType.expense,amount:10000,localCategoryId:'lainnya',availableCategoryIds:['lainnya']));
    expect(suggestion,isNull);expect(calls,0);expect(provider.failureMessage,contains('belum diaktifkan'));
  });
  test('deletion waits for queued backup and blocks new uploads',() async {
    final events=<String>[], upload=Completer<void>();
    final backup=DataOperationGate.backup(()async{events.add('backup');await upload.future;});
    await Future<void>.delayed(Duration.zero);
    final deletion=DataOperationGate.deletion(()async{events.add('delete');});
    await expectLater(DataOperationGate.backup(()async{}),throwsStateError);
    upload.complete();await backup;await deletion;expect(events,['backup','delete']);
  });
  test('Drive deletion preserves other profiles, removes deleted learning and custom categories',() {
    final snapshot=BackupSnapshot(formatVersion:1,createdAt:DateTime.now(),tables:{'users':[{'id':'one'},{'id':'two'}],'transactions':[{'user_id':'one','category_id':'private'},{'user_id':'two','category_id':'shared'}],'category_mappings':[{'user_id':'one','category_id':'private'}],'category_history':[],'categories':[{'id':'private','is_system':0},{'id':'shared','is_system':0},{'id':'system','is_system':1}],'app_settings':[]});
    final clean=removeUserFromBackup(snapshot,'one');expect(clean.tables['users'],[{'id':'two'}]);expect(clean.tables['transactions'],[{'user_id':'two','category_id':'shared'}]);expect(clean.tables['categories']!.map((x)=>x['id']),['shared','system']);expect(clean.tables['category_mappings'],isEmpty);
  });
  test('local deletion removes only selected user and keeps database open',() async {
    sqfliteFfiInit();final database=FinChatDatabase(factory:databaseFactoryFfi,databasePath:inMemoryDatabasePath);addTearDown(database.close);
    await database.ensureUser(userId:'one');await database.ensureUser(userId:'two');final db=await database.database;
    await db.insert('categories',{'id':'private','name':'Private','type':'expense','is_system':0});
    await db.insert('category_mappings',{'id':'mapping','user_id':'one','normalized_keyword':'private','category_id':'private','source':'user','confidence':1,'usage_count':1,'last_used_at':1,'created_at':1,'updated_at':1});
    await AccountDataService(database).deleteLocalUser('one');expect(db.isOpen,isTrue);expect((await db.query('users')).map((x)=>x['id']),['two']);expect(await db.query('category_mappings'),isEmpty);expect(await db.query('categories',where:'id = ?',whereArgs:['private']),isEmpty);expect((await db.query('categories')).length,9);
  });
}
