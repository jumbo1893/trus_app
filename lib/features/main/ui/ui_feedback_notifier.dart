import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/models/api/receivedfine/stats/received_fine_stats_detail_models.dart';

import '../../../models/api/interfaces/model_to_string.dart';
import '../../../models/api/notification/push/push_payload.dart';
import 'ui_effect.dart';
import 'ui_feedback_state.dart';

final uiFeedbackProvider =
StateNotifierProvider<UiFeedbackNotifier, UiFeedbackState>((ref) {
  return UiFeedbackNotifier();
});

class UiFeedbackNotifier extends StateNotifier<UiFeedbackState> {
  UiFeedbackNotifier() : super(UiFeedbackState.initial());

  bool _sessionLoadingSheetVisible = false;
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

  void showConfirmationSheet(String message, VoidCallback callback) {
    emit(UiConfirmationSheet(message, callback));
  }

  void showSimpleSheet(String title, String message) {
    emit(UiSimpleSheet(title, message));
  }

  void showStatsBottomSheet(String title, String subtitle, List<ModelToString> items) {
    emit(UiStatsBottomSheet(title, subtitle, items));
  }

  void showFineStatsBottomSheet(String title, String subtitle, ReceivedFineStatsDetailResponse response) {
    emit(UiFineStatsBottomSheet(title, subtitle, response));
  }

  void showPushNotificationSheet(PushPayload payload) {
    emit(UiPushNotificationSheet(payload));
  }

  void showSessionLoadingSheet([String? message]) {
    if (_sessionLoadingSheetVisible) return;

    _sessionLoadingSheetVisible = true;
    emit(UiLoadingSheet(message));
  }

  void hideSessionLoadingSheet() {
    if (!_sessionLoadingSheetVisible) return;

    _sessionLoadingSheetVisible = false;
    emit(const UiHideLoadingSheet());
  }

}