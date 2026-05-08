import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trus_app/config.dart';
import 'package:trus_app/firebase_options.dart';
import 'package:trus_app/models/api/log/log_api_model.dart';

import '../features/general/repository/crud_api_service.dart';
import '../models/api/notification/push/device_token_api_model.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // ignore: avoid_print
  print('[push-diagnostics][background] '
      'id=${message.messageId} data=${message.data} '
      'notifTitle=${message.notification?.title} notifBody=${message.notification?.body}');
}

class NotificationsService {
  static final FlutterLocalNotificationsPlugin _localNotifications =
  FlutterLocalNotificationsPlugin();

  static bool _backgroundHandlerRegistered = false;
  static bool _localNotificationsInitialized = false;
  static bool _listenersRegistered = false;

  static Future<void> initialize(Ref ref) async {
    await _d('init_start', ref, {
      'firebaseProjectId': DefaultFirebaseOptions.currentPlatform.projectId,
      'firebaseAppId': DefaultFirebaseOptions.currentPlatform.appId,
      'firebaseSenderId':
      DefaultFirebaseOptions.currentPlatform.messagingSenderId,
    });

    await _registerBackgroundHandlerOnce(ref);
    await _requestPlatformPermissionsIfNeeded(ref);
    await _initLocalNotificationsOnce(ref);

    await syncCurrentTokenWithBackend(ref);
    await _registerListenersOnce(ref);

    final initialMsg = await FirebaseMessaging.instance.getInitialMessage();

    if (initialMsg != null) {
      await _d('getInitialMessage', ref, _serializeMessage(initialMsg));
    } else {
      await _d('getInitialMessage_none', ref);
    }

    await _d('init_ready', ref, {
      'isIOS': Platform.isIOS,
      'isAndroid': Platform.isAndroid,
    });
  }

  static Future<void> _registerBackgroundHandlerOnce(Ref ref) async {
    if (_backgroundHandlerRegistered) {
      await _d('background_handler_already_registered', ref);
      return;
    }

    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    _backgroundHandlerRegistered = true;

    await _d('background_handler_registered', ref);
  }

  static Future<void> _requestPlatformPermissionsIfNeeded(Ref ref) async {
    if (Platform.isIOS) {
      final settings = await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      await _d('ios_permission', ref, {
        'authorizationStatus': settings.authorizationStatus.toString(),
        'alert': settings.alert,
        'badge': settings.badge,
        'sound': settings.sound,
        'timeSensitive': settings.timeSensitive,
        'criticalAlert': settings.criticalAlert,
        'announcement': settings.announcement,
        'carPlay': settings.carPlay,
        'lockScreen': settings.lockScreen,
        'notificationCenter': settings.notificationCenter,
      });

      await FirebaseMessaging.instance
          .setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      await _d('ios_foreground_presentation_set', ref, {
        'alert': true,
        'badge': true,
        'sound': true,
      });

      await FirebaseMessaging.instance.setAutoInitEnabled(true);

      final autoInit = FirebaseMessaging.instance.isAutoInitEnabled;
      await _d('ios_auto_init', ref, {'isAutoInitEnabled': autoInit});

      String? apnsToken = await FirebaseMessaging.instance.getAPNSToken();
      await _d('ios_apns_token_first', ref, {'apnsToken': apnsToken});

      if (apnsToken == null) {
        await Future<void>.delayed(const Duration(seconds: 2));
        apnsToken = await FirebaseMessaging.instance.getAPNSToken();

        await _d('ios_apns_token_retry', ref, {'apnsToken': apnsToken});
      }

      final nsettings =
      await FirebaseMessaging.instance.getNotificationSettings();

      await _d('ios_getNotificationSettings', ref, {
        'authorizationStatus': nsettings.authorizationStatus.toString(),
        'alert': nsettings.alert,
        'badge': nsettings.badge,
        'sound': nsettings.sound,
        'timeSensitive': nsettings.timeSensitive,
        'criticalAlert': nsettings.criticalAlert,
      });
    }

    if (Platform.isAndroid) {
      final settings = await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      await _d('android_permission', ref, {
        'authorizationStatus': settings.authorizationStatus.toString(),
      });
    }
  }

