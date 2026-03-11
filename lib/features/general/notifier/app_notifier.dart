import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/features/main/controller/screen_notifier.dart';

import '../../main/ui/ui_feedback_notifier.dart';
import '../repository/api_executor_mixin.dart';
import '../repository/api_result.dart';

abstract class AppNotifier<S> extends StateNotifier<S> with ApiExecutorMixin {
  final Ref ref;
  AppNotifier(this.ref, S state) : super(state);

  UiFeedbackNotifier get ui => ref.read(uiFeedbackProvider.notifier);
  ScreenNotifier get screenNotifier => ref.read(screenNotifierProvider.notifier);

  Future<ApiResult<T>> runUi<T>(
      Future<T> Function() action, {
        String? loadingMessage = "Načítám…",
        String? successSnack,
        bool showErrorDialog = true,
        bool showLoading = true,
        bool successResultSnack = false,
      }) async {
    int token = -1;
    if (showLoading) {
      token = ui.startLoading(loadingMessage);
    }
    try {
      final result = await executeApi(action);

      switch (result) {
        case ApiSuccess():
          if (successSnack != null) {
            ui.showSnack(successSnack);
          }
          else if (successResultSnack) {
            ui.showSnack(result.data.toString());
      }
          return result;

        case ApiFieldError():
        // field chyby se mají vrátit do notifieru (form)
          return result;

        case ApiError():
          if (showErrorDialog) {
            ui.showErrorDialog(result.message);
          } else {
            ui.showSnack(result.message);
          }
          return result;
      }
    } finally {
      if (showLoading) {
        ui.stopLoading(token);
      }
    }
  }

  Future<T> runUiWithResult<T>(
      Future<T> Function() action, {
        String loadingMessage = "Načítám…",
        String? successSnack,
        bool showErrorDialog = true,
        bool showLoading = true,
        bool successResultSnack = false,
      }) async {
    final result = await runUi<T>(
      action,
      loadingMessage: loadingMessage,
      successSnack: successSnack,
      showErrorDialog: showErrorDialog,
      showLoading: showLoading,
      successResultSnack: successResultSnack,
    );

    switch (result) {
      case ApiSuccess():
        return result.data;

      case ApiFieldError():
        throw Exception("Field error: ${result.fieldErrors}");

      case ApiError():
        throw Exception(result.message);
    }
  }

  void changeFragment(String id) {
    screenNotifier.changeByFragmentId(id);
  }
}
