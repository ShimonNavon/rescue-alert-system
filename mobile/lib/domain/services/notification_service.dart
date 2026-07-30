import 'dart:async';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:rescue_app/domain/services/api/rest_api_service.dart';
import 'package:rescue_app/firebase_options.dart';
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
    required RestApiService apiClient,
    required DeviceService deviceService,
  })  : _authService = authService,
        _deepLinkService = deepLinkService,
        _apiClient = apiClient,
        _deviceService = deviceService;

  final AuthService _authService;
  final DeepLinkService _deepLinkService;
  final RestApiService _apiClient;
  final DeviceService _deviceService;

  final _localNotifications = FlutterLocalNotificationsPlugin();
  StreamSubscription<RemoteMessage>? _foregroundSub;
  StreamSubscription<String>? _tokenRefreshSub;
  StreamSubscription<User?>? _authStateSub;

  Future<void> initialize() async {
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    await _initLocalNotifications();

    final messaging = FirebaseMessaging.instance;
    await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    await messaging.requestPermission(alert: true, badge: true, sound: true);

    _tokenRefreshSub = messaging.onTokenRefresh.listen(_registerToken);
    _foregroundSub = FirebaseMessaging.onMessage.listen(
      _handleForegroundMessage,
    );
    _authStateSub = _authService.authStateChanges.listen((user) async {
      if (user != null) {
        await registerCurrentToken();
      }
    });
    FirebaseMessaging.onMessageOpenedApp.listen(_handleRemoteMessage);

    final initialMessage = await messaging.getInitialMessage();
    if (initialMessage != null) {
      _handleRemoteMessage(initialMessage);
    }

    await registerCurrentToken();
  }

  Future<void> registerCurrentToken() async {
    if (Platform.isIOS) {
      await _waitForApnsToken();
    }

    final token = await FirebaseMessaging.instance.getToken();
    if (token != null) {
      await _registerToken(token);
      return;
    }

    debugPrint(
        'FCM token not available yet; will register when Firebase refreshes it.');
  }

  Future<void> _waitForApnsToken() async {
    if (!Platform.isIOS) {
      return;
    }

    for (int i = 0; i < 10; i++) {
      final apnsToken = await FirebaseMessaging.instance.getAPNSToken();
      if (apnsToken != null) {
        debugPrint('APNS token: $apnsToken');
        return;
      }

      await Future.delayed(const Duration(seconds: 1));
    }

    debugPrint('APNS token not available yet; continuing without throwing.');
  }

  Future<void> _initLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    await _localNotifications.initialize(
      settings: const InitializationSettings(
          android: androidSettings, iOS: iosSettings),
      onDidReceiveNotificationResponse: (details) {
        if (details.payload != null) {
          _deepLinkService.setPendingRoute(details.payload!);
        }
      },
    );

    if (Platform.isIOS) {
      await _localNotifications
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(alert: true, badge: true, sound: true);
    }

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
      id: notification.hashCode,
      title: notification.title,
      body: notification.body,
      notificationDetails: NotificationDetails(
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
    await _authStateSub?.cancel();
  }
}
