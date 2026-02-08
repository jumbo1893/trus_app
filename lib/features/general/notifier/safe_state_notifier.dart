import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract class SafeStateNotifier<S> extends StateNotifier<S> {
  SafeStateNotifier(super.state);

  /// Bezpečné nastavení stavu – pokud je notifier disposed, nic neudělá
  void safeSetState(S newState) {
    if (!mounted) return;
    state = newState;
  }

  /// Helper pro async akce
  Future<void> runAsync(
      Future<void> Function() action,
      ) async {
    if (!mounted) return;
    await action();
  }
}
