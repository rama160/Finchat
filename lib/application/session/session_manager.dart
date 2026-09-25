import 'package:flutter/foundation.dart';

import '../../domain/entities/session.dart';
import '../../domain/repositories/session_repository.dart';

class SessionManager extends ChangeNotifier {
  SessionManager(this._repository);

  final SessionRepository _repository;
  Session? _session;
  bool _initialized = false;

  Session? get session => _session;
  bool get initialized => _initialized;
  bool get isAuthenticated => _session != null;

  Future<void> initialize() async {
    _session = await _repository.getCurrentSession();
    _initialized = true;
    notifyListeners();
  }

  Future<void> login({required String email}) async {
    final normalized = email.trim();
    if (normalized.isEmpty) return;
    final session = Session(userId: normalized, email: normalized);
    await _repository.saveSession(session);
    _session = session;
    notifyListeners();
  }

  Future<void> logout() async {
    await _repository.clearSession();
    _session = null;
    notifyListeners();
  }
}
