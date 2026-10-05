
import 'google_id_token_session.dart';
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
  final GoogleIdTokenSession _tokenSession = GoogleIdTokenSession();

  void rememberAccount(GoogleSignInAccount account) {
    _tokenSession.remember(account.authentication.idToken);
  }

  void clearAccount() => _tokenSession.clear();

  Future<String?> currentIdToken() async {
    await initialize();
    return _tokenSession.current(() async {
      final restored = await _signIn.attemptLightweightAuthentication();
      return restored?.authentication.idToken;
    });
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
