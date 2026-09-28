import 'package:flutter_test/flutter_test.dart';

import 'package:finchat/application/auth/google_auth_service.dart';
import 'package:finchat/application/session/session_manager.dart';
import 'package:finchat/data/repositories/in_memory_session_repository.dart';
import 'package:finchat/domain/auth/google_auth_result.dart';

class _FakeGoogleAuth implements GoogleAuthGateway {
  _FakeGoogleAuth(this.result);

  final GoogleAuthResult result;
  int signInCalls = 0;
  int signOutCalls = 0;

  @override
  Future<void> initialize() async {}

  @override
  Future<GoogleAuthResult> signIn() async {
    signInCalls++;
    return result;
  }

  @override
  Future<void> signOut() async {
    signOutCalls++;
  }
}

void main() {
  test('Google sign-in creates a Google session without changing the local user key format', () async {
    final repository = InMemorySessionRepository();
    final google = _FakeGoogleAuth(
      const GoogleAuthResult(
        googleUserId: 'google-123',
        email: 'User@Example.com',
        displayName: 'User Example',
        idToken: 'id-token',
      ),
    );
    final manager = SessionManager(repository, googleAuth: google);
    await manager.initialize();

    await manager.loginWithGoogle();

    expect(google.signInCalls, 1);
    expect(manager.session?.userId, 'user@example.com');
    expect(manager.session?.email, 'user@example.com');
    expect(manager.session?.authProvider, 'google');
    expect(manager.session?.providerUserId, 'google-123');
    expect(manager.session?.displayName, 'User Example');
  });

  test('Google logout clears the local session even when Google sign-out succeeds', () async {
    final google = _FakeGoogleAuth(
      const GoogleAuthResult(googleUserId: 'google-123', email: 'user@example.com'),
    );
    final manager = SessionManager(InMemorySessionRepository(), googleAuth: google);
    await manager.initialize();
    await manager.loginWithGoogle();

    await manager.logout();

    expect(google.signOutCalls, 1);
    expect(manager.session, isNull);
  });
}
