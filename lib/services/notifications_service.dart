import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/firebase_options.dart';
import 'package:trus_app/models/api/log/log_api_model.dart';

import '../features/general/repository/crud_api_service.dart';
import '../models/api/notification/push/device_token_api_model.dart';

/// Background handler – musí být top-level nebo static
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  if (kDebugMode) {
    print('Background zpráva: ${message.messageId}');
  }
}

class NotificationsService {
  static final FlutterLocalNotificationsPlugin _localNotifications =
  FlutterLocalNotificationsPlugin();

  static Future<void> initialize(Ref ref) async {
    // Background handler
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // Android permission
    if (Platform.isAndroid) {
      final messaging = FirebaseMessaging.instance;
      final settings = await messaging.requestPermission();
      _sendLogToBackend(
          'Android permission status: ${settings.authorizationStatus}', ref);
      if (kDebugMode) {
        print('Android permission status: ${settings.authorizationStatus}');
      }
    }

    // iOS permission + extra logy
    if (Platform.isIOS) {
      final settings = await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      _sendLogToBackend(
          'iOS permission status: ${settings.authorizationStatus} '
              '(alert=${settings.alert}, badge=${settings.badge}, sound=${settings.sound})',
          ref);
      print(
          'iOS permission status: ${settings.authorizationStatus} (alert=${settings.alert}, badge=${settings.badge}, sound=${settings.sound})');

      // Zjistit autoInit
      await FirebaseMessaging.instance.setAutoInitEnabled(true);
      final autoInit = FirebaseMessaging.instance.isAutoInitEnabled;
      _sendLogToBackend('iOS isAutoInitEnabled: $autoInit', ref);

      // Log APNs tokenu
      final apnsToken = await FirebaseMessaging.instance.getAPNSToken();
      _sendLogToBackend('APNs Token: $apnsToken', ref);
      print('APNs Token: $apnsToken');
    }

    // Local notifications init
    const AndroidInitializationSettings androidInitSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosInitSettings =
    DarwinInitializationSettings();
    const InitializationSettings initSettings = InitializationSettings(
      android: androidInitSettings,
      iOS: iosInitSettings,
    );
    await _localNotifications.initialize(initSettings);

    // --- TOKEN handling ---
    final token = await FirebaseMessaging.instance.getToken();
    if (token == null) {
      _sendLogToBackend('FCM getToken() returned NULL', ref);
      print('FCM getToken() returned NULL');
    } else {
      _sendLogToBackend('FCM Token acquired: $token', ref);
      print('FCM Token: $token');
      await _sendTokenToBackend(token, ref);
    }

    // Pokud se token změní
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
      _sendLogToBackend('FCM Token refresh: $newToken', ref);
      if (kDebugMode) {
        print('FCM Token refresh: $newToken');
      }
      await _sendTokenToBackend(newToken, ref);
    });

    // Foreground zprávy
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _sendLogToBackend('Foreground zpráva: ${message.data}', ref);
      if (kDebugMode) {
        print('Doručena foreground zpráva: ${message.data}');
      }

      if (message.data.isNotEmpty) {
        _showLocalNotificationFromData(message.data);
      } else if (message.notification != null) {
        _showLocalNotification(message);
      }
    });

    // Kliknutí na notifikaci
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _sendLogToBackend(
          'Notifikace otevřena: ${message.notification?.title}', ref);
      if (kDebugMode) {
        print('Notifikace otevřena: ${message.notification?.title}');
      }
    });
  }

  /// Pošle token na backend
  static Future<void> _sendTokenToBackend(String token, Ref ref) async {
    try {
      final crud = CrudApiService(ref);
      await crud.addModel(DeviceTokenApiModel(token: token));
      _sendLogToBackend("Token $token poslán na backend přes CrudApiService", ref);
      if (kDebugMode) {
        print("Token $token poslán na backend přes CrudApiService");
      }
    } catch (e) {
      _sendLogToBackend("Chyba při posílání tokenu: $e", ref);
      if (kDebugMode) {
        rethrow;
      }
    }
  }

  /// Pošle log na backend
  static Future<void> _sendLogToBackend(String message, Ref ref) async {
    try {
      final crud = CrudApiService(ref);
      await crud.addModel(
          LogApiModel(message: message, logClass: "NotificationsService"));
    } catch (e) {
      if (kDebugMode) {
        rethrow;
      }
    }
  }

  static Future<void> _showLocalNotification(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    const AndroidNotificationDetails androidDetails =
    AndroidNotificationDetails(
      'default_channel',
      'Obecné',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails platformDetails =
    NotificationDetails(android: androidDetails);

    await _localNotifications.show(
      notification.hashCode,
      notification.title,
      notification.body,
      platformDetails,
    );
  }

  static Future<void> _showLocalNotificationFromData(
      Map<String, dynamic> data) async {
    final title = data['title'] ?? 'Notifikace';
    final body = data['body'] ?? '';

    const AndroidNotificationDetails androidDetails =
    AndroidNotificationDetails(
      'default_channel',
      'Obecné',
      importance: Importance.max,
      priority: Priority.high,
      styleInformation:
      BigTextStyleInformation(''), // umožní zobrazit dlouhý text
    );

    const NotificationDetails platformDetails =
    NotificationDetails(android: androidDetails);

    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      platformDetails,
    );
  }
}
