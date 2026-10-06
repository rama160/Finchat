import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in_platform_interface/google_sign_in_platform_interface.dart';
import 'package:finchat/application/auth/google_sign_in_coordinator.dart';
import 'package:finchat/application/backup/google_drive_auth_service.dart';

class _GooglePlatform extends GoogleSignInPlatform {
  int restoreCalls = 0, authenticateCalls = 0;
  bool granted = false;
  final requests = <AuthorizationRequestDetails>[];
  @override
  bool supportsAuthenticate() => true;
  @override
  bool authorizationRequiresUserInteraction() => false;
  @override
  Future<void> disconnect(DisconnectParams params) async {}
  @override
  Future<void> signOut(SignOutParams params) async {}
  @override
  Future<void> clearAuthorizationToken(ClearAuthorizationTokenParams params) async {}
  @override
  Future<ServerAuthorizationTokenData?> serverAuthorizationTokensForScopes(ServerAuthorizationTokensForScopesParameters params) async => null;
  @override
  Future<void> init(InitParameters params) async {}
  @override
  Future<AuthenticationResults?> attemptLightweightAuthentication(AttemptLightweightAuthenticationParameters params) async {
    restoreCalls++; throw StateError('Background backup must not restore authentication UI');
  }
  @override
  Future<AuthenticationResults> authenticate(AuthenticateParameters params) async {
    authenticateCalls++; throw StateError('Background backup must not prompt');
  }
  @override
  Future<ClientAuthorizationTokenData?> clientAuthorizationTokensForScopes(ClientAuthorizationTokensForScopesParameters params) async {
    requests.add(params.request);
    return granted ? const ClientAuthorizationTokenData(accessToken: 'test-access-token') : null;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('reopened app uses no-prompt Drive authorization and skips unavailable consent', () async {
    final old = GoogleSignInPlatform.instance; final platform = _GooglePlatform();
    GoogleSignInPlatform.instance = platform; addTearDown(() => GoogleSignInPlatform.instance = old);
    final service = GoogleDriveAuthService(coordinator: GoogleSignInCoordinator());
    expect(await service.tryAuthorizeDriveSilently(), isNull);
    expect(platform.restoreCalls, 0); expect(platform.authenticateCalls, 0);
    expect(platform.requests.single.promptIfUnauthorized, isFalse);
    expect(platform.requests.single.scopes, GoogleDriveAuthService.scopes);
    platform.granted = true;
    final client = await service.tryAuthorizeDriveSilently();
    expect(client, isNotNull); client!.close();
    expect(platform.restoreCalls, 0); expect(platform.authenticateCalls, 0);
    expect(platform.requests.last.promptIfUnauthorized, isFalse);
  });
}
