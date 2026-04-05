import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../screens/login_screen.dart';
import '../screens/map_screen.dart';
import '../screens/dashboard_screen.dart';
import '../screens/message_details_screen.dart';
import '../screens/message_queue_screen.dart';
import '../screens/root_shell_screen.dart';
import '../screens/settings_screen.dart';
import '../services/auth_service.dart';
import '../services/deeplink_service.dart';

class AppRouter {
  AppRouter({
    required AuthService authService,
    required DeepLinkService deepLinkService,
  }) : _authService = authService,
       _deepLinkService = deepLinkService {
    _authSub = _authService.authStateChanges.listen(
      (_) => _refreshController.add(null),
    );
    _linkSub = _deepLinkService.linkStream.listen(
      (_) => _refreshController.add(null),
    );
  }

  final AuthService _authService;
  final DeepLinkService _deepLinkService;
  final StreamController<void> _refreshController =
      StreamController<void>.broadcast();
  late final StreamSubscription _authSub;
  late final StreamSubscription _linkSub;

  late final GoRouter router = GoRouter(
    initialLocation: '/login',
    refreshListenable: GoRouterRefreshStream(_refreshController.stream),
    redirect: (context, state) {
      final isAuthenticated = _authService.currentUser != null;
      final isOnLogin = state.matchedLocation == '/login';
      final pendingLink = _deepLinkService.consumePendingRoute();
      if (pendingLink != null && isAuthenticated) {
        return pendingLink;
      }
      if (!isAuthenticated && !isOnLogin) {
        return '/login';
      }
      if (isAuthenticated && isOnLogin) {
        return '/map';
      }
      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      ShellRoute(
        builder: (context, state, child) => RootShellScreen(child: child),
        routes: [
          GoRoute(path: '/map', builder: (context, state) => const MapScreen()),
          GoRoute(
            path: '/dashboard',
            builder: (context, state) => const DashboardScreen(),
          ),
          GoRoute(
            path: '/messages',
            builder: (context, state) => const MessageQueueScreen(),
            routes: [
              GoRoute(
                path: ':id',
                builder: (context, state) => MessageDetailsScreen(
                  messageId: state.pathParameters['id']!,
                ),
              ),
            ],
          ),
          GoRoute(
            path: '/settings',
            builder: (context, state) => const SettingsScreen(),
          ),
        ],
      ),
    ],
  );

  void dispose() {
    _authSub.cancel();
    _linkSub.cancel();
    _refreshController.close();
  }
}

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListener = () => notifyListeners();
    _subscription = stream.asBroadcastStream().listen((_) => notifyListener());
  }

  late final VoidCallback notifyListener;
  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
