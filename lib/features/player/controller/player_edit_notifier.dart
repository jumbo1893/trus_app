import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/features/player/controller/player_notifier.dart';
import 'package:trus_app/features/player/repository/player_repository.dart';
import 'package:trus_app/features/player/screens/player_screen.dart';
import 'package:trus_app/features/player/state/player_edit_state.dart';
import 'package:trus_app/models/api/player/player_api_model.dart';
import 'package:trus_app/models/api/player/player_setup.dart';

import '../../../common/utils/field_validator.dart';
import '../../../common/widgets/notifier/dropdown/i_dropdown_notifier.dart';
import '../../../models/api/football/football_player_api_model.dart';
import '../../../models/api/interfaces/dropdown_item.dart';
import '../../../models/enum/crud.dart';
import '../../general/notifier/base_crud_notifier.dart';
import '../player_mode.dart';
import '../player_notifier_args.dart';

final playerEditNotifierProvider = StateNotifierProvider.autoDispose
    .family<PlayerEditNotifier, PlayerEditState, PlayerNotifierArgs>((ref, args) {
  return PlayerEditNotifier(
    ref: ref,
    repository: ref.read(playerRepositoryProvider),
    playerNotifierArgs: args,
  );
});

class PlayerEditNotifier
    extends BaseCrudNotifier<PlayerApiModel, PlayerEditState> implements IDropdownNotifier {
  final PlayerRepository repository;
  final PlayerNotifierArgs playerNotifierArgs;

  PlayerEditNotifier({
    required Ref ref,
    required this.repository,
    required this.playerNotifierArgs,
  }) : super(
    ref,
    PlayerEditState(
      footballPlayers: const AsyncValue.loading(),
      playerStats: const [],
      name: "",
      birthdate: DateTime(2000, 1, 1),
      fan: false,
      active: true,
    ),
  ) {
    Future.microtask(() => _load(args: playerNotifierArgs));
  }

  /// =========================
  /// PUBLIC API
  /// =========================
  Future<void> _load({required PlayerNotifierArgs args}) async {
    final int? playerId = args.playerId;
    final cached = repository.getCachedPlayerSetup(playerId);

    if (cached != null) {
      _applySetup(cached);
    }
    if (args.playerMode == PlayerMode.edit) {
      //není potřeba volat playerSetup znovu, je již v cache po view
      return;
    }
    final setup = await runUiWithResult<PlayerSetup>(
          () => repository.fetchPlayerSetup(playerId),
      showLoading: (cached == null),
      successSnack: null,
    );
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
    );
  }

  // ========= form setters =========

  void setName(String value) => state = state.copyWith(name: value);
  void setFan(bool fan) => state = state.copyWith(fan: fan);
  void setActive(bool active) => state = state.copyWith(active: active);
  void setBirthday(DateTime birthdate) => state = state.copyWith(birthdate: birthdate);


  /// =========================
  /// CRUD
  /// =========================

  void submitCrud(Crud crud) {
    submit(
      crud: crud,
      loadingText: switch (crud) {
        Crud.create => "Přidávám hráče…",
        Crud.update => "Upravuji hráče…",
        Crud.delete => "Mažu hráče…",
      },
      successSnack: switch (crud) {
        Crud.create => "Hráč přidán",
        Crud.update => "Hráč upraven",
        Crud.delete => "Hráč smazán",
      },
      onSuccessRedirect: PlayerScreen.id,
      invalidateProvider: playerNotifierProvider,
    );
  }

  @override
  selectDropdown(DropdownItem item) {
    state = state.copyWith(selectedFootballPlayer: item);
  }

  @override
  Future<void> create(PlayerApiModel model) async {
    await repository.api.addPlayer(model);
    repository.invalidatePlayerSetup(null);
  }

  @override
  Future<void> update(PlayerApiModel model) async {
    await repository.api.editPlayer(model, model.id!);
    repository.invalidatePlayerSetup(model.id);
  }

  @override
  Future<void> delete(PlayerApiModel model) async {
    await repository.api.deletePlayer(model.id!);
    repository.invalidatePlayerSetup(model.id);
  }

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

  FootballPlayerApiModel? _getPickedFootballer(DropdownItem? dropdownItem) {
    FootballPlayerApiModel? footballer = dropdownItem as FootballPlayerApiModel?;
    if(footballer == null || footballer.id! == 0) {
      return null;
    }
    return footballer;
  }

  // ========= validation + BaseCrud glue =========


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
    Map<String, String>? errors,
  }) {
    return state.copyWith(
      errors: errors,
    );
  }
}
