import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/features/general/notifier/app_notifier.dart';

abstract class SafeStateNotifier<S> extends AppNotifier<S> {
  SafeStateNotifier(
  Ref ref,
  S state,
  ) : super(ref, state);

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

  Future<AsyncValue<T>> guard<T>(Future<T> Function() action) async {
    final result = await AsyncValue.guard(action);
    return result;
  }

  Future<void> guardSet<T>({
    required Future<T> Function() action,
    required S Function(AsyncValue<T> value) reduce,
  }) async {
    final result = await AsyncValue.guard(action);
    if (!mounted) return;
    safeSetState(reduce(result));
  }
}
