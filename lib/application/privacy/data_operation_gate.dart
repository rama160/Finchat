/// Serialize explicit deletion with backups so an older upload cannot restore
/// a deleted user's data after the deletion finishes.
abstract final class DataOperationGate {
  static Future<void> _tail = Future<void>.value();
  static bool _deleting = false;
  static Future<T> _run<T>(Future<T> Function() action) {
    final task = _tail.then((_) => action());
    _tail = task.then<void>((_) {}, onError: (Object _, StackTrace __) {});
    return task;
  }
  static Future<T> backup<T>(Future<T> Function() action) {
    if (_deleting) return Future<T>.error(StateError('Penghapusan data sedang berlangsung.'));
    return _run(action);
  }
  static Future<T> deletion<T>(Future<T> Function() action) async {
    if (_deleting) throw StateError('Penghapusan data sedang berlangsung.');
    _deleting = true;
    try { return await _run(action); } finally { _deleting = false; }
  }
}
