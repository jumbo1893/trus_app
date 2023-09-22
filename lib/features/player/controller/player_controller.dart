import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/features/general/crud_operations.dart';

import '../../../common/utils/field_validator.dart';
import '../../../models/api/player_api_model.dart';
import '../../general/read_operations.dart';
import '../repository/player_api_service.dart';

final playerControllerProvider = Provider((ref) {
  final playerApiService = ref.watch(playerApiServiceProvider);
  return PlayerController(playerApiService: playerApiService, ref: ref);
});

class PlayerController implements CrudOperations, ReadOperations {
  final PlayerApiService playerApiService;
  final ProviderRef ref;
  final nameController = StreamController<String>.broadcast();
  final dateController = StreamController<DateTime>.broadcast();
  final activeController = StreamController<bool>.broadcast();
  final fanController = StreamController<bool>.broadcast();
  final nameErrorTextController = StreamController<String>.broadcast();
  String originalPlayerName = "";
  String playerName = "";
  bool playerFan = false;
  bool playerActive = true;
  DateTime playerDate = DateTime.now();

  PlayerController({
    required this.playerApiService,
    required this.ref,
  });

  void loadPlayer(PlayerApiModel player) {
    setEditControllers(player);
    nameErrorTextController.add("");
    setFieldsToPlayer(player);
    originalPlayerName = player.name;
  }

  void loadNewPlayer() {
    playerName = "";
    nameController.add("");
    playerDate = DateTime.utc(DateTime.now().year, 1, 1);
    dateController.add(DateTime.utc(DateTime.now().year, 1, 1));
    fanController.add(false);
    activeController.add(true);
    nameErrorTextController.add("");
    playerFan = false;
    playerActive = true;
  }

  void setFieldsToPlayer(PlayerApiModel player) {
    playerName = player.name;
    playerFan = player.fan;
    playerActive = player.active;
    playerDate = player.birthday;
  }

  void setEditControllers(PlayerApiModel player) {
    nameController.add(player.name);
    dateController.add(player.birthday);
    fanController.add(player.fan);
    activeController.add(player.active);
  }

  Future<void> player(PlayerApiModel player) async {
    Future.delayed(
        Duration.zero,
            () => loadPlayer(player));
  }

  Future<void> newPlayer() async {
    Future.delayed(
        Duration.zero,
            () => loadNewPlayer());
  }

  Stream<String> name() {
    return nameController.stream;
  }

  Stream<String> nameErrorText() {
    return nameErrorTextController.stream;
  }

  Stream<DateTime> date() {
    return dateController.stream;
  }

  Stream<bool> fan() {
    return fanController.stream;
  }

  Stream<bool> active() {
    return activeController.stream;
  }

  void setName(String name) {
    nameController.add(name);
    playerName = name;
  }

  void setDate(DateTime date) {
    dateController.add(date);
    playerDate = date;
  }

  void setFan(bool fan) {
    fanController.add(fan);
    playerFan = fan;
  }

  void setActive(bool active) {
    activeController.add(active);
    playerActive = active;
  }

  bool validateFields() {
    String errorText = validateEmptyField(playerName.trim());
    nameErrorTextController.add(errorText);
    return errorText.isEmpty;
  }

  @override
  Future<PlayerApiModel?> addModel() async {
    if (validateFields()) {
      return await playerApiService.addPlayer(PlayerApiModel(name: playerName,
          birthday: playerDate,
          fan: playerFan,
          active: playerActive));
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
    if(validateFields()) {
      PlayerApiModel response = await playerApiService.editPlayer(PlayerApiModel(
          name: playerName, birthday: playerDate, fan: playerFan, active: playerActive), id);

      return response.toStringForEdit(originalPlayerName);
    }
    return null;
  }

  @override
  Future<List<PlayerApiModel>> getModels() async {
    return await playerApiService.getPlayers();
  }
}
