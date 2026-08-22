import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/models/api/ai/ai_models.dart';

class AiAssistantState {
  final AsyncValue<List<AiQuestion>> questions;
  final AsyncValue<AiUsage> usage;
  final bool submitting;
  final String? pendingQuestion;
  final String? errorMessage;

  const AiAssistantState({
    required this.questions,
    required this.usage,
    required this.submitting,
    required this.pendingQuestion,
    required this.errorMessage,
  });

  factory AiAssistantState.initial() => const AiAssistantState(
    questions: AsyncValue.loading(),
    usage: AsyncValue.loading(),
    submitting: false,
    pendingQuestion: null,
    errorMessage: null,
  );

  AiAssistantState copyWith({
    AsyncValue<List<AiQuestion>>? questions,
    AsyncValue<AiUsage>? usage,
    bool? submitting,
    String? pendingQuestion,
    bool clearPendingQuestion = false,
    String? errorMessage,
    bool clearError = false,
  }) => AiAssistantState(
    questions: questions ?? this.questions,
    usage: usage ?? this.usage,
    submitting: submitting ?? this.submitting,
    pendingQuestion: clearPendingQuestion
        ? null
        : pendingQuestion ?? this.pendingQuestion,
    errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
  );
}
