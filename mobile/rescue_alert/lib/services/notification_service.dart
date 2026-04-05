import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'api_client.dart';
import 'auth_service.dart';
import 'deeplink_service.dart';

class NotificationService {
  NotificationService({
    required AuthService authService,
    required DeepLinkService deepLinkService,
    required ApiClient apiClient,
  }) : _authService = authService,
       _deepLinkService = deepLinkService,
       _apiClient = apiClient;

  final AuthService _authService;
  final DeepLinkService _deepLinkService;
  final ApiClient _apiClient;
  StreamSubscription<RemoteMessage>? _foregroundSub;

  Future<void> initialize() async {
    await Firebase.initializeApp();

    final messaging = FirebaseMessaging.instance;
    await messaging.requestPermission(alert: true, badge: true, sound: true);

    final token = await messaging.getToken();
    if (token != null && _authService.currentUser != null) {
      await _apiClient.registerPushToken(token);
    }

    _foregroundSub = FirebaseMessaging.onMessage.listen(_handleRemoteMessage);

    FirebaseMessaging.onMessageOpenedApp.listen(_handleRemoteMessage);
    final initialMessage = await messaging.getInitialMessage();
    if (initialMessage != null) {
      _handleRemoteMessage(initialMessage);
    }
  }

  void _handleRemoteMessage(RemoteMessage message) {
    final deepLink = message.data['deepLink']?.toString();
    final messageId = message.data['messageId']?.toString();
    if (deepLink != null && deepLink.isNotEmpty) {
      _deepLinkService.setPendingRoute(deepLink);
    } else if (messageId != null) {
      _deepLinkService.setPendingRoute('/messages/$messageId');
    }
  }

  Future<void> dispose() async {
    await _foregroundSub?.cancel();
  }
}
