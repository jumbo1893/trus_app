import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/features/player/repository/player_repository.dart';
import 'package:trus_app/features/player/state/player_edit_state.dart';
import 'package:trus_app/models/api/player/player_api_model.dart';
import 'package:trus_app/models/api/player/player_setup.dart';

import '../../../common/utils/field_validator.dart';
import '../../../common/widgets/notifier/dropdown/i_dropdown_notifier.dart';
import '../../../common/widgets/notifier/loader/loading_state.dart';
import '../../../models/api/football/football_player_api_model.dart';
import '../../../models/api/interfaces/dropdown_item.dart';
import '../../general/notifier/base_crud_notifier.dart';
import '../../general/repository/api_result.dart';
import '../../main/screen_controller.dart';
import '../player_mode.dart';
import '../player_notifier_args.dart';

final playerEditNotifierProvider = StateNotifierProvider.autoDispose
    .family<PlayerEditNotifier, PlayerEditState, PlayerNotifierArgs>((ref, args) {
  return PlayerEditNotifier(
    repository: ref.read(playerRepositoryProvider),
    playerNotifierArgs: args,
    screenController: ref.read(screenControllerProvider),
  );
});

class PlayerEditNotifier
    extends BaseCrudNotifier<PlayerApiModel, PlayerEditState> implements IDropdownNotifier {
  final PlayerRepository repository;
  final PlayerNotifierArgs playerNotifierArgs;

  PlayerEditNotifier({
    required this.repository,
    required this.playerNotifierArgs,
    required ScreenController screenController,
  }) : super(
    PlayerEditState(
      footballPlayers: const AsyncValue.loading(),
      playerStats: const [], name: "", birthdate: DateTime(2000, 1, 1), fan: false, active: true,
    ),
    screenController,
  ) {
    _load(args: playerNotifierArgs);
  }

  /// =========================
  /// PUBLIC API
  /// =========================
  Future<void> _load({required PlayerNotifierArgs args}) async {
    final int? playerId = args.playerId;
    final cached = repository.getCachedPlayerSetup(playerId);

    if (cached != null) {
      _applySetup(cached);
    } else {
      state = copyWithState(
        loading: state.loading.loading("Načítám hráče…"),
      );
    }
    if (args.playerMode == PlayerMode.edit) {
      //není potřeba volat playerSetup znovu, je již v cache po view
      return;
    }
    final setup = await repository.fetchPlayerSetup(playerId);
    if (!mounted) return;

    _applySetup(setup);
  }

  /// =========================
  /// APPLY SETUP → STATE
  /// =========================
  void _applySetup(PlayerSetup setup) {
    state = state.copyWith(
      name: setup.player?.name ?? "",
      birthdate: setup.player?.birthday,
      fan: setup.player?.fan ?? false,
      active: setup.player?.active ?? true,
      footballPlayers: AsyncValue.data(setup.footballPlayerList),
      selectedFootballPlayer: setup.primaryFootballPlayer,
      achievementPlayerDetail: setup.achievementPlayerDetail,
      playerStats: setup.playerStats,
      model: setup.player,
      loading: state.loading.idle(),
    );
  }

  /// =========================
  /// CRUD
  /// =========================
  @override
  PlayerApiModel buildModel() {
    return PlayerApiModel(
      id: state.model?.id,
      name: state.name,
      birthday: state.birthdate,
      fan: state.fan,
      active: state.active,
      footballPlayer: _getPickedFootballer(state.selectedFootballPlayer),
    );
  }

  void setName(String value) {
    state = state.copyWith(name: value);
  }

  void setFan(bool fan) {
    state = state.copyWith(fan: fan);
  }

  void setActive(bool active) {
    state = state.copyWith(active: active);
  }

  void setBirthday(DateTime birthdate) {
    state = state.copyWith(birthdate: birthdate);
  }

  FootballPlayerApiModel? _getPickedFootballer(DropdownItem? dropdownItem) {
    FootballPlayerApiModel? footballer = dropdownItem as FootballPlayerApiModel?;
    if(footballer == null || footballer.id! == 0) {
      return null;
    }
    return footballer;
  }

  @override
  selectDropdown(DropdownItem item) {
    state = state.copyWith(selectedFootballPlayer: item);
  }

  @override
  Future<ApiResult<void>> create(PlayerApiModel model) async {
    final result = await executeApi(() => repository.api.addPlayer(model));
    repository.invalidatePlayerSetup(null);
    return result;
  }

  @override
  Future<ApiResult<void>> update(PlayerApiModel model) async {
    final result =
        await executeApi(() => repository.api.editPlayer(model, model.id!));
    repository.invalidatePlayerSetup(model.id);
    return result;
  }

  @override
  Future<ApiResult<void>> delete(PlayerApiModel model) async {
    final result =
        await executeApi(() => repository.api.deletePlayer(model.id!));
    repository.invalidatePlayerSetup(model.id);
    return result;
  }

  @override
  bool validate() {
    return validateNameField();
  }

  bool validateNameField() {
    String errorText = validateEmptyField(state.name);
    state = state.copyWith(errors: {'name': errorText});
    return errorText.isEmpty;
  }

  @override
  PlayerEditState copyWithState({
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
}
