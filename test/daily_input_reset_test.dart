import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:finchat/application/session/session_manager.dart';
import 'package:finchat/data/repositories/in_memory_session_repository.dart';
import 'package:finchat/data/local/finchat_database.dart';
import 'package:finchat/main.dart';
import 'package:finchat/presentation/screens/chat_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfiNoIsolate;
    final directory = await Directory.systemTemp.createTemp('finchat_day_reset_');
    await databaseFactoryFfiNoIsolate.setDatabasesPath(directory.path);
  });
  testWidgets('next-day resume resets the input view while preserving SQLite history', (tester) async {
    final manager = SessionManager(InMemorySessionRepository());
    await manager.initialize();
    await manager.login(email: 'daily@finchat.local');
    await tester.runAsync(() async {
      await FinChatDatabase().ensureUser(userId: 'daily@finchat.local');
    });
    var now = DateTime(2026, 10, 5, 23, 59);
    await tester.pumpWidget(SessionScope(sessionManager: manager, child: MaterialApp(home: ChatScreen(now: () => now))));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'nasi 10 ribu');
    await tester.pump();
    await tester.tap(find.byTooltip('Proses transaksi'));
    await tester.pumpAndSettle();
    expect(find.text('nasi'), findsOneWidget);
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
    now = DateTime(2026, 10, 6, 0, 1);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpAndSettle();
    expect(find.text('nasi'), findsNothing);
    expect(find.textContaining('06 Oktober 2026'), findsOneWidget);
    final db = await FinChatDatabase().database;
    final rows = await db.query('transactions');
    expect(rows.length, 1);
    expect(rows.single['description'], 'nasi');
    await tester.pumpWidget(const SizedBox());
    await db.close();
    manager.dispose();
  });
}
