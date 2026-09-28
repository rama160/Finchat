import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../domain/entities/session.dart';
import '../../domain/repositories/session_repository.dart';

class SecureSessionRepository implements SessionRepository {
  SecureSessionRepository({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  static const _userIdKey = 'finchat.session.user_id';
  static const _emailKey = 'finchat.session.email';
  static const _providerKey = 'finchat.session.auth_provider';
  static const _providerUserIdKey = 'finchat.session.provider_user_id';
  static const _displayNameKey = 'finchat.session.display_name';

  final FlutterSecureStorage _storage;

  @override
  Future<Session?> getCurrentSession() async {
    final userId = await _storage.read(key: _userIdKey);
    final email = await _storage.read(key: _emailKey);
    if (userId == null || email == null || userId.trim().isEmpty || email.trim().isEmpty) {
      return null;
    }
    return Session(
      userId: userId,
      email: email,
      authProvider: await _storage.read(key: _providerKey) ?? 'email',
      providerUserId: await _storage.read(key: _providerUserIdKey),
      displayName: await _storage.read(key: _displayNameKey),
    );
  }

  @override
  Future<void> saveSession(Session session) async {
    await _storage.write(key: _userIdKey, value: session.userId);
    await _storage.write(key: _emailKey, value: session.email);
    await _storage.write(key: _providerKey, value: session.authProvider);
    if (session.providerUserId == null || session.providerUserId!.isEmpty) {
      await _storage.delete(key: _providerUserIdKey);
    } else {
      await _storage.write(key: _providerUserIdKey, value: session.providerUserId!);
    }
    if (session.displayName == null || session.displayName!.isEmpty) {
      await _storage.delete(key: _displayNameKey);
    } else {
      await _storage.write(key: _displayNameKey, value: session.displayName!);
    }
  }

  @override
  Future<void> clearSession() async {
    await _storage.delete(key: _userIdKey);
    await _storage.delete(key: _emailKey);
    await _storage.delete(key: _providerKey);
    await _storage.delete(key: _providerUserIdKey);
    await _storage.delete(key: _displayNameKey);
  }
}
