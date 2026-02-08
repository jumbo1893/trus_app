

import '../../../common/widgets/notifier/loader/loading_state.dart';

class LoadingErrorState {
  final LoadingState loading;
  final Map<String, String> errors;
  final String? successMessage;

  const LoadingErrorState({
    this.loading = const LoadingState(),
    this.errors = const {},
    this.successMessage,
  });

  LoadingErrorState copyWith({
    LoadingState? loading,
    Map<String, String>? errors,
    String? successMessage,
  }) {
    return LoadingErrorState(
      loading: loading ?? this.loading,
      errors: errors ?? this.errors,
      successMessage: successMessage,
    );
  }
}
