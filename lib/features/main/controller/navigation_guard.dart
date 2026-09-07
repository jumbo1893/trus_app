import 'package:flutter_riverpod/flutter_riverpod.dart';

typedef NavigationGuard = Future<bool> Function();
// This is an imperative navigation callback, not observable UI state. Registering
// it during mount/dispose must not notify Riverpod while Flutter is building.
final navigationGuardProvider = Provider((ref) => NavigationGuardRegistry());

class NavigationGuardRegistry {
  NavigationGuard? guard;

  void Function() register(NavigationGuard callback) {
    guard = callback;
    return () {
      // An older route may unmount after its replacement has registered.
      if (identical(guard, callback)) guard = null;
    };
  }
}
