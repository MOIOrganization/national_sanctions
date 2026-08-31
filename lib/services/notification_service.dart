import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import '../firebase_options.dart';

/// Handles FCM messages while the app is in the background or terminated.
///
/// Must remain a top-level function so the background isolate can look it up.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  debugPrint('==============================================');
  debugPrint('[FCM] BACKGROUND MESSAGE');
  debugPrint('[FCM] Message ID: ${message.messageId}');
  debugPrint('[FCM] Title: ${message.notification?.title}');
  debugPrint('[FCM] Body: ${message.notification?.body}');
  debugPrint('[FCM] Data: ${message.data}');
  debugPrint('==============================================');
}

class NotificationService {
  NotificationService._();

  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  static Future<void> initialize() async {
    final NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    debugPrint(
      '[FCM] Notification permission: ${settings.authorizationStatus}',
    );

    final String? token = await _messaging.getToken();

    debugPrint('==============================================');
    debugPrint('FCM TOKEN: $token');
    debugPrint('==============================================');

    _messaging.onTokenRefresh.listen((String newToken) {
      debugPrint('==============================================');
      debugPrint('[FCM] TOKEN REFRESHED: $newToken');
      debugPrint('==============================================');
    });

    FirebaseMessaging.onMessage.listen(_logForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_logNotificationTap);
  }

  static void _logForegroundMessage(RemoteMessage message) {
    debugPrint('==============================================');
    debugPrint('[FCM] FOREGROUND MESSAGE');
    debugPrint('[FCM] Message ID: ${message.messageId}');
    debugPrint('[FCM] Title: ${message.notification?.title}');
    debugPrint('[FCM] Body: ${message.notification?.body}');
    debugPrint('[FCM] Data: ${message.data}');
    debugPrint('==============================================');
  }

  static void _logNotificationTap(RemoteMessage message) {
    debugPrint('==============================================');
    debugPrint('[FCM] NOTIFICATION TAPPED');
    debugPrint('[FCM] Message ID: ${message.messageId}');
    debugPrint('[FCM] Title: ${message.notification?.title}');
    debugPrint('[FCM] Body: ${message.notification?.body}');
    debugPrint('[FCM] Data: ${message.data}');
    debugPrint('==============================================');
  }
}
