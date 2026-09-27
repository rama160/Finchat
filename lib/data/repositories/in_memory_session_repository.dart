import '../../domain/entities/session.dart';
import '../../domain/repositories/session_repository.dart';

class InMemorySessionRepository implements SessionRepository {
  Session? _session;

  @override
  Future<Session?> getCurrentSession() async => _session;

  @override
  Future<void> saveSession(Session session) async => _session = session;

  @override
  Future<void> clearSession() async => _session = null;
}
