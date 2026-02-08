import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/features/fine/repository/fine_api_service.dart';
import 'package:trus_app/features/fine/state/fine_edit_state.dart';
import 'package:trus_app/models/api/fine_api_model.dart';

import '../../../common/utils/field_validator.dart';
import '../../../common/widgets/notifier/loader/loading_state.dart';
import '../../general/notifier/base_crud_notifier.dart';
import '../../general/repository/api_result.dart';
import '../../main/screen_controller.dart';

final fineEditProvider =
StateNotifierProvider.autoDispose
    .family<FineEditNotifier, FineEditState, FineApiModel?>(
      (ref, fine) {
    return FineEditNotifier(
      fine,
      ref.read(fineApiServiceProvider),
      ref.read(screenControllerProvider),
    );
  },
);

final fineAddProvider =
StateNotifierProvider.autoDispose<FineEditNotifier, FineEditState>((ref) {
  return FineEditNotifier(
    null,
    ref.read(fineApiServiceProvider),
    ref.read(screenControllerProvider),
  );
});


class FineEditNotifier
    extends BaseCrudNotifier<FineApiModel, FineEditState> {

  final FineApiService api;

  FineEditNotifier(
      FineApiModel? model,
      this.api,
      ScreenController screenController,
      ) : super(
    FineEditState(
      name: model?.name ?? "",
      amount: model?.amount.toString() ?? "0",
      inactive: model?.inactive ?? false,
      model: model,
    ),
    screenController,
  );

  @override
  FineEditState copyWithState({
    LoadingState? loading,
    Map<String, String>? errors,
    String? successMessage,
  }) {
    return state.copyWith(
      loading: loading,
      errors: errors,
      successMessage: successMessage,
    );
  }

  void setName(String value) {
    state = state.copyWith(name: value);
  }

  void setAmount(String amount) {
    state = state.copyWith(amount: amount);
  }

  void setInactive(bool inactive) {
    state = state.copyWith(inactive: inactive);
  }

  @override
  bool validate() {
    return validateNameField() && validateAmountFields();
  }

  bool validateNameField() {
    String errorText = validateEmptyField(state.name);
    state = state.copyWith(errors: {'name': errorText});
    return errorText.isEmpty;
  }

  bool validateAmountFields() {
    String errorText =
    validateAmountField(state.amount);
    state = state.copyWith(errors: {'amount': errorText});
    return errorText.isEmpty;
  }

  @override
  FineApiModel buildModel() {
    return FineApiModel(
      id: state.model?.id,
      name: state.name,
      amount: int.parse(state.amount),
      inactive:  state.inactive,
    );
  }

  @override
  Future<ApiResult<void>> create(FineApiModel model) {
    return executeApi(() => api.addFine(model));
  }

  @override
  Future<ApiResult<void>> update(FineApiModel model) {
    return executeApi(() => api.editFine(model, model.id!));
  }

  @override
  Future<ApiResult<void>> delete(FineApiModel model) {
    return executeApi(() => api.deleteFine(model.id!));
  }
}
