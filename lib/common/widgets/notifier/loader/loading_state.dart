class LoadingState {
  final bool isLoading;
  final String? message;
  final String? errorDialog;

  const LoadingState({
    this.isLoading = false,
    this.message,
    this.errorDialog,
  });

  LoadingState loading(String message) =>
      LoadingState(isLoading: true, message: message, errorDialog: null);

  LoadingState errorMessage(String? message) =>
      LoadingState(isLoading: false, errorDialog: message);

  LoadingState idle() => const LoadingState();


}
