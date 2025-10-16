import 'dart:convert';
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
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // V backgroundu nemáme Ref → pošleme aspoň konzolové logy
  // (chceš-li i backend logy, uděláme later "buffer & flush" strategii).
  // ignore: avoid_print
  print('[push-diagnostics][background] '
      'id=${message.messageId} data=${message.data} '
      'notifTitle=${message.notification?.title} notifBody=${message.notification?.body}');
}

class NotificationsService {
  static final FlutterLocalNotificationsPlugin _localNotifications =
  FlutterLocalNotificationsPlugin();

  /// Jednotný helper pro logování do backendu (s kontextem platformy a času).
  static Future<void> _d(String label, Ref ref,
      [Map<String, dynamic>? extra]) async {
    final payload = <String, dynamic>{
      'label': label,
      'ts': DateTime.now().toIso8601String(),
      'platform': kIsWeb
          ? 'web'
          : (Platform.isIOS
          ? 'iOS'
          : (Platform.isAndroid ? 'Android' : Platform.operatingSystem)),
      if (!kIsWeb) 'osVersion': Platform.operatingSystemVersion,
      'isDebug': kDebugMode,
      if (extra != null) ...extra,
    };
    await _sendLogToBackend('[push-diagnostics] ${jsonEncode(payload)}', ref);
    if (kDebugMode) {
      // ignore: avoid_print
      print('[push-diagnostics] $label :: ${jsonEncode(extra ?? {})}');
    }
  }

  static Future<void> initialize(Ref ref) async {
    await _d('init_start', ref, {
      'firebaseProjectId': DefaultFirebaseOptions.currentPlatform.projectId,
      'firebaseAppId': DefaultFirebaseOptions.currentPlatform.appId,
      'firebaseSenderId':
      DefaultFirebaseOptions.currentPlatform.messagingSenderId,
    });

    // Background handler
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    await _d('background_handler_registered', ref);

    // --- Oprávnění a autoinit podle platforem ---
    if (Platform.isAndroid) {
      final messaging = FirebaseMessaging.instance;

      // Od Android 13 je nutné žádat POST_NOTIFICATIONS
      final settings = await messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );
      await _d('android_permission', ref, {
        'authorizationStatus': settings.authorizationStatus.toString(),
        'canAlert': settings.alert,
        'canBadge': settings.badge,
        'canSound': settings.sound,
      });

      // U Androidu je dobré si ověřit dostupnost tokenu hned po povolení.
      final notifSettings = await messaging.getNotificationSettings();
      await _d('android_getNotificationSettings', ref, {
        'authorizationStatus': notifSettings.authorizationStatus.toString(),
        'alert': notifSettings.alert,
        'badge': notifSettings.badge,
        'sound': notifSettings.sound,
      });
    }

