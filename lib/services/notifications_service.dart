import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/firebase_options.dart';
import 'package:http/http.dart' as http;

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
    // Inicializace Firebase Messaging
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // Android 13+ permission
    if (Platform.isAndroid) {
      final messaging = FirebaseMessaging.instance;
      final settings = await messaging.requestPermission();
      if (kDebugMode) {
        print('Android permission status: ${settings.authorizationStatus}');
      }
    }

    // iOS permission
    if (Platform.isIOS) {
      final settings = await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      if (kDebugMode) {
        print('iOS permission status: ${settings.authorizationStatus}');
      }
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
    if (kDebugMode) {
      print('FCM Token: $token');
    }
    if (token != null) {
      await _sendTokenToBackend(token, ref);
    }

    // Pokud se token změní (např. reinstall app, odhlášení Google účtu…)
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
      if (kDebugMode) {
        print('FCM Token refresh: $newToken');
      }
      await _sendTokenToBackend(newToken, ref);
    });

    // Foreground zprávy
    // Foreground zprávy
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (kDebugMode) {
        print('Doručena foreground zpráva: ${message.data}');
      }

      // Na Androidu použijeme vlastní notifikaci s BigTextStyle
      if (message.data.isNotEmpty) {
        _showLocalNotificationFromData(message.data);
      } else if (message.notification != null) {
        // fallback pro iOS (notification payload)
        _showLocalNotification(message);
      }
    });

    // Kliknutí na notifikaci
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      if (kDebugMode) {
        print('Notifikace otevřena: ${message.notification?.title}');
      }
      // Sem můžeš dát navigaci
    });
  }

  /// Pošle token na backend
  static Future<void> _sendTokenToBackend(String token, Ref ref) async {
    try {
      final crud = CrudApiService(ref);
      await crud.addModel(DeviceTokenApiModel(token: token));
      if (kDebugMode) {
        print("Token $token poslán na backend přes CrudApiService");
      }
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
  static Future<void> _showLocalNotificationFromData(Map<String, dynamic> data) async {
    final title = data['title'] ?? 'Notifikace';
    final body = data['body'] ?? '';

    const AndroidNotificationDetails androidDetails =
    AndroidNotificationDetails(
      'default_channel',
      'Obecné',
      importance: Importance.max,
      priority: Priority.high,
      styleInformation: BigTextStyleInformation(''), // umožní zobrazit dlouhý text
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
