import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../domain/entities/session.dart';
import '../../domain/repositories/session_repository.dart';

class SecureSessionRepository implements SessionRepository {
  SecureSessionRepository({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  static const _userIdKey = 'finchat.session.user_id';
  static const _emailKey = 'finchat.session.email';

  final FlutterSecureStorage _storage;

  @override
  Future<Session?> getCurrentSession() async {
    final userId = await _storage.read(key: _userIdKey);
    final email = await _storage.read(key: _emailKey);
    if (userId == null || email == null || userId.trim().isEmpty || email.trim().isEmpty) {
      return null;
    }
    return Session(userId: userId, email: email);
  }

  @override
  Future<void> saveSession(Session session) async {
    await _storage.write(key: _userIdKey, value: session.userId);
    await _storage.write(key: _emailKey, value: session.email);
  }

  @override
  Future<void> clearSession() async {
    await _storage.delete(key: _userIdKey);
    await _storage.delete(key: _emailKey);
  }
}
