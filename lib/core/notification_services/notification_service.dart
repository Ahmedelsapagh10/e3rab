import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../init_config/initalization_config.dart';
import '../preferences/preferences.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Background delivery is intentionally passive until a reviewed route exists.
}

class NotificationService {
  NotificationService._();

  static final NotificationService _instance = NotificationService._();

  factory NotificationService() => _instance;

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _local =
      FlutterLocalNotificationsPlugin();
  int _notificationId = 0;

  Future<void> initialize() async {
    if (!isFirebaseInitialized) return;
    if (!kIsWeb) await _initializeLocalNotifications();
    await _initializeFirebaseMessaging();
  }

  Future<void> _initializeFirebaseMessaging() async {
    await _messaging.requestPermission(alert: true, badge: true, sound: true);
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    FirebaseMessaging.onMessage.listen((message) {
      final notification = message.notification;
      if (notification == null || kIsWeb) return;
      _showLocalNotification(
        title: notification.title ?? 'إعراب',
        body: notification.body ?? '',
      );
    });
    try {
      final token = await _messaging.getToken();
      if (token != null) {
        await Preferences.instance.setDeviceToken(token);
      }
    } catch (_) {
      // Push configuration is optional; guest learning remains available.
    }
  }

  Future<void> _initializeLocalNotifications() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwin = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    await _local.initialize(
      settings: const InitializationSettings(android: android, iOS: darwin),
    );
    if (Platform.isAndroid) {
      await _local
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.requestNotificationsPermission();
    }
    if (Platform.isIOS) {
      await _local
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >()
          ?.requestPermissions(alert: true, badge: true, sound: true);
    }
  }

  Future<void> _showLocalNotification({
    required String title,
    required String body,
  }) async {
    const android = AndroidNotificationDetails(
      'e3rab_learning_reminders',
      'تذكيرات التعلّم',
      channelDescription: 'تذكيرات المراجعة والتعلّم في تطبيق إعراب',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );
    await _local.show(
      id: _notificationId++,
      title: title,
      body: body,
      notificationDetails: const NotificationDetails(android: android),
    );
  }
}
