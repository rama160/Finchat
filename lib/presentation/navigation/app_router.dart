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
        routeInformationParser: const _Parser(),
        routeInformationProvider: PlatformRouteInformationProvider(
          initialRouteInformation: const RouteInformation(location: '/'),
        ),
      );
}

class _Parser extends RouteInformationParser<Object> {
  const _Parser();
  @override
  Future<Object> parseRouteInformation(RouteInformation routeInformation) async =>
      routeInformation.location ?? '/';
}

class _Delegate extends RouterDelegate<Object> with ChangeNotifier, PopNavigatorRouterDelegateMixin<Object> {
  _Delegate(this.sessionManager) {
    sessionManager.addListener(notifyListeners);
  }

  final SessionManager sessionManager;

  @override
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    if (!sessionManager.initialized) {
      return const Navigator(pages: [MaterialPage(child: SplashScreen())], onPopPage: _pop);
    }
    final page = sessionManager.isAuthenticated
        ? const MaterialPage(child: ChatScreen())
        : const MaterialPage(child: LoginScreen());
    return Navigator(pages: [page], onPopPage: _pop);
  }

  static bool _pop(Route<dynamic> route, dynamic result) => route.didPop(result);

  @override
  Future<void> setNewRoutePath(Object configuration) async {}

  @override
  void dispose() {
    sessionManager.removeListener(notifyListeners);
    super.dispose();
  }
}
