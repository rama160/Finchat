import 'package:google_sign_in/google_sign_in.dart';

class GoogleSignInCoordinator {
  GoogleSignInCoordinator({GoogleSignIn? signIn, String? serverClientId})
      : _signIn = signIn ?? GoogleSignIn.instance,
        _serverClientId = serverClientId;

  static final instance = GoogleSignInCoordinator();

  final GoogleSignIn _signIn;
  String? _serverClientId;
  Future<void>? _initialization;

  GoogleSignIn get signIn => _signIn;

  void configure({String? serverClientId}) {
    if (_initialization != null) return;
    _serverClientId = serverClientId;
  }

  Future<void> initialize() {
    return _initialization ??= _signIn.initialize(
      serverClientId: _serverClientId,
    );
  }
}
