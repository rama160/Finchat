import 'package:flutter_test/flutter_test.dart';
import 'package:finchat/application/session/session_manager.dart';
import 'package:finchat/data/repositories/in_memory_session_repository.dart';

void main() {
  test('login creates an authenticated session', () async {
    final manager = SessionManager(InMemorySessionRepository());
    await manager.initialize();
    await manager.login(email: 'test@example.com');
    expect(manager.isAuthenticated, isTrue);
    expect(manager.session?.email, 'test@example.com');
  });
}
