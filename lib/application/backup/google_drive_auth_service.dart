import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:googleapis_auth/googleapis_auth.dart' as auth;

class GoogleDriveAuthService {
  GoogleDriveAuthService({this.clientId});

  final String? clientId;
  static const scopes = <String>['https://www.googleapis.com/auth/drive.appdata'];
  GoogleSignInAccount? _currentUser;
  Future<void>? _initialization;

  Future<void> initialize() {
    return _initialization ??= GoogleSignIn.instance.initialize(clientId: clientId).then((_) {
      GoogleSignIn.instance.authenticationEvents.listen((event) {
        switch (event) {
          case GoogleSignInAuthenticationEventSignIn():
            _currentUser = event.user;
          case GoogleSignInAuthenticationEventSignOut():
            _currentUser = null;
        }
      });
    });
  }

  GoogleSignInAccount? get currentUser => _currentUser;

  Future<GoogleSignInAccount> signIn() async {
    await initialize();
    if (!GoogleSignIn.instance.supportsAuthenticate()) {
      throw StateError('Google Sign-In pada platform ini tidak menyediakan authenticate().');
    }
    final user = await GoogleSignIn.instance.authenticate();
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
    await GoogleSignIn.instance.signOut();
    _currentUser = null;
  }
}
