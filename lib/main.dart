import 'dart:async';

import 'package:flutter/material.dart';

import 'core/release/play_release_config.dart';
import 'application/billing/play_billing_service.dart';

import 'application/auth/google_auth_service.dart';
import 'application/auth/google_sign_in_coordinator.dart';
import 'application/session/session_manager.dart';
import 'data/session/secure_session_repository.dart';
import 'presentation/navigation/app_router.dart';
import 'presentation/widgets/spenva_brand.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final googleServerClientId = const String.fromEnvironment(
    'FINCHAT_GOOGLE_SERVER_CLIENT_ID',
  );
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
  if (PlayReleaseConfig.isPlay)
    unawaited(
      PlayBillingService.instance.initialize().catchError((Object _) {}),
    );
}

class FinChatApp extends StatefulWidget {
  const FinChatApp({super.key, required this.sessionManager});

  final SessionManager sessionManager;

  @override
  State<FinChatApp> createState() => _FinChatAppState();
}

class _FinChatAppState extends State<FinChatApp> {
  late RouterConfig<Object> _router = AppRouter(widget.sessionManager).router;

  void _disposeRouter() {
    final delegate = _router.routerDelegate;
    final provider = _router.routeInformationProvider;
    if (delegate is ChangeNotifier) delegate.dispose();
    if (provider is ChangeNotifier) provider.dispose();
  }

  @override
  void didUpdateWidget(FinChatApp oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.sessionManager, widget.sessionManager)) {
      _disposeRouter();
      _router = AppRouter(widget.sessionManager).router;
    }
  }

  @override
  void dispose() {
    _disposeRouter();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SessionScope(
      sessionManager: widget.sessionManager,
      child: MaterialApp.router(
        title: 'Spenva',
        debugShowCheckedModeBanner: false,
        theme: spenvaTheme(),
        routerConfig: _router,
      ),
    );
  }
}

class SessionScope extends InheritedNotifier<SessionManager> {
  const SessionScope({
    super.key,
    required SessionManager sessionManager,
    required super.child,
  }) : super(notifier: sessionManager);

  static SessionManager of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<SessionScope>();
    assert(scope != null, 'SessionScope is missing above this widget.');
    return scope!.notifier!;
  }
}
