import 'package:flutter_test/flutter_test.dart';
import 'package:finchat/application/session/session_manager.dart';
import 'package:finchat/data/repositories/in_memory_session_repository.dart';
import 'package:finchat/main.dart';

void main() {
  testWidgets('shows login when there is no session', (tester) async {
    final manager = SessionManager(InMemorySessionRepository());
    await manager.initialize();
    await tester.pumpWidget(FinChatApp(sessionManager: manager));
    expect(find.bySemanticsLabel('Spenva'), findsWidgets);
    expect(find.text('Lanjut dengan Google'), findsOneWidget);
    expect(find.text('Gunakan mode offline'), findsOneWidget);
  });
}
