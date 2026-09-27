import '../entities/session.dart';

abstract interface class SessionRepository {
  Future<Session?> getCurrentSession();
  Future<void> saveSession(Session session);
  Future<void> clearSession();
}
