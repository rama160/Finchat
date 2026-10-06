// Captures actual app widgets with invented demo data, never user's screenshots.
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:finchat/application/session/session_manager.dart';
import 'package:finchat/data/repositories/in_memory_session_repository.dart';
import 'package:finchat/data/local/finchat_database.dart';
import 'package:finchat/main.dart';
import 'package:finchat/presentation/screens/login_screen.dart';
import 'package:finchat/presentation/screens/chat_screen.dart';

void main() {
  testWidgets('capture actual Spenva screens with demo finances', (tester) async {
    await tester.runAsync(() async {
      for (final (name,file) in [('SpenvaSans','DejaVuSans.ttf'),('SpenvaSans','DejaVuSans-Bold.ttf')]) {
        final loader=FontLoader(name)..addFont(rootBundle.load('assets/fonts/$file'));await loader.load();
      }
      sqfliteFfiInit();databaseFactory=databaseFactoryFfiNoIsolate;
      final directory=await Directory.systemTemp.createTemp('spenva_store_demo_');await databaseFactory.setDatabasesPath(directory.path);
    });
    await tester.binding.setSurfaceSize(const Size(360,800));addTearDown(()=>tester.binding.setSurfaceSize(null));
    final manager=SessionManager(InMemorySessionRepository());await manager.initialize();
    final capture=GlobalKey();
    Future<void> display(Widget screen) async {
      await tester.pumpWidget(SessionScope(sessionManager:manager,child:RepaintBoundary(key:capture,child:MaterialApp(theme:ThemeData(useMaterial3:true,fontFamily:'SpenvaSans',colorScheme:ColorScheme.fromSeed(seedColor:const Color(0xff555d91)),scaffoldBackgroundColor:const Color(0xfff9f7fd)),home:screen))));
      await tester.pumpAndSettle();
    }
    Future<void> save(String name) async {
      expect(tester.takeException(),isNull);
      final boundary=capture.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      await tester.runAsync(()async{final image=await boundary.toImage(pixelRatio:3);final bytes=await image.toByteData(format:ui.ImageByteFormat.png);final directory=Directory('build/play/screenshots');await directory.create(recursive:true);await File('${directory.path}/$name.png').writeAsBytes(bytes!.buffer.asUint8List());image.dispose();});
    }
    await display(const LoginScreen());await save('01-sign-in');
    await manager.login(email:'demo@finchat.local');
    await tester.runAsync(()async{final database=FinChatDatabase();await database.ensureUser(userId:'demo@finchat.local');final db=await database.database;final now=DateTime.now();final day=DateTime(now.year,now.month,now.day).millisecondsSinceEpoch;
      for(final (id,type,amount,description,category) in [('demo-salary','income',5000000,'gaji','gaji'),('demo-food','expense',25000,'nasi goreng','makanan'),('demo-fuel','expense',50000,'bensin','transportasi')]) {
        await db.insert('transactions',{'id':id,'user_id':'demo@finchat.local','type':type,'amount':amount,'description':description,'category_id':category,'transaction_date':day,'input_source':'text','processed_by':'localParser','confidence':1,'created_at':now.millisecondsSinceEpoch,'updated_at':now.millisecondsSinceEpoch});
      }
    });
    await display(const ChatScreen());await save('02-chat');
    await tester.tap(find.text('Laporan'));await tester.pumpAndSettle();await save('03-report');
    await tester.pumpWidget(const SizedBox());await tester.runAsync(()async{await (await FinChatDatabase().database).close();});manager.dispose();
  },skip:const String.fromEnvironment('CAPTURE_STORE_SCREENSHOTS')!='true');
}
