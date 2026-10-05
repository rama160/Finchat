import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:finchat/application/session/session_manager.dart';
import 'package:finchat/data/repositories/in_memory_session_repository.dart';
import 'package:finchat/main.dart';
import 'package:finchat/data/local/finchat_database.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfiNoIsolate;
    final directory = await Directory.systemTemp.createTemp('finchat_navigation_');
    await databaseFactoryFfiNoIsolate.setDatabasesPath(directory.path);
  });
  testWidgets('system back returns backup to settings, settings to input, reports to input', (tester) async {
    final manager = SessionManager(InMemorySessionRepository());
    await manager.initialize();
    await manager.login(email: 'qa@finchat.local');
    // Widget tests use a fake clock; open SQLite outside it and execute native
    // queries without a background isolate to avoid pumpAndSettle deadlocks.
    await tester.runAsync(() async {
      await FinChatDatabase().ensureUser(userId: 'qa@finchat.local');
    });
    await tester.pumpWidget(FinChatApp(sessionManager: manager));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'nasi 25rb');
    await tester.pump();
    await tester.tap(find.byTooltip('Proses transaksi'));
    await tester.pumpAndSettle();
    expect(find.text('nasi'), findsOneWidget);
    // Wait for the successful-save snackbar before tapping the composer again.
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'berapa pengeluaran hari ini?');
    await tester.pump();
    await tester.tap(find.byTooltip('Proses transaksi'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Total pengeluaran'), findsOneWidget);
    final beforeQuestion = await (await FinChatDatabase().database).query('transactions');
    await tester.enterText(find.byType(TextField), 'Apakah anggaran 2 juta cukup?');
    await tester.pump();
    await tester.tap(find.byTooltip('Proses transaksi'));
    await tester.pumpAndSettle();
    final afterQuestion = await (await FinChatDatabase().database).query('transactions');
    expect(afterQuestion.length, beforeQuestion.length);
    expect(find.text('Apakah anggaran 2 juta cukup?'), findsOneWidget);
    await tester.tap(find.byTooltip('Pengaturan'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Backup & pemulihan'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Backup & pemulihan'));
    await tester.pumpAndSettle();
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('Pengaturan'), findsOneWidget);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('FinChat'), findsOneWidget);
    await tester.tap(find.byTooltip('Laporan'));
    await tester.pumpAndSettle();
    expect(find.text('Laporan'), findsWidgets);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('FinChat'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
    final db = await FinChatDatabase().database;
    await db.close();
    manager.dispose();
  });
}
