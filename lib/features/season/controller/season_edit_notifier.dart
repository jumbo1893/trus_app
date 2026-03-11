import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/common/utils/calendar.dart';
import 'package:trus_app/features/season/controller/season_notifier.dart';
import 'package:trus_app/features/season/screens/season_screen.dart';

import '../../../common/utils/field_validator.dart';
import '../../../models/api/season_api_model.dart';
import '../../../models/enum/crud.dart';
import '../../general/notifier/base_crud_notifier.dart';
import '../repository/season_api_service.dart';
import '../state/season_edit_state.dart';

final seasonEditProvider =
StateNotifierProvider.autoDispose
    .family<SeasonEditNotifier, SeasonEditState, SeasonApiModel?>(
      (ref, season) {
    return SeasonEditNotifier(
      ref,
      season,
      ref.read(seasonApiServiceProvider),
    );
  },
);

final seasonAddProvider =
StateNotifierProvider.autoDispose<SeasonEditNotifier, SeasonEditState>((ref) {
  return SeasonEditNotifier(
    ref,
    null,
    ref.read(seasonApiServiceProvider),
  );
});


class SeasonEditNotifier
    extends BaseCrudNotifier<SeasonApiModel, SeasonEditState> {

  final SeasonApiService api;

  SeasonEditNotifier(
      Ref ref,
      SeasonApiModel? model,
      this.api,
      ) : super(
    ref,
    SeasonEditState(
      name: model?.name ?? "",
      from: model?.fromDate ?? getDatesForNewSeason(true),
      to: model?.toDate ?? getDatesForNewSeason(false),
      model: model,
    ),
  );

  /// =========================
  /// CRUD
  /// =========================

  void submitCrud(Crud crud) {
    submit(
      crud: crud,
      loadingText: switch (crud) {
        Crud.create => "Přidávám sezonu…",
        Crud.update => "Upravuji sezonu…",
        Crud.delete => "Mažu sezonu…",
      },
      successSnack: switch (crud) {
        Crud.create => "Sezona přidána",
        Crud.update => "Sezona upravena",
        Crud.delete => "Sezona smazána",
      },
      onSuccessRedirect: SeasonScreen.id,
      invalidateProvider: seasonNotifierProvider,
    );
  }

  @override
  Future<void> create(SeasonApiModel model) async {
    await api.addSeason(model);
  }

  @override
  Future<void> update(SeasonApiModel model) async {
    await api.editSeason(model, model.id!);
  }

  @override
  Future<void> delete(SeasonApiModel model) async {
    await api.deleteSeason(model.id!);
  }

  @override
  SeasonApiModel buildModel() {
    return SeasonApiModel(
      id: state.model?.id,
      name: state.name,
      fromDate: state.from,
      toDate: state.to,
    );
  }

  // ========= form setters =========

  void setName(String value) {
    state = state.copyWith(name: value);
  }

  void setFrom(DateTime date) {
    state = state.copyWith(from: date);
  }

  void setTo(DateTime date) {
    state = state.copyWith(to: date);
  }

  // ========= validation + BaseCrud glue =========

  @override
  bool validate() {
    return validateNameField() && validateCalendarField();
  }

  bool validateNameField() {
    String errorText = validateEmptyField(state.name);
    state = state.copyWith(errors: {'name': errorText});
    return errorText.isEmpty;
  }

  bool validateCalendarField() {
    String errorText =
    validateSeasonDate(state.from, state.to);
    state = state.copyWith(errors: {'toDate': errorText});
    return errorText.isEmpty;
  }

  @override
  SeasonEditState copyWithState({
    Map<String, String>? errors,
  }) {
    return state.copyWith(
      errors: errors,
    );
  }
}
