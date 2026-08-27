import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/features/ai/repository/ai_api_service.dart';
import 'package:trus_app/features/membership/repository/membership_api_service.dart';
import 'package:trus_app/features/ai/state/ai_assistant_state.dart';
import 'package:trus_app/features/general/notifier/safe_state_notifier.dart';
import 'package:trus_app/models/api/ai/ai_models.dart';

final aiAssistantControllerProvider =
    StateNotifierProvider.autoDispose<AiAssistantController, AiAssistantState>(
      (ref) =>
          AiAssistantController(ref: ref, api: ref.read(aiApiServiceProvider)),
    );

class AiAssistantController extends SafeStateNotifier<AiAssistantState> {
  final AiApiService api;

  AiAssistantController({required Ref ref, required this.api})
    : super(ref, AiAssistantState.initial()) {
    Future.microtask(load);
  }

  Future<void> load() async {
    safeSetState(
      state.copyWith(
        questions: const AsyncValue.loading(),
        usage: const AsyncValue.loading(),
        clearError: true,
      ),
    );
    try {
      final results = await Future.wait<Object>([
        api.getHistory(),
        api.getUsage(),
      ]);
      if (!mounted) return;
      final newestFirst = results[0] as List<AiQuestion>;
      safeSetState(
        state.copyWith(
          questions: AsyncValue.data(newestFirst.reversed.toList()),
          usage: AsyncValue.data(results[1] as AiUsage),
        ),
      );
    } catch (error, stack) {
      if (!mounted) return;
      safeSetState(
        state.copyWith(
          questions: AsyncValue.error(error, stack),
          usage: AsyncValue.error(error, stack),
          errorMessage: error.toString(),
        ),
      );
    }
  }

  Future<bool> submit(String rawQuestion) async {
    final question = rawQuestion.trim();
    if (question.isEmpty || state.submitting) return false;

    final usage = state.usage.valueOrNull;
    if (usage != null && !usage.canAsk) {
      safeSetState(
        state.copyWith(
          errorMessage: usage.enabled
              ? 'Pro dnešek jste vyčerpali limit AI dotazů.'
              : 'TrusBot není pro váš účet povolen.',
        ),
      );
      return false;
    }

    safeSetState(
      state.copyWith(
        submitting: true,
        pendingQuestion: question,
        clearError: true,
      ),
    );
    try {
      final response = await api.ask(question);
      if (!mounted) return false;
      final messages = List<AiQuestion>.of(
        state.questions.valueOrNull ?? const [],
      )..add(response);
      safeSetState(
        state.copyWith(
          questions: AsyncValue.data(messages),
          usage: AsyncValue.data(response.usage),
          submitting: false,
          clearPendingQuestion: true,
        ),
      );
      ref.invalidate(membershipProvider);
      return true;
    } catch (error) {
      if (!mounted) return false;
      safeSetState(
        state.copyWith(
          submitting: false,
          clearPendingQuestion: true,
          errorMessage: error.toString(),
        ),
      );
      return false;
    }
  }
}
