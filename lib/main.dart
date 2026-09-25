import 'package:flutter/material.dart';

import 'application/session/session_manager.dart';
import 'data/repositories/in_memory_session_repository.dart';
import 'presentation/navigation/app_router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final sessionManager = SessionManager(InMemorySessionRepository());
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
        title: 'FinChat',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
          useMaterial3: true,
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
