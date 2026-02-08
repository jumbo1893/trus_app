import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../common/widgets/notifier/loader/loading_state.dart';
import '../../../models/enum/crud.dart';
import '../../main/screen_controller.dart';
import '../repository/api_executor_mixin.dart';
import '../repository/api_result.dart';
import '../state/base_crud_state.dart';


abstract class BaseCrudNotifier<T, S extends BaseCrudState<T>>
    extends StateNotifier<S>
    with ApiExecutorMixin {
  final ScreenController screenController;

  BaseCrudNotifier(super.state, this.screenController);

  /// MUSÍ vracet konkrétní S
  S copyWithState({
    LoadingState? loading,
    Map<String, String>? errors,
    String? successMessage,
  });

  bool validate();
  T buildModel();
  Future<ApiResult<void>> create(T model);
  Future<ApiResult<void>> update(T model);
  Future<ApiResult<void>> delete(T model);

  Future<void> submit(String loadingText, String successMessage, String onSuccessRedirect, Crud crud, ProviderOrFamily provider, {
    void Function(dynamic model)? onSuccessAction,
  }) async {
    if (crud != Crud.delete && !validate()) return;
    state = copyWithState(
      loading: state.loading.loading(loadingText),
      errors: {},
    );

    final model = buildModel();
    ApiResult result;
    switch(crud) {
      case Crud.create:
        result = await create(model);
      case Crud.update:
        result = await update(model);
      case Crud.delete:
        result = await delete(model);
    }
    switch (result) {
      case ApiSuccess():
        state = copyWithState(
          loading: state.loading.idle(),
          successMessage: successMessage,
        );

        screenController.ref.invalidate(provider);

        if (onSuccessAction != null) {
          onSuccessAction(result.data);
        } else {
          screenController.changeFragment(onSuccessRedirect);
        }
        break;

      case ApiFieldError():
        state = copyWithState(
          loading: state.loading.idle(),
          errors: result.fieldErrors,
        );
        break;

      case ApiError():
        state = copyWithState(
          loading: state.loading.errorMessage(result.message),
        );
        break;
    }
  }

  void clearSuccessMessage() {
    state = copyWithState(successMessage: null);
  }

  void clearErrorMessage() {
    state = copyWithState(
      loading: state.loading.errorMessage(null),
    );
  }
}

