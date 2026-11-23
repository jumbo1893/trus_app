import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:trus_app/features/main/main_screen.dart';

/// Google Analytics for Firebase. Posílá jen technická ID obrazovek
/// a Firebase UID (pseudonym), nikdy jména, e-maily ani jiné PII.
class AnalyticsService {
  static bool get _isSupported =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  static FirebaseAnalytics get _analytics => FirebaseAnalytics.instance;

  static void initialize() {
    if (!_isSupported) return;
    FirebaseAuth.instance.authStateChanges().listen(
      (user) => _run(() => _analytics.setUserId(id: user?.uid)),
    );
  }

  /// Pro pojmenované routy mimo MainScreen (login, registrace...).
  /// MainScreen a home route ('/') se logují přes [logScreen].
  static List<NavigatorObserver> get navigatorObservers => _isSupported
      ? [
          FirebaseAnalyticsObserver(
            analytics: _analytics,
            routeFilter: (route) =>
                route is PageRoute &&
                route.settings.name != '/' &&
                route.settings.name != MainScreen.routeName,
          ),
        ]
      : const [];

  static Future<void> logScreen(String screenId) {
    if (!_isSupported) return Future.value();
    return _run(
      () => _analytics.logScreenView(
        screenName: screenId,
        screenClass: screenId,
      ),
    );
  }

  static Future<void> _run(Future<void> Function() action) async {
    try {
      await action();
    } catch (error) {
      // Analytika nikdy nesmí ovlivnit běh aplikace.
      debugPrint('[Analytics] $error');
    }
  }
}
