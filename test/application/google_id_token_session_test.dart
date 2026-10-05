import 'dart:async';
import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:finchat/application/auth/google_id_token_session.dart';

String token(int seconds) => 'header.${base64Url.encode(utf8.encode(jsonEncode({'exp': DateTime.now().millisecondsSinceEpoch ~/ 1000 + seconds})))}.signature';

void main() {
  test('logged-in valid token does not attempt lightweight authentication', () async {
    final session = GoogleIdTokenSession();
    final valid = token(3600);
    session.remember(valid);
    var calls = 0;
    expect(await session.current(() async { calls++; return null; }), valid);
    expect(calls, 0);
  });
  test('expired token restores once and never sends expired or malformed token', () async {
    final session = GoogleIdTokenSession();
    session.remember(token(-10));
    final valid = token(3600);
    expect(await session.current(() async => valid), valid);
    session.remember('malformed');
    expect(await session.current(() async => null), isNull);
  });
  test('logout clears token and ignores late authentication restoration', () async {
    final session = GoogleIdTokenSession();
    final pending = Completer<String?>();
    final result = session.current(() => pending.future);
    session.clear();
    pending.complete(token(3600));
    expect(await result, isNull);
    expect(await session.current(() async => null), isNull);
  });
  test('concurrent AI requests share authentication restoration', () async {
    final session = GoogleIdTokenSession();
    final pending = Completer<String?>();
    var calls = 0;
    Future<String?> restore() { calls++; return pending.future; }
    final first = session.current(restore);
    final second = session.current(restore);
    pending.complete(token(3600));
    expect(await first, await second);
    expect(calls, 1);
  });
}
