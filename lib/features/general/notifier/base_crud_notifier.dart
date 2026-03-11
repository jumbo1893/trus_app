import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/enum/crud.dart';
import '../repository/api_result.dart';
import '../state/base_crud_state.dart';
import 'app_notifier.dart';


abstract class BaseCrudNotifier<T, S extends BaseCrudState<T>>
    extends AppNotifier<S> {

  BaseCrudNotifier(
      Ref ref,
      S state,
      ) : super(ref, state);

  S copyWithState({
    Map<String, String>? errors,
  });

  bool validate();
  T buildModel();
  Future<void> create(T model);
  Future<void> update(T model);
  Future<void> delete(T model);

  Future<void> submit({
    required Crud crud,
    String? loadingText,
    bool showLoading = true,
    bool successResultSnack = false,
    required String successSnack,
    required String onSuccessRedirect,
    required ProviderOrFamily invalidateProvider,
    Function? onSuccessAction,
  }) async {
    if (crud != Crud.delete && !validate()) return;

    state = copyWithState(errors: {});
    final model = buildModel();
    Future<void> Function() action;
    switch (crud) {
      case Crud.create:
        action = () => create(model);
        break;
      case Crud.update:
        action = () => update(model);
        break;
      case Crud.delete:
        action = () => delete(model);
        break;
    }
    final result = await runUi<void>(
      action,
      loadingMessage: loadingText,
      successSnack: successSnack,
      showLoading: showLoading,
      successResultSnack: successResultSnack,

    );
    switch (result) {
      case ApiSuccess():
      // invalidace listu/detailu apod.
        //screenController.ref.invalidate(invalidateProvider);
        if (onSuccessAction != null) onSuccessAction(model);
        changeFragment(onSuccessRedirect);

        break;

      case ApiFieldError():
      // vrátit field errors do form state
        state = copyWithState(errors: result.fieldErrors);
        break;

      case ApiError():
      // UI už ukázal snack/dialog, tady není nutné nic
        break;
    }

  }
}

