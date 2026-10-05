
import 'dart:convert';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleSignInCoordinator {
  GoogleSignInCoordinator({
    GoogleSignIn? signIn,
    String? serverClientId,
  })  : _signIn = signIn ?? GoogleSignIn.instance,
        _serverClientId = serverClientId ?? _defaultServerClientId;

  static final GoogleSignInCoordinator instance =
      GoogleSignInCoordinator();

  static const String _defaultServerClientId =
      '515697505386-r2ahk5fv1oa93dh6549h25ekllo85rfq.apps.googleusercontent.com';

  final GoogleSignIn _signIn;
  String? _serverClientId;
  Future<void>? _initialization;
  GoogleSignInAccount? _account;

  void rememberAccount(GoogleSignInAccount account) => _account = account;
  void clearAccount() => _account = null;

  Future<String?> currentIdToken() async {
    await initialize();
    final cached = _account?.authentication.idToken;
    if (_isFresh(cached)) return cached;
    final restored = await _signIn.attemptLightweightAuthentication();
    if (restored != null) _account = restored;
    final token = _account?.authentication.idToken;
    return _isFresh(token) ? token : null;
  }

  bool _isFresh(String? token) {
    if (token == null || token.trim().isEmpty) return false;
    try {
      final payload = jsonDecode(utf8.decode(base64Url.decode(base64Url.normalize(token.split('.')[1]))));
      final exp = payload['exp'];
      return exp is num && exp * 1000 > DateTime.now().millisecondsSinceEpoch + 60000;
    } catch (_) {
      return false;
    }
  }

  GoogleSignIn get signIn => _signIn;

  void configure({String? serverClientId}) {
    if (_initialization != null) {
      return;
    }

    if (serverClientId != null && serverClientId.trim().isNotEmpty) {
      _serverClientId = serverClientId.trim();
    }
  }

  Future<void> initialize() {
    return _initialization ??= _signIn.initialize(
      serverClientId: _serverClientId,
    );
  }
}
