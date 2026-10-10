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
import 'package:finchat/presentation/widgets/spenva_brand.dart';
import 'package:finchat/presentation/widgets/period_filter.dart';

void main() {
  testWidgets('capture actual Spenva screens with demo finances', (tester) async {
    await tester.runAsync(() async {
      final bodyFont=FontLoader('SpenvaSans')
        ..addFont(rootBundle.load('assets/fonts/DejaVuSans.ttf'))
        ..addFont(rootBundle.load('assets/fonts/DejaVuSans-Bold.ttf'));
      await bodyFont.load();
      final googleFont=FontLoader('GoogleSans')..addFont(rootBundle.load('assets/fonts/GoogleSans-Medium.ttf'));await googleFont.load();
      final sdk=Platform.environment['FLUTTER_ROOT'];
      if (sdk == null) throw StateError('FLUTTER_ROOT is required for capture icon font.');
      final icons=await File('$sdk/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf').readAsBytes();
      final iconFont=FontLoader('MaterialIcons')..addFont(Future.value(ByteData.sublistView(icons)));await iconFont.load();
      sqfliteFfiInit();databaseFactory=databaseFactoryFfiNoIsolate;
      final directory=await Directory.systemTemp.createTemp('spenva_store_demo_');await databaseFactory.setDatabasesPath(directory.path);
    });
    await tester.binding.setSurfaceSize(const Size(432,768));addTearDown(()=>tester.binding.setSurfaceSize(null));
    final manager=SessionManager(InMemorySessionRepository());await manager.initialize();
    final capture=GlobalKey();
    Future<void> display(Widget screen) async {
      await tester.pumpWidget(SessionScope(sessionManager:manager,child:RepaintBoundary(key:capture,child:MaterialApp(debugShowCheckedModeBanner:false,theme:spenvaTheme(),home:screen))));
      await tester.pumpAndSettle();
      final context=tester.element(find.byType(MaterialApp));
      await tester.runAsync(()async{
        for(final asset in ['sign_in','header','mark','google-g']) {
          await precacheImage(AssetImage('assets/brand/$asset.png'),context);
        }
      });
      await tester.pumpAndSettle();
    }
    Future<void> save(String name) async {
      expect(tester.takeException(),isNull);
      final boundary=capture.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      await tester.runAsync(()async{final image=await boundary.toImage(pixelRatio:2.5);final bytes=await image.toByteData(format:ui.ImageByteFormat.png);final directory=Directory('build/play/screenshots');await directory.create(recursive:true);await File('${directory.path}/$name.png').writeAsBytes(bytes!.buffer.asUint8List());image.dispose();});
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
    await tester.tap(find.descendant(of:find.byType(PeriodFilter),matching:find.byType(TextButton)).first);await tester.pumpAndSettle();
    final month=DateTime.now();
    await tester.tap(find.byKey(ValueKey('calendar_${month.year}_${month.month}_1')));await tester.pump();
    await tester.tap(find.byKey(ValueKey('calendar_${month.year}_${month.month}_3')));await tester.pumpAndSettle();await save('04-calendar');
    await tester.pumpWidget(const SizedBox());await tester.runAsync(()async{await (await FinChatDatabase().database).close();});manager.dispose();
  },skip:const String.fromEnvironment('CAPTURE_STORE_SCREENSHOTS')!='true');
}
