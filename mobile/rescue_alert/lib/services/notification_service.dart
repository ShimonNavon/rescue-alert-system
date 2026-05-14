import 'dart:async';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../firebase_options.dart';
import 'api_client.dart';
import 'auth_service.dart';
import 'deeplink_service.dart';
import 'device_service.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
}

const _androidChannel = AndroidNotificationChannel(
  'rescue_alerts',
  'Rescue Alerts',
  description: 'Critical rescue alert notifications',
  importance: Importance.max,
);

class NotificationService {
  NotificationService({
    required AuthService authService,
    required DeepLinkService deepLinkService,
    required ApiClient apiClient,
    required DeviceService deviceService,
  })  : _authService = authService,
        _deepLinkService = deepLinkService,
        _apiClient = apiClient,
        _deviceService = deviceService;

  final AuthService _authService;
  final DeepLinkService _deepLinkService;
  final ApiClient _apiClient;
  final DeviceService _deviceService;

  final _localNotifications = FlutterLocalNotificationsPlugin();
  StreamSubscription<RemoteMessage>? _foregroundSub;
  StreamSubscription<String>? _tokenRefreshSub;

  Future<void> initialize() async {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    await _initLocalNotifications();

    final messaging = FirebaseMessaging.instance;
    await messaging.requestPermission(alert: true, badge: true, sound: true);

    _tokenRefreshSub = messaging.onTokenRefresh.listen(_registerToken);
    _foregroundSub = FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleRemoteMessage);

    final initialMessage = await messaging.getInitialMessage();
    if (initialMessage != null) _handleRemoteMessage(initialMessage);
  }

  Future<void> registerCurrentToken() async {
    final token = await FirebaseMessaging.instance.getToken();
    if (token != null) await _registerToken(token);
  }

  Future<void> _initLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    await _localNotifications.initialize(
      const InitializationSettings(android: androidSettings, iOS: iosSettings),
      onDidReceiveNotificationResponse: (details) {
        if (details.payload != null) {
          _deepLinkService.setPendingRoute(details.payload!);
        }
      },
    );

    if (Platform.isAndroid) {
      await _localNotifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(_androidChannel);
    }
  }

  Future<void> _registerToken(String token) async {
    if (_authService.currentUser == null) return;
    try {
      await _apiClient.registerDevice(
        fcmToken: token,
        deviceId: await _deviceService.getDeviceId(),
        platform: _deviceService.getPlatform(),
        deviceModel: await _deviceService.getDeviceModel(),
      );
    } catch (e) {
      debugPrint('Device registration failed: $e');
    }
  }

  void _handleForegroundMessage(RemoteMessage message) {
    final notification = message.notification;
    if (notification == null) return;

    final route = _routeFromData(message.data);
    _localNotifications.show(
      notification.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _androidChannel.id,
          _androidChannel.name,
          channelDescription: _androidChannel.description,
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      payload: route,
    );
  }

  void _handleRemoteMessage(RemoteMessage message) {
    final route = _routeFromData(message.data);
    if (route != null) _deepLinkService.setPendingRoute(route);
  }

  String? _routeFromData(Map<String, dynamic> data) {
    final deepLink = data['deepLink']?.toString();
    if (deepLink != null && deepLink.isNotEmpty) return deepLink;
    final messageId = data['messageId']?.toString();
    if (messageId != null) return '/messages/$messageId';
    return null;
  }

  Future<void> dispose() async {
    await _foregroundSub?.cancel();
    await _tokenRefreshSub?.cancel();
  }
}
