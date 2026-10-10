import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis_auth/googleapis_auth.dart' as auth;

import '../auth/google_sign_in_coordinator.dart';

class GoogleDriveAuthService {
  GoogleDriveAuthService({GoogleSignInCoordinator? coordinator})
    : _coordinator = coordinator ?? GoogleSignInCoordinator.instance;

  final GoogleSignInCoordinator _coordinator;
  static const scopes = <String>[
    'https://www.googleapis.com/auth/drive.appdata',
  ];

  Future<void> initialize() async {
    await _coordinator.initialize();
  }

  GoogleSignInAccount? get currentUser => _coordinator.currentAccount;

  Future<GoogleSignInAccount> signIn() async {
    await initialize();
    if (!_coordinator.signIn.supportsAuthenticate()) {
      throw StateError(
        'Google Sign-In pada platform ini tidak menyediakan authenticate().',
      );
    }
    final user = await _coordinator.signIn.authenticate();
    _coordinator.rememberAccount(user);
    return user;
  }

  Future<auth.AuthClient?> tryAuthorizeDriveSilently() async {
    await initialize();
    final user = currentUser;
    // No authenticate/lightweight restore here: both can show Android UI.
    // This API returns null rather than prompting when consent is unavailable.
    final authorization =
        await (user?.authorizationClient ??
                _coordinator.signIn.authorizationClient)
            .authorizationForScopes(scopes);
    return authorization?.authClient(scopes: scopes);
  }

  Future<auth.AuthClient> authorizeDrive() async {
    await initialize();
    final user = currentUser ?? await signIn();
    var authorization = await user.authorizationClient.authorizationForScopes(
      scopes,
    );
    authorization ??= await user.authorizationClient.authorizeScopes(scopes);
    return authorization.authClient(scopes: scopes);
  }

  Future<void> signOut() async {
    await initialize();
    await _coordinator.signIn.signOut();
    _coordinator.clearAccount();
  }
}
