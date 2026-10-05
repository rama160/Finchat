import 'dart:convert';

/// Holds only a short-lived Google ID token. Gateway verifies its signature.
class GoogleIdTokenSession {
  String? _token;
  int _generation = 0;
  Future<String?>? _refresh;

  void remember(String? token) {
    _generation++;
    _token = token;
  }

  void clear() {
    _generation++;
    _token = null;
    _refresh = null;
  }

  bool _fresh(String? token) {
    if (token == null || token.isEmpty) return false;
    try {
      final payload = jsonDecode(utf8.decode(base64Url.decode(base64Url.normalize(token.split('.')[1]))));
      final exp = payload['exp'];
      return exp is num && exp * 1000 > DateTime.now().millisecondsSinceEpoch + 60000;
    } catch (_) {
      return false;
    }
  }

  Future<String?> current(Future<String?> Function() restore) async {
    if (_fresh(_token)) return _token;
    final pending = _refresh;
    if (pending != null) return pending;
    final generation = _generation;
    final future = _restore(restore, generation);
    _refresh = future;
    try {
      return await future;
    } finally {
      if (identical(_refresh, future)) _refresh = null;
    }
  }

  Future<String?> _restore(Future<String?> Function() restore, int generation) async {
    final token = await restore();
    if (generation != _generation) return _fresh(_token) ? _token : null;
    _token = token;
    return _fresh(_token) ? _token : null;
  }
}
