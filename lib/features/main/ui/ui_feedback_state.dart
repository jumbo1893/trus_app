// ui_feedback_state.dart
import 'package:flutter/foundation.dart';

import 'ui_effect.dart';

@immutable
class UiFeedbackState {
  final bool isLoading;
  final String? loadingMessage;

  final List<UiEffect> effects;

  const UiFeedbackState({
    required this.isLoading,
    this.loadingMessage,
    this.effects = const [],
  });

  factory UiFeedbackState.initial() => const UiFeedbackState(isLoading: false);

  UiFeedbackState copyWith({
    bool? isLoading,
    String? loadingMessage,
    List<UiEffect>? effects,
  }) {
    return UiFeedbackState(
      isLoading: isLoading ?? this.isLoading,
      loadingMessage: loadingMessage ?? this.loadingMessage,
      effects: effects ?? this.effects,
    );
  }
}