import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import '../exports.dart';
import '../preferences/preferences.dart';
import '../init_config/initalization_config.dart';

bool isWithNotification = false;
String notificationId = "0";
String notificationType = "";
RemoteMessage? initialMessageRcieved;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();

  factory NotificationService() => _instance;

  NotificationService._internal();

  /// Global Key for Navigation
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  /// Firebase Messaging Instance
  FirebaseMessaging get _messaging => FirebaseMessaging.instance;

  /// Local Notifications Plugin
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  int _notificationCounter = 0;

  /// **Initialize Notifications**
  Future<void> initialize() async {
    if (isFirebaseInitialized) {
      await _initializeFirebaseMessaging();
    } else {
      log(
        "Skipping Firebase Messaging initialization as Firebase is not configured.",
      );
    }
    await _initializeLocalNotifications();
  }

  /// **Firebase Messaging Initialization**
  Future<void> _initializeFirebaseMessaging() async {
    // Handle when app is completely closed and opened via notification
    //! [Kill]
    RemoteMessage? initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      initialMessageRcieved = initialMessage;

      // notificationType = initialMessage.data['reference_table'] ?? "";
      // notificationId = initialMessage.data['modal_id'] ?? "";
      //! open
    }

    // Handle notification click when app is in
    //! [ background ]
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    // Handle notification click when app is in
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      initialMessageRcieved = message;

      // if (

      //     message.data['type'] == "office_request") {
      //   navigatorKey.currentState?.pushNamed(Routes.mainLawyerRoute,

      //      );
      // }

      // //!
      // else {
      //   navigatorKey.currentState
      //       ?.pushNamed(Routes.notificationRoute, arguments: userType);
      // }
    });

    // Request notification permissions
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    log('User granted permission: ${settings.authorizationStatus}');

    //! [Forground ]
    FirebaseMessaging.onMessage.listen((message) {
      log("Foreground Message Received: ${message.notification?.title}");
      log("Message Data: ${message.data}");

      /// Check if the message is from a chat room
      final roomId = message.data['modal_id']?.toString();

      if (MessageStateManager().isInChatRoom("0")) {
        log("Already in chat room $roomId - skipping notification");
        return;
      }
      // if (MessageStateManager().isInChatRoom(roomId)) {
      //   log("Already in chat room $roomId - skipping notification");
      //   return;
      // }

      _showLocalNotification(
        title: message.notification?.title ?? '',
        body: message.notification?.body ?? '',
        payload: jsonEncode(message.data), // message.data.toString(),
      );
    });
    await _getToken();
  }

  /// **Handles Background Notifications**
  static Future<void> _firebaseMessagingBackgroundHandler(
    RemoteMessage message,
  ) async {
    initialMessageRcieved = message;
    isWithNotification = true;
    log("Background Message Received: ${message.notification?.title}");
  }

  /// **Fetches and Stores FCM Token**

  Future<String?> _getToken() async {
    try {
      Preferences.instance.init();
      // Request permission (if needed)
      await _messaging.requestPermission();
      // Get the device token
      String? deviceToken = await _messaging.getToken();
      log("token ====>> $deviceToken");
      // Save the token to preferences
      await Preferences.instance.setDeviceToken(deviceToken ?? '');
      return deviceToken;
    } catch (e) {
      log("Error getting token: $e");
      return null;
    }
  }

  /// **Local Notifications Initialization**
  Future<void> _initializeLocalNotifications() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    final InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      settings: initSettings,

      ///! [ON CLIECK LOCAL NOTFICATION]
      onDidReceiveNotificationResponse: (details) {
        final payload = details.payload;
        log('Notification payload: $payload userType==>');

        try {
          if (payload != null) {
            Map<String, dynamic> message;

            message = jsonDecode(payload);

            log('Notification message after parsing: $message');

            //   if (message['type'] == "office_delete_request" ||
            //       message['type'] == "change_type" ||
            //       message['type'] == "court_case_cancel" ||
            //       message['type'] == "office_request") {
            //     navigatorKey.currentState?.pushNamed(Routes.mainLawyerRoute,
            //         arguments: ChooseTypeRegisterArgs(
            //           indexPageClientOrLawyer: userType ? 1 : 0,
            //         ));
          }

          // } else {
          //   // Default action if payload is null
          //   navigatorKey.currentState
          //       ?.pushNamed(Routes.notificationRoute, arguments: userType);
          // }
        } catch (e) {
          log('Error parsing notification payload: $e');

          // navigatorKey.currentState
          //     ?.pushNamed(Routes.notificationRoute, );
        }
      },
    );

    if (!kIsWeb && Platform.isAndroid) {
      await _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.requestNotificationsPermission();
    }

    if (!kIsWeb && Platform.isIOS) {
      await _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >()
          ?.requestPermissions(alert: true, badge: true, sound: true);
    }
  }

  /// **Shows a Local Notification**
  Future<void> _showLocalNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'your_channel_id_ataaby',
          'your_channel_name_ataaby',
          channelDescription: 'your_channel_description_ataaby',
          importance: Importance.max,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
          ticker: 'ticker',
        );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
    );

    await _flutterLocalNotificationsPlugin.show(
      id: _notificationCounter++,
      title: title,
      body: body,
      notificationDetails: notificationDetails,
      payload: payload,
    );
  }
}

class MessageStateManager {
  static final MessageStateManager _instance = MessageStateManager._internal();
  factory MessageStateManager() => _instance;
  MessageStateManager._internal();

  // Track active chat room IDs
  final Set<String> _activeChatRoomIds = {};

  // Methods to update state
  void enterChatRoom(String roomId) {
    _activeChatRoomIds.add(roomId);
    log("Entered chat room: $roomId");
  }

  void leaveChatRoom(String roomId) {
    _activeChatRoomIds.remove(roomId);
    log("Left chat room: $roomId");
  }

  // Check if we're in a specific chat room
  bool isInChatRoom(String? roomId) {
    return roomId != null && _activeChatRoomIds.contains(roomId);
  }
}
