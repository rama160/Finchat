import 'package:google_sign_in/google_sign_in.dart';

import '../../domain/auth/google_auth_result.dart';
import 'google_sign_in_coordinator.dart';

abstract interface class GoogleAuthGateway {
  Future<void> initialize();
  Future<GoogleAuthResult> signIn();
  Future<void> signOut();
}

class GoogleAuthService implements GoogleAuthGateway {
  GoogleAuthService({GoogleSignIn? signIn, String? serverClientId, GoogleSignInCoordinator? coordinator})
      : _coordinator = coordinator ?? (signIn == null ? GoogleSignInCoordinator.instance : GoogleSignInCoordinator(signIn: signIn, serverClientId: serverClientId)) {
    if (signIn == null) {
      _coordinator.configure(serverClientId: serverClientId);
    }
  }

  final GoogleSignInCoordinator _coordinator;

  GoogleSignIn get _signIn => _coordinator.signIn;

  @override
  Future<void> initialize() => _coordinator.initialize();

  @override
  Future<GoogleAuthResult> signIn() async {
    await initialize();
    if (!_signIn.supportsAuthenticate()) {
      throw StateError('Google Sign-In tidak tersedia pada platform ini.');
    }

    final account = await _signIn.authenticate();
    _coordinator.rememberAccount(account);
    final authentication = account.authentication;
    final email = account.email.trim().toLowerCase();
    final googleUserId = account.id.trim();
    if (googleUserId.isEmpty || email.isEmpty) {
      throw StateError('Informasi akun Google tidak lengkap.');
    }

    return GoogleAuthResult(
      googleUserId: googleUserId,
      email: email,
      displayName: account.displayName,
      idToken: authentication.idToken,
    );
  }

  @override
  Future<void> signOut() async {
    await initialize();
    try {
      await _signIn.signOut();
    } finally {
      _coordinator.clearAccount();
    }
  }
}