  static Future<void> _initLocalNotificationsOnce(Ref ref) async {
    if (_localNotificationsInitialized) {
      await _d('local_notifications_already_initialized', ref);
      return;
    }

    const AndroidInitializationSettings androidInitSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosInitSettings =
    DarwinInitializationSettings();

    const InitializationSettings initSettings = InitializationSettings(
      android: androidInitSettings,
      iOS: iosInitSettings,
    );

    final initResult = await _localNotifications.initialize(initSettings);

    _localNotificationsInitialized = true;

    await _d('local_notifications_initialized', ref, {
      'result': initResult,
    });
  }

  static Future<void> _registerListenersOnce(Ref ref) async {
    if (_listenersRegistered) {
      await _d('listeners_already_registered', ref);
      return;
    }

    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
      await _d('fcm_token_refresh', ref, {'newToken': newToken});
      await _sendTokenToBackend(newToken, ref);
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      await _d(
        'onMessage_foreground_received',
        ref,
        _serializeMessage(message),
      );

      if (message.data.isNotEmpty) {
        await _d('onMessage_show_local_from_data', ref, {
          'title': message.data['title'],
          'body': message.data['body'],
        });

        await _showLocalNotificationFromData(message.data);
      } else if (message.notification != null) {
        await _d('onMessage_show_local_from_notification', ref, {
          'title': message.notification?.title,
          'body': message.notification?.body,
        });

        await _showLocalNotification(message);
      } else {
        await _d('onMessage_no_payload_to_show', ref);
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
      await _d('onMessageOpenedApp', ref, _serializeMessage(message));
    });

    _listenersRegistered = true;

