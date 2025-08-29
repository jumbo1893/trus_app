import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/features/general/cache/cache_processor.dart';
import 'package:trus_app/features/general/crud_operations.dart';
import 'package:trus_app/features/mixin/achievement_controller_mixin.dart';
import 'package:trus_app/features/mixin/boolean_controller_mixin.dart';
import 'package:trus_app/features/mixin/date_controller_mixin.dart';
import 'package:trus_app/features/mixin/string_controller_mixin.dart';
import 'package:trus_app/features/mixin/view_controller_mixin.dart';
import 'package:trus_app/features/player/widget/i_player_hash_key.dart';
import 'package:trus_app/models/api/football/football_player_api_model.dart';

import '../../../common/utils/calendar.dart';
import '../../../common/utils/field_validator.dart';
import '../../../models/api/player/player_api_model.dart';
import '../../../models/api/player/player_setup.dart';
import '../../general/read_operations.dart';
import '../../mixin/dropdown_controller_mixin.dart';
import '../repository/player_api_service.dart';

final playerControllerProvider = Provider((ref) {
  final playerApiService = ref.watch(playerApiServiceProvider);
  return PlayerController(playerApiService: playerApiService, ref: ref);
});

class PlayerController extends CacheProcessor
    with DropdownControllerMixin, StringControllerMixin, DateControllerMixin, BooleanControllerMixin, ViewControllerMixin, AchievementControllerMixin
    implements CrudOperations, ReadOperations, IPlayerHashKey {
  final PlayerApiService playerApiService;
  String originalPlayerName = "";
  late PlayerSetup playerSetup;
  final String playerListId = "playerListId";

  PlayerController({
    required this.playerApiService,
    required Ref ref,
  }) : super(ref);

  void loadEditPlayer() {
    initDropdown(
        playerSetup.primaryFootballPlayer, playerSetup.footballPlayerList, footballerKey());
    initStringFields(playerSetup.player!.name, nameKey());
    originalPlayerName = playerSetup.player!.name;
    initDateFields(playerSetup.player!.birthday, dateKey());
    initBooleanFields(playerSetup.player!.active, activeKey());
    initBooleanFields(playerSetup.player!.fan, fanKey());
  }

  void loadViewPlayer() {
    initViewFields(
        playerSetup.primaryFootballPlayer.dropdownItem(), footballerKey());
    initViewFields(
        playerSetup.player!.name, nameKey());
    initViewFields(
        dateTimeToString(playerSetup.player!.birthday), dateKey());
    initViewFields(playerSetup.getPlayerStats(), footballerDetailKey());
    initAchievementFields(playerSetup.achievementPlayerDetail!, achievementsKey());
  }

  String getNameViewField() {
    if (playerSetup.player!.fan) {
      return "Fanoušek:";
    }
    else if (playerSetup.player!.active) {
      return "Aktivní hráč:";
    }
    else {
      return "Neaktivní hráč:";
    }
  }

  void loadNewPlayer() {
    initDropdown(
        playerSetup.primaryFootballPlayer, playerSetup.footballPlayerList, footballerKey());
    initStringFields("", nameKey());
    initDateFields(DateTime.utc(DateTime.now().year, 1, 1), dateKey());
    initBooleanFields(true, activeKey());
    initBooleanFields(false, fanKey());
  }

  Future<void> setupNewPlayer() async {
    playerSetup = await _setupPlayer(null);
  }

  Future<void> setupEditPlayer(int id) async {
    playerSetup = await _setupPlayer(id);
  }

  Future<void> newPlayer() async {
    await Future.delayed(Duration.zero, () => loadNewPlayer());
  }

  Future<void> editPlayer() async {
    Future.delayed(Duration.zero, () => loadEditPlayer());
  }

  Future<void> viewPlayer() async {
    Future.delayed(Duration.zero, () => loadViewPlayer());
  }

  bool validateFields() {
    String errorText = validateEmptyField(stringValues[nameKey()]!.trim());
    stringErrorTextControllers[nameKey()]!.add(errorText);
    return errorText.isEmpty;
  }

  Future<PlayerSetup> _setupPlayer(int? id) async {
    return await playerApiService.setupPlayer(id);
  }

  FootballPlayerApiModel? _getPickedFootballer() {
    FootballPlayerApiModel footballer = dropdownValues[footballerKey()] as FootballPlayerApiModel;
    if(footballer.id! == 0) {
      return null;
    }
    return footballer;
  }

  @override
  Future<PlayerApiModel?> addModel() async {
    if (validateFields()) {
      return await playerApiService.addPlayer(PlayerApiModel(
          name: stringValues[nameKey()]!,
          birthday: dateValues[dateKey()]!,
          fan: boolValues[fanKey()]!,
          active: boolValues[activeKey()]!,
          footballPlayer: _getPickedFootballer()));
    }
    return null;
  }

  @override
  Future<String> deleteModel(int id) async {
    await playerApiService.deletePlayer(id);
    return "$originalPlayerName úspěšně smazán";
  }

  @override
  Future<String?> editModel(int id) async {
    if (validateFields()) {
      PlayerApiModel response = await playerApiService.editPlayer(
          PlayerApiModel(
              id: id,
              name: stringValues[nameKey()]!,
              birthday: dateValues[dateKey()]!,
              fan: boolValues[fanKey()]!,
              active: boolValues[activeKey()]!,
              footballPlayer: _getPickedFootballer()),
          id);

      return response.toStringForEdit(originalPlayerName);
    }
    return null;
  }

  @override
  Future<List<PlayerApiModel>> getModels() async {
    return await playerApiService.getPlayers();
  }

  Future<void> setupPlayerList() async {
    await initSetupList<List<PlayerApiModel>>(() async => playerApiService.getPlayers(), playerListId);
  }

  @override
  String activeKey() {
    return "player_active";
  }

  @override
  String dateKey() {
    return "player_date";
  }

  @override
  String fanKey() {
    return "player_fan";
  }

  @override
  String footballerKey() {
    return "player_footballer";
  }

  @override
  String nameKey() {
    return "player_name";
  }

  @override
  String footballerDetailKey() {
    return "player_footballerDetail";
  }

  @override
  String achievementsKey() {
    return "player_achievement";
  }
}
