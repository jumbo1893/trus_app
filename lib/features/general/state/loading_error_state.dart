



class ErrorState {
  final Map<String, String> errors;

  const ErrorState({
    this.errors = const {},
  });

  ErrorState copyWith({
    Map<String, String>? errors,
  }) {
    return ErrorState(
      errors: errors ?? this.errors,
    );
  }
}
