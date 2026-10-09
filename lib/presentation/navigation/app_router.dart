import 'package:flutter/material.dart';

import '../../application/session/session_manager.dart';
import '../screens/chat_screen.dart';
import '../screens/login_screen.dart';
import '../screens/splash_screen.dart';

class AppRouter {
  AppRouter(this.sessionManager);
  final SessionManager sessionManager;

  RouterConfig<Object> get router => RouterConfig<Object>(
    routerDelegate: _Delegate(sessionManager),
    backButtonDispatcher: RootBackButtonDispatcher(),
    routeInformationParser: const _Parser(),
    routeInformationProvider: PlatformRouteInformationProvider(
      initialRouteInformation: RouteInformation(uri: Uri.parse('/')),
    ),
  );
}

class _Parser extends RouteInformationParser<Object> {
  const _Parser();

  @override
  Future<Object> parseRouteInformation(
    RouteInformation routeInformation,
  ) async => routeInformation.uri.toString();
}

class _Delegate extends RouterDelegate<Object>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<Object> {
  _Delegate(this.sessionManager) {
    sessionManager.addListener(notifyListeners);
  }

  final SessionManager sessionManager;

  @override
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    if (!sessionManager.initialized) {
      return Navigator(
        key: navigatorKey,
        pages: const [MaterialPage(child: SplashScreen())],
        onDidRemovePage: _onDidRemovePage,
      );
    }

    final page = sessionManager.isAuthenticated
        ? MaterialPage(
            key: ValueKey(sessionManager.session!.userId),
            child: const ChatScreen(),
          )
        : const MaterialPage(key: ValueKey('login'), child: LoginScreen());

    return Navigator(
      key: navigatorKey,
      pages: [page],
      onDidRemovePage: _onDidRemovePage,
    );
  }

  static void _onDidRemovePage(Page<dynamic> page) {
    // The current page is derived from SessionManager state. There is no
    // separate navigation stack to mutate when the root page is removed.
  }

  @override
  Future<void> setNewRoutePath(Object configuration) async {}

  @override
  void dispose() {
    sessionManager.removeListener(notifyListeners);
    super.dispose();
  }
}
