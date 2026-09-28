import 'package:flutter/foundation.dart';

import '../../domain/entities/session.dart';
import '../../domain/repositories/session_repository.dart';
import '../auth/google_auth_service.dart';

class SessionManager extends ChangeNotifier {
  SessionManager(this._repository, {GoogleAuthGateway? googleAuth}) : _googleAuth = googleAuth;

  final SessionRepository _repository;
  final GoogleAuthGateway? _googleAuth;
  Session? _session;
  bool _initialized = false;
  bool _busy = false;

  Session? get session => _session;
  bool get initialized => _initialized;
  bool get isAuthenticated => _session != null;
  bool get isBusy => _busy;

  Future<void> initialize() async {
    _session = await _repository.getCurrentSession();
    _initialized = true;
    notifyListeners();
  }

  Future<void> login({required String email}) async {
    final normalized = email.trim().toLowerCase();
    if (!_isValidEmail(normalized)) throw const FormatException('Masukkan alamat email yang valid.');
    final session = Session(userId: normalized, email: normalized);
    await _repository.saveSession(session);
    _session = session;
    notifyListeners();
  }

  Future<void> loginWithGoogle() async {
    final googleAuth = _googleAuth;
    if (googleAuth == null) throw StateError('Google Sign-In belum dikonfigurasi.');
    if (_busy) return;
    _busy = true;
    notifyListeners();
    try {
      final result = await googleAuth.signIn();
      final normalizedEmail = result.email.trim().toLowerCase();
      final session = Session(
        // Keep the local user key compatible with existing email-based data.
        userId: normalizedEmail,
        email: normalizedEmail,
        authProvider: 'google',
        providerUserId: result.googleUserId,
        displayName: result.displayName,
      );
      await _repository.saveSession(session);
      _session = session;
    } finally {
      _busy = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    if (_session?.authProvider == 'google') {
      try {
        await _googleAuth?.signOut();
      } catch (_) {
        // Local session must still be cleared if remote Google sign-out fails.
      }
    }
    await _repository.clearSession();
    _session = null;
    notifyListeners();
  }

  static bool _isValidEmail(String value) => RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value);
}
