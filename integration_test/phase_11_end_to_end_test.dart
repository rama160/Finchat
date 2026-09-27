import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:finchat/data/repositories/in_memory_session_repository.dart';
import 'package:finchat/application/session/session_manager.dart';
import 'package:finchat/main.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Phase 11 authenticated shell exposes report, settings and transaction entry', (tester) async {
    final manager = SessionManager(InMemorySessionRepository());
    await manager.initialize();
    await tester.pumpWidget(FinChatApp(sessionManager: manager));

    expect(find.text('Masuk'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'qa@finchat.local');
    await tester.tap(find.text('Masuk'));
    await tester.pumpAndSettle();

    expect(find.text('FinChat'), findsOneWidget);
    expect(find.byTooltip('Laporan'), findsOneWidget);
    expect(find.byTooltip('Pengaturan'), findsOneWidget);
    expect(find.byTooltip('Proses transaksi'), findsOneWidget);
  });
}