    if (Platform.isIOS) {
      // iOS permission
      final settings = await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        // Tip: pokud chceš tiché povolení bez dialogu, dej provisional: true
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

      // Jak se zobrazují foreground notifikace (baner i ve frontendu)
      await FirebaseMessaging.instance
          .setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
      await _d('ios_foreground_presentation_set', ref,
          {'alert': true, 'badge': true, 'sound': true});

      // Auto-init FCM
      await FirebaseMessaging.instance.setAutoInitEnabled(true);
      final autoInit = FirebaseMessaging.instance.isAutoInitEnabled;
      await _d('ios_auto_init', ref, {'isAutoInitEnabled': autoInit});

      // APNs token (důležitý pro mapování FCM→APNs)
      String? apnsToken = await FirebaseMessaging.instance.getAPNSToken();
      await _d('ios_apns_token_first', ref, {'apnsToken': apnsToken});

      // APNs token může být null hned po startu → zkusíme ještě jednou po krátké prodlevě
      if (apnsToken == null) {
        await Future<void>.delayed(const Duration(seconds: 2));
        apnsToken = await FirebaseMessaging.instance.getAPNSToken();
        await _d('ios_apns_token_retry', ref, {'apnsToken': apnsToken});

        if (apnsToken == null) {
          await _d('ios_apns_token_null_hints', ref, {
            'hints': [
              'Zkontroluj Push Notifications capability a aps-environment v entitlements.',
              'Ověř provisioning profile (development vs distribution) dle buildu.',
              'Testuj na fyzickém zařízení (simulátor APNs nepodporuje).',
              'V Nastavení iOS ověř, že aplikace má povolené Oznámení.',
            ]
          });
        }
      }

      // Pro jistotu i iOS getNotificationSettings
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

    // --- Local notifications init ---
    const AndroidInitializationSettings androidInitSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosInitSettings =
    DarwinInitializationSettings(
      // Pokud máš vlastní kategorie/akce, zvaž zde nastavení
      // notificationCategories: [...]
    );
    const InitializationSettings initSettings = InitializationSettings(
      android: androidInitSettings,
      iOS: iosInitSettings,
    );
    final initResult = await _localNotifications.initialize(initSettings);
    await _d('local_notifications_initialized', ref, {
      'result': initResult, // bool? (může být null na některých platformách)
    });

    // --- Token handling ---
    final tokenStart = DateTime.now();
    final token = await FirebaseMessaging.instance.getToken();
    final tokenDuration =
        DateTime.now().difference(tokenStart).inMilliseconds; // ms
    if (token == null) {
      await _d('fcm_token_null', ref, {
        'fetchMs': tokenDuration,
        'hints': [
          'Zkus znovu povolit oprávnění k oznámením.',
          'Ověř připojení k internetu.',
          'Na iOS: zkontroluj APNs ↔ FCM konfiguraci (APNs .p8 ve Firebase).',
        ]
      });
    } else {
      await _d('fcm_token_acquired', ref, {
        'token': token,
        'fetchMs': tokenDuration,
      });
      await _sendTokenToBackend(token, ref);
    }

    // Pokud se token změní
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
      await _d('fcm_token_refresh', ref, {'newToken': newToken});
      await _sendTokenToBackend(newToken, ref);
    });

    // --- Incoming messages ---

    // Zpráva, která appku otevřela ze zavřeného stavu (cold start)
    final initialMsg = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMsg != null) {
      await _d('getInitialMessage', ref, _serializeMessage(initialMsg));
    } else {
      await _d('getInitialMessage_none', ref);
    }

    // Foreground zprávy
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      await _d('onMessage_foreground_received', ref, _serializeMessage(message));

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

    // Uživatelské otevření notifikace z pozadí/foregroundu
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
      await _d('onMessageOpenedApp', ref, _serializeMessage(message));
    });

    await _d('init_ready', ref, {
      'isIOS': Platform.isIOS,
      'isAndroid': Platform.isAndroid,
    });
  }

  /// Pošle token na backend
  static Future<void> _sendTokenToBackend(String token, Ref ref) async {
    try {
      final crud = CrudApiService(ref);
      await crud.addModel(DeviceTokenApiModel(token: token));
      await _d('token_sent_to_backend', ref, {'token': token});
    } catch (e, st) {
      await _d('token_send_error', ref, {
        'error': e.toString(),
        'stack': st.toString(),
      });
      if (kDebugMode) rethrow;
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
        // ignore: only_throw_errors
        throw e;
      }
    }
  }

  /// Serializace RemoteMessage pro diagnostiku (bezpečně, ale detailně).
  static Map<String, dynamic> _serializeMessage(RemoteMessage msg) {
    return {
      'messageId': msg.messageId,
      'senderId': msg.senderId,
      'from': msg.from,
      'category': msg.category,
      'collapseKey': msg.collapseKey,
      'sentTime': msg.sentTime?.toIso8601String(),
      'ttl': msg.ttl,
      'contentAvailable': msg.contentAvailable, // iOS "silent" indikátor
      'mutableContent': msg.mutableContent, // iOS pro Notification Service Ext.
      'dataKeys': msg.data.keys.toList(),
      'data': msg.data, // pokud by obsahovalo citlivé věci, případně vynechej
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
          'visibility': msg.notification?.android?.visibility.toString(),
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
