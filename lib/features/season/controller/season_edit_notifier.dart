import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/common/utils/calendar.dart';

import '../../../common/utils/field_validator.dart';
import '../../../common/widgets/notifier/loader/loading_state.dart';
import '../../../models/api/season_api_model.dart';
import '../../general/notifier/base_crud_notifier.dart';
import '../../general/repository/api_result.dart';
import '../../main/screen_controller.dart';
import '../repository/season_api_service.dart';
import '../state/season_edit_state.dart';

final seasonEditProvider =
StateNotifierProvider.autoDispose
    .family<SeasonEditNotifier, SeasonEditState, SeasonApiModel?>(
      (ref, season) {
    return SeasonEditNotifier(
      season,
      ref.read(seasonApiServiceProvider),
      ref.read(screenControllerProvider),
    );
  },
);

final seasonAddProvider =
StateNotifierProvider.autoDispose<SeasonEditNotifier, SeasonEditState>((ref) {
  return SeasonEditNotifier(
    null,
    ref.read(seasonApiServiceProvider),
    ref.read(screenControllerProvider),
  );
});


class SeasonEditNotifier
    extends BaseCrudNotifier<SeasonApiModel, SeasonEditState> {

  final SeasonApiService api;

  SeasonEditNotifier(
      SeasonApiModel? model,
      this.api,
      ScreenController screenController,
      ) : super(
    SeasonEditState(
      name: model?.name ?? "",
      from: model?.fromDate ?? getDatesForNewSeason(true),
      to: model?.toDate ?? getDatesForNewSeason(false),
      model: model,
    ),
    screenController,
  );

  @override
  SeasonEditState copyWithState({
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

  void setFrom(DateTime date) {
    state = state.copyWith(from: date);
  }

  void setTo(DateTime date) {
    state = state.copyWith(to: date);
  }

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
  SeasonApiModel buildModel() {
    return SeasonApiModel(
      id: state.model?.id,
      name: state.name,
      fromDate: state.from,
      toDate: state.to,
    );
  }

  @override
  Future<ApiResult<void>> create(SeasonApiModel model) {
    return executeApi(() => api.addSeason(model));
  }

  @override
  Future<ApiResult<void>> update(SeasonApiModel model) {
    return executeApi(() => api.editSeason(model, model.id!));
  }

  @override
  Future<ApiResult<void>> delete(SeasonApiModel model) {
    return executeApi(() => api.deleteSeason(model.id!));
  }
}