    await _d('listeners_registered', ref);
  }

  static Future<String?> syncCurrentTokenWithBackend(Ref ref) async {
    final tokenStart = DateTime.now();
    final token = await FirebaseMessaging.instance.getToken();
    final tokenDuration = DateTime.now().difference(tokenStart).inMilliseconds;

    if (token == null) {
      await _d('fcm_token_null', ref, {
        'fetchMs': tokenDuration,
        'hints': [
          'Zkus znovu povolit oprávnění k oznámením.',
          'Ověř připojení k internetu.',
          'Na iOS zkontroluj APNs a Firebase konfiguraci.',
        ],
      });

      return null;
    }

    await _d('fcm_token_acquired', ref, {
      'token': token,
      'fetchMs': tokenDuration,
    });

    await _sendTokenToBackend(token, ref);

    return token;
  }

  static Future<void> sendTestPushToThisDevice(Ref ref) async {
    final token = await syncCurrentTokenWithBackend(ref);

    if (token == null || token.isEmpty) {
      throw Exception("FCM token není dostupný");
    }

    final clientDeviceId = await getOrCreateClientDeviceId();

    final crud = CrudApiService(ref);

    final model = DeviceTokenApiModel(
      token: token,
      clientDeviceId: clientDeviceId,
    );

    await crud.executePostRequest<void>(
      Uri.parse("$serverUrl/$tokenApi/test"),
          (_) => null,
      jsonEncode(model.toJson()),
    );

    await _d('test_push_sent_request_done', ref, {
      'token': token,
      'clientDeviceId': clientDeviceId,
    });
  }

  static Future<void> _sendTokenToBackend(String token, Ref ref) async {
    try {
      final crud = CrudApiService(ref);
      final clientDeviceId = await getOrCreateClientDeviceId();

      await crud.addModel<DeviceTokenApiModel>(
        DeviceTokenApiModel(
          token: token,
          clientDeviceId: clientDeviceId,
        ),
      );

      await _d('token_sent_to_backend', ref, {
        'token': token,
        'clientDeviceId': clientDeviceId,
      });
    } catch (e, st) {
      await _d('token_send_error', ref, {
        'error': e.toString(),
        'stack': st.toString(),
      });

      if (kDebugMode) rethrow;
    }
  }

  static Future<String> getOrCreateClientDeviceId() async {
    final pref = await SharedPreferences.getInstance();

    final existing = pref.getString("clientDeviceId");

    if (existing != null && existing.isNotEmpty) {
      return existing;
    }

    final random = Random.secure();

    final bytes = List<int>.generate(
      16,
          (_) => random.nextInt(256),
    );

    final id = bytes
        .map((byte) => byte.toRadixString(16).padLeft(2, '0'))
        .join();

    await pref.setString("clientDeviceId", id);

    return id;
  }

  static Future<void> _sendLogToBackend(String message, Ref ref) async {
    try {
      final crud = CrudApiService(ref);

      await crud.addModel(
        LogApiModel(
          message: message,
          logClass: "NotificationsService",
        ),
      );
    } catch (e) {
      if (kDebugMode) {
        // ignore: only_throw_errors
        throw e;
      }
    }
  }

  static Future<void> _d(
      String label,
      Ref ref, [
        Map<String, dynamic>? extra,
      ]) async {
    final payload = <String, dynamic>{
      'label': label,
      'ts': DateTime.now().toIso8601String(),
      'platform': kIsWeb
          ? 'web'
          : Platform.isIOS
          ? 'iOS'
          : Platform.isAndroid
          ? 'Android'
          : Platform.operatingSystem,
      if (!kIsWeb) 'osVersion': Platform.operatingSystemVersion,
      'isDebug': kDebugMode,
      if (extra != null) ...extra,
    };

    await _sendLogToBackend(
      '[push-diagnostics] ${jsonEncode(payload)}',
      ref,
    );

    if (kDebugMode) {
      // ignore: avoid_print
      print('[push-diagnostics] $label :: ${jsonEncode(extra ?? {})}');
    }
  }

  static Map<String, dynamic> _serializeMessage(RemoteMessage msg) {
    return {
      'messageId': msg.messageId,
      'senderId': msg.senderId,
      'from': msg.from,
      'category': msg.category,
      'collapseKey': msg.collapseKey,
      'sentTime': msg.sentTime?.toIso8601String(),
      'ttl': msg.ttl,
      'contentAvailable': msg.contentAvailable,
      'mutableContent': msg.mutableContent,
      'dataKeys': msg.data.keys.toList(),
      'data': msg.data,
      'notification': msg.notification == null
          ? null
          : {
        'title': msg.notification?.title,
        'body': msg.notification?.body,
        'android': {
          'channelId': msg.notification?.android?.channelId,
          'count': msg.notification?.android?.count,
          'imageUrl': msg.notification?.android?.imageUrl,
          'link': msg.notification?.android?.link,
          'smallIcon': msg.notification?.android?.smallIcon,
          'sound': msg.notification?.android?.sound,
          'ticker': msg.notification?.android?.ticker,
          'visibility':
          msg.notification?.android?.visibility.toString(),
          'priority': msg.notification?.android?.priority.toString(),
        },
        'apple': {
          'subtitle': msg.notification?.apple?.subtitle,
          'subtitleLocKey': msg.notification?.apple?.subtitleLocKey,
          'imageUrl': msg.notification?.apple?.imageUrl,
          'sound': msg.notification?.apple?.sound?.name,
          'badge': msg.notification?.apple?.badge,
        },
      },
    };
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
      Map<String, dynamic> data,
      ) async {
    final title = data['title'] ?? 'Notifikace';
    final body = data['body'] ?? '';

    const AndroidNotificationDetails androidDetails =
    AndroidNotificationDetails(
      'default_channel',
      'Obecné',
      importance: Importance.max,
      priority: Priority.high,
      styleInformation: BigTextStyleInformation(''),
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