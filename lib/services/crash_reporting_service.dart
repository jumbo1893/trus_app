import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

class CrashReportingService {
  static bool get _isSupported =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS ||
          defaultTargetPlatform == TargetPlatform.macOS);

  static void initialize() {
    if (!_isSupported) return;

    FlutterError.onError = (details) {
      FlutterError.presentError(details);
      FirebaseCrashlytics.instance.recordFlutterFatalError(details);
    };
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
  }

  static Future<void> log(String message) async {
    debugPrint('[Crashlytics] $message');
    if (!_isSupported) return;
    try {
      await FirebaseCrashlytics.instance.log(message);
    } catch (_) {
      // Diagnostika nikdy nesmí ovlivnit běh aplikace.
    }
  }

  static Future<void> setKey(String key, Object value) async {
    if (!_isSupported) return;
    try {
      await FirebaseCrashlytics.instance.setCustomKey(key, value);
    } catch (_) {
      // Diagnostika nikdy nesmí ovlivnit běh aplikace.
    }
  }

  static Future<void> recordError(
    Object error,
    StackTrace stack, {
    required String reason,
    Iterable<Object> information = const [],
    bool fatal = false,
  }) async {
    debugPrint('[Crashlytics] $reason: $error\n$stack');
    if (!_isSupported) return;
    try {
      await FirebaseCrashlytics.instance.recordError(
        error,
        stack,
        reason: reason,
        information: information,
        fatal: fatal,
      );
    } catch (_) {
      // Diagnostika nikdy nesmí ovlivnit běh aplikace.
    }
  }
}
