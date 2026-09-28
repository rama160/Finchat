import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis_auth/googleapis_auth.dart' as auth;

import '../auth/google_sign_in_coordinator.dart';

class GoogleDriveAuthService {
  GoogleDriveAuthService({GoogleSignInCoordinator? coordinator})
      : _coordinator = coordinator ?? GoogleSignInCoordinator.instance;

  final GoogleSignInCoordinator _coordinator;
  static const scopes = <String>['https://www.googleapis.com/auth/drive.appdata'];
  GoogleSignInAccount? _currentUser;

  Future<void> initialize() async {
    await _coordinator.initialize();
    _currentUser ??= _coordinator.signIn.currentUser;
  }

  GoogleSignInAccount? get currentUser => _currentUser;

  Future<GoogleSignInAccount> signIn() async {
    await initialize();
    if (!_coordinator.signIn.supportsAuthenticate()) {
      throw StateError('Google Sign-In pada platform ini tidak menyediakan authenticate().');
    }
    final user = await _coordinator.signIn.authenticate();
    _currentUser = user;
    return user;
  }

  Future<auth.AuthClient> authorizeDrive() async {
    await initialize();
    final user = _currentUser ?? await signIn();
    var authorization = await user.authorizationClient.authorizationForScopes(scopes);
    authorization ??= await user.authorizationClient.authorizeScopes(scopes);
    return authorization.authClient(scopes: scopes);
  }

  Future<void> signOut() async {
    await initialize();
    await _coordinator.signIn.signOut();
    _currentUser = null;
  }
}
