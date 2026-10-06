import 'package:flutter/material.dart';

import 'application/auth/google_auth_service.dart';
import 'application/auth/google_sign_in_coordinator.dart';
import 'application/session/session_manager.dart';
import 'data/session/secure_session_repository.dart';
import 'presentation/navigation/app_router.dart';
import 'presentation/widgets/spenva_brand.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final googleServerClientId = const String.fromEnvironment('FINCHAT_GOOGLE_SERVER_CLIENT_ID');
  final googleAuth = GoogleAuthService(
    serverClientId: googleServerClientId.isEmpty ? null : googleServerClientId,
  );
  GoogleSignInCoordinator.instance.configure(
    serverClientId: googleServerClientId.isEmpty ? null : googleServerClientId,
  );
  final sessionManager = SessionManager(
    SecureSessionRepository(),
    googleAuth: googleAuth,
  );
  await sessionManager.initialize();
  runApp(FinChatApp(sessionManager: sessionManager));
}

class FinChatApp extends StatelessWidget {
  const FinChatApp({super.key, required this.sessionManager});

  final SessionManager sessionManager;

  @override
  Widget build(BuildContext context) {
    return SessionScope(
      sessionManager: sessionManager,
      child: MaterialApp.router(
        title: 'Spenva',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: spenvaPurple),
          useMaterial3: true,
          fontFamily: 'SpenvaSans',
          scaffoldBackgroundColor: spenvaBackground,
          appBarTheme: const AppBarTheme(backgroundColor: spenvaBackground, surfaceTintColor: Colors.transparent),
          cardTheme: CardThemeData(color: Colors.white, elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22))),
          filledButtonTheme: FilledButtonThemeData(style: FilledButton.styleFrom(
            backgroundColor: spenvaPurple, padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12))),
        ),
        routerConfig: AppRouter(sessionManager).router,
      ),
    );
  }
}

class SessionScope extends InheritedNotifier<SessionManager> {
  const SessionScope({super.key, required SessionManager sessionManager, required super.child})
      : super(notifier: sessionManager);

  static SessionManager of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<SessionScope>();
    assert(scope != null, 'SessionScope is missing above this widget.');
    return scope!.notifier!;
  }
}
