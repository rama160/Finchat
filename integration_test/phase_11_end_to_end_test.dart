import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:finchat/data/local/finchat_database.dart';
import 'package:finchat/data/repositories/in_memory_session_repository.dart';
import 'package:finchat/application/session/session_manager.dart';
import 'package:finchat/main.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('authenticated shell preserves offline multi-transaction entry, reports and navigation', (tester) async {
    if (Platform.isLinux) {
      sqfliteFfiInit(); databaseFactory = databaseFactoryFfiNoIsolate;
      final directory = await Directory.systemTemp.createTemp('spenva_integration_');
      await databaseFactory.setDatabasesPath(directory.path);
    }
    final manager = SessionManager(InMemorySessionRepository());
    await manager.initialize();
    await tester.pumpWidget(FinChatApp(sessionManager: manager));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Gunakan mode offline'));
    await tester.tap(find.text('Gunakan mode offline'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'qa@finchat.local');
    await tester.tap(find.text('Mulai'));
    await tester.pumpAndSettle();
    expect(find.byTooltip('Pengaturan'), findsOneWidget);
    expect(find.byTooltip('Input suara'), findsOneWidget);
    final input = find.byKey(const ValueKey('chat_input'));
    await tester.enterText(input, 'nasi goreng 10 ribu dan bakso 5 ribu dan gaji 7 juta');
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Proses transaksi'));
    await tester.pumpAndSettle();
    final database = FinChatDatabase(); final db = await database.database;
    final rows = await db.query('transactions', where: 'user_id = ?', whereArgs: ['qa@finchat.local']);
    expect(rows, hasLength(3));
    expect(rows.singleWhere((row) => row['type'] == 'income')['amount'], 7000000);
    await tester.tap(find.text('Laporan')); await tester.pumpAndSettle();
    expect(find.text('Saldo'), findsOneWidget);
    await tester.tap(find.text('Input')); await tester.pumpAndSettle();
    expect(input, findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox()); await db.close(); manager.dispose();
  });
}
