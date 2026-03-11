import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/features/fine/repository/fine_api_service.dart';
import 'package:trus_app/features/fine/screens/fine_screen.dart';
import 'package:trus_app/features/fine/state/fine_edit_state.dart';
import 'package:trus_app/models/api/fine_api_model.dart';

import '../../../common/utils/field_validator.dart';
import '../../../models/enum/crud.dart';
import '../../general/notifier/base_crud_notifier.dart';

final fineEditProvider =
StateNotifierProvider.autoDispose
    .family<FineEditNotifier, FineEditState, FineApiModel?>(
      (ref, fine) {
    return FineEditNotifier(
      ref,
      fine,
      ref.read(fineApiServiceProvider),
    );
  },
);

final fineAddProvider =
StateNotifierProvider.autoDispose<FineEditNotifier, FineEditState>((ref) {
  return FineEditNotifier(
    ref,
    null,
    ref.read(fineApiServiceProvider),
  );
});


class FineEditNotifier
    extends BaseCrudNotifier<FineApiModel, FineEditState> {
  final FineApiService api;

  FineEditNotifier(
      Ref ref,
      FineApiModel? model,
      this.api,
      ) : super(ref,
    FineEditState(
      name: model?.name ?? "",
      amount: model?.amount.toString() ?? "0",
      inactive: model?.inactive ?? false,
      model: model,
    ),
  );

  // ========= form setters =========
  void setName(String value) {
    state = state.copyWith(name: value);
  }

  void setAmount(String amount) {
    state = state.copyWith(amount: amount);
  }

  void setInactive(bool inactive) {
    state = state.copyWith(inactive: inactive);
  }

  /// =========================
  /// CRUD
  /// =========================

  void submitCrud(Crud crud) {
    submit(
      crud: crud,
      loadingText: switch (crud) {
        Crud.create => "Přidávám pokutu…",
        Crud.update => "Upravuji pokutu…",
        Crud.delete => "Mažu pokutu…",
      },
      successSnack: switch (crud) {
        Crud.create => "Pokuta přidána",
        Crud.update => "Pokuta upravena",
        Crud.delete => "Pokuta smazána",
      },
      onSuccessRedirect: FineScreen.id,
      invalidateProvider: fineApiServiceProvider,
    );
  }

  @override
  Future<void> create(FineApiModel model) async {
    await api.addFine(model);
  }

  @override
  Future<void> update(FineApiModel model) async {
    await api.editFine(model, model.id!);
  }

  @override
  Future<void> delete(FineApiModel model) async {
    await api.deleteFine(model.id!);
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

  // ========= validation + BaseCrud glue =========

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
  FineEditState copyWithState({
    Map<String, String>? errors,
  }) {
    return state.copyWith(
      errors: errors,
    );
  }
}
