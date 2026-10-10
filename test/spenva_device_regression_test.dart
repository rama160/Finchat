import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:finchat/application/session/session_manager.dart';
import 'package:finchat/data/repositories/in_memory_session_repository.dart';
import 'package:finchat/data/local/finchat_database.dart';
import 'package:finchat/main.dart';
import 'package:finchat/presentation/screens/login_screen.dart';
import 'package:finchat/presentation/screens/report_screen.dart';
import 'package:finchat/presentation/widgets/spenva_brand.dart';
import 'package:finchat/core/formatting/rupiah.dart';
import 'package:finchat/domain/speech/transcript_buffer.dart';
import 'package:finchat/domain/parsing/spoken_money_normalizer.dart';
import 'package:finchat/application/transactions/local_transaction_parser.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    sqfliteFfiInit(); databaseFactory = databaseFactoryFfiNoIsolate;
    final dir = await Directory.systemTemp.createTemp('spenva_ux_');
    await databaseFactory.setDatabasesPath(dir.path);
  });
  test('currency, negative balance and provider answers use one format', () {
    expect(formatRupiah(15000), 'Rp 15.000');
    for (final (amount, formatted) in [(100, 'Rp 100'), (160000, 'Rp 160.000'), (567765, 'Rp 567.765'), (100000000, 'Rp 100.000.000')]) {
      expect(formatRupiah(amount), formatted);
    }
    expect(normalizeRupiahText('Rp .567.678 dan Rp.160.000'), 'Rp 567.678 dan Rp 160.000');
    expect(formatRupiah(-3620000), '-Rp 3.620.000');
    expect(normalizeRupiahText('Rp.15.000, Rp15000 dan Rp7.378.000,0'), 'Rp 15.000, Rp 15.000 dan Rp 7.378.000');
  });
  test('segmented and cumulative voice preserve both foods without duplicate amounts', () {
    final buffer = TranscriptBuffer();
    buffer.add('nasi goreng 10.000', isFinal: false);
    buffer.add('bakso 5.000', isFinal: true);
    final parsed = LocalTransactionParser().parse(normalizeVoiceTransactions(buffer.text));
    expect(parsed.map((item) => item.amount), [10000, 5000]);
    expect(parsed.map((item) => item.description), ['nasi goreng', 'bakso']);
    buffer.clear();
    buffer.add('nasi goreng 10.000', isFinal: false);
    buffer.add('nasi goreng 15.000 dan bakso 5.000', isFinal: false);
    buffer.add('nasi goreng 15.000 dan bakso 5.000', isFinal: true);
    expect(LocalTransactionParser().parse(buffer.text).map((item) => item.amount), [15000, 5000]);
    buffer.clear();
    buffer.add('nasi goreng 10.000', isFinal: true);
    buffer.add('nasi goreng 10.000, bakso 5.000', isFinal: true);
    expect(LocalTransactionParser().parse(buffer.text).map((item) => item.amount), [10000, 5000]);
  });
  test('salary and income aliases parse locally including mixed expenses', () {
    final parser = LocalTransactionParser();
    for (final word in ['gaji', 'gajian', 'upah', 'honor', 'bonus', 'komisi', 'THR', 'uang masuk', 'hasil penjualan']) {
      final result = parser.parse('$word 5 juta');
      expect(result.single.amount, 5000000, reason: word);
      expect(result.single.type, ParsedTransactionType.income, reason: word);
    }
    expect(parser.parse('gaji 5000000').single.type, ParsedTransactionType.income);
    expect(parser.parse('gaji 5000000').single.amount, 5000000);
    final mixed = parser.parse('gaji 5 juta, nasi goreng 10.000, bakso 5.000');
    expect(mixed.map((item) => item.amount), [5000000, 10000, 5000]);
    expect(mixed.map((item) => item.type), [ParsedTransactionType.income, ParsedTransactionType.expense, ParsedTransactionType.expense]);
    expect(parser.parse('bayar upah 100 ribu').single.type, ParsedTransactionType.expense);
  });
  test('local greeting uses device hour and only available display name', () {
    expect(greetingFor(DateTime(2026, 10, 6, 9), 'Rama Wijaya'), 'Selamat pagi, Rama');
    expect(greetingFor(DateTime(2026, 10, 6, 13), null), 'Selamat siang');
    expect(greetingFor(DateTime(2026, 10, 6, 17), ''), 'Selamat sore');
    expect(greetingFor(DateTime(2026, 10, 6, 21), '  '), 'Selamat malam');
  });
  testWidgets('sign in stays usable on small screens with large text', (tester) async {
    await tester.binding.setSurfaceSize(const Size(320, 640));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final manager = SessionManager(InMemorySessionRepository()); await manager.initialize();
    await tester.pumpWidget(SessionScope(sessionManager: manager, child: MaterialApp(home: MediaQuery(
      data: const MediaQueryData(size: Size(320, 640), textScaler: TextScaler.linear(1.8)), child: const LoginScreen()))));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Gunakan mode offline'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Gunakan mode offline')); await tester.pumpAndSettle();
    expect(find.text('Email lokal (opsional)'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.tap(find.text('Batal')); await tester.pumpAndSettle();
    await tester.pumpWidget(const SizedBox()); manager.dispose();
  });
  testWidgets('million totals stay complete at large text and PDF saves or shares by choice', (tester) async {
    final database = FinChatDatabase();
    await tester.runAsync(() async {
      await database.ensureUser(userId: 'report@spenva.local');
      final db = await database.database; final now = DateTime.now(); final day = DateTime(now.year, now.month, now.day).millisecondsSinceEpoch;
      for (final row in [(['income', 'gaji', 5000000]), (['expense', 'lainnya', 3620000])]) {
        await db.insert('transactions', {'id': '${row[0]}_ux', 'user_id': 'report@spenva.local', 'type': row[0], 'amount': row[2], 'description': row[0], 'category_id': row[1],
          'transaction_date': day, 'input_source': 'text', 'processed_by': 'localParser', 'confidence': 1, 'created_at': now.millisecondsSinceEpoch, 'updated_at': now.millisecondsSinceEpoch});
      }
    });
    var saves = 0, shares = 0;
    await tester.binding.setSurfaceSize(const Size(320, 780));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(MaterialApp(home: MediaQuery(data: const MediaQueryData(size: Size(320, 780), textScaler: TextScaler.linear(1.8)), child: ReportScreen(userId: 'report@spenva.local',
      savePdf: (bytes, filename) async { expect(String.fromCharCodes(bytes.take(4)), '%PDF'); expect(filename.endsWith('.pdf'), isTrue); saves++; return Uri.parse('content://documents/report.pdf'); },
      sharePdf: (bytes, filename) async { expect(String.fromCharCodes(bytes.take(4)), '%PDF'); shares++; }))));
    await tester.pumpAndSettle();
    expect(find.text('Rp 5.000.000'), findsOneWidget);
    expect(find.text('Saldo'), findsOneWidget);
    expect(find.text('Selisih periode'), findsNothing);
    expect(find.text('Ekspor PDF'), findsNothing);
    final incomeRect = tester.getRect(find.byKey(const ValueKey('metric_Pemasukan')));
    expect(incomeRect.width, greaterThan(200));
    expect(find.text('Rp 3.620.000'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.tap(find.byTooltip('Ekspor PDF')); await tester.pumpAndSettle();
    await tester.tap(find.text('Simpan ke perangkat')); await tester.pumpAndSettle();
    expect(saves, 1); expect(shares, 0);
    await tester.tap(find.byTooltip('Ekspor PDF')); await tester.pumpAndSettle();
    await tester.tap(find.text('Bagikan PDF')); await tester.pumpAndSettle();
    expect(shares, 1);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
    await (await database.database).close();
  });
}
