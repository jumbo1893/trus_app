import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'ui_effect.dart';
import 'ui_feedback_state.dart';

final uiFeedbackProvider =
StateNotifierProvider<UiFeedbackNotifier, UiFeedbackState>((ref) {
  return UiFeedbackNotifier();
});

class UiFeedbackNotifier extends StateNotifier<UiFeedbackState> {
  UiFeedbackNotifier() : super(UiFeedbackState.initial());

  int _seq = 0;
  final Map<int, String?> _active = {};

  int startLoading([String? message]) {
    final id = ++_seq;
    _active[id] = message;

    state = state.copyWith(
      isLoading: true,
      loadingMessage: message ?? state.loadingMessage,
    );
    return id;
  }

  void stopLoading(int id) {
    _active.remove(id);

    if (_active.isEmpty) {
      state = state.copyWith(isLoading: false, loadingMessage: null);
      return;
    }

    final lastMessage =
    _active.values.lastWhere((m) => m != null, orElse: () => null);
    state = state.copyWith(isLoading: true, loadingMessage: lastMessage);
  }

  // ------- effects -------
  void emit(UiEffect effect) {
    state = state.copyWith(effects: [...state.effects, effect]);
  }

  /// zavolá UI po tom, co effect zobrazí
  void consumeFirstEffect() {
    if (state.effects.isEmpty) return;
    state = state.copyWith(effects: state.effects.sublist(1));
  }

  // convenience:
  void showSnack(String message, {Duration duration = const Duration(seconds: 1)}) {
    emit(UiSnack(message, duration: duration));
  }

  void showErrorDialog(String message, {String title = "Chyba"}) {
    emit(UiErrorDialog(message, title: title));
  }

  void showConfirmationDialog(String message, VoidCallback callback) {
    emit(UiConfirmationDialog(message, callback));
  }
}