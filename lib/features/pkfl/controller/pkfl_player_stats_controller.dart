import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/models/helper/title_and_text.dart';
import '../../../models/api/pkfl/pkfl_player_api_model.dart';
import '../../general/read_operations.dart';
import '../repository/pkfl_api_service.dart';

final pkflPlayerStatsControllerProvider = Provider((ref) {
  final pkflApiService = ref.watch(pkflApiServiceProvider);
  return PkflPlayerStatsController(
      pkflApiService: pkflApiService,
      ref: ref);
});

class PkflPlayerStatsController implements ReadOperations {
  final PkflApiService pkflApiService;
  final ProviderRef ref;
  final playerListController =
      StreamController<List<PkflPlayerApiModel>>.broadcast();
  final pickedPlayerController =
  StreamController<PkflPlayerApiModel>.broadcast();
  final titleAndTextStream =
  StreamController<List<TitleAndText>>.broadcast();
  PkflPlayerApiModel? screenPickedPlayer;
  List<PkflPlayerApiModel> playerList = [];

  PkflPlayerStatsController({
    required this.pkflApiService,
    required this.ref,
  });

  Stream<List<TitleAndText>> streamText() {
    return titleAndTextStream.stream;
  }

  Stream<List<PkflPlayerApiModel>> players() {
    return playerListController.stream;
  }

  Stream<PkflPlayerApiModel> pickedPlayer() {
    return pickedPlayerController.stream;
  }

  void setCurrentPlayer() {
    if(screenPickedPlayer == null) {
      setPickedPlayer(returnCurrentPlayer(playerList));
    }
    else {
      setPickedPlayer(returnPlayerById(playerList, screenPickedPlayer!.id));
    }
  }

  PkflPlayerApiModel returnCurrentPlayer(List<PkflPlayerApiModel> playerList) {
    if(playerList.isNotEmpty) {
      return playerList[0];
    }
    return PkflPlayerApiModel(name: "Vyber hráče", id: 0);
  }

  PkflPlayerApiModel returnPlayerById(List<PkflPlayerApiModel> playerList, int id) {
    for (PkflPlayerApiModel player in playerList) {
      if (player.id == id) {
        return player;
      }
    }
    return returnCurrentPlayer(playerList);
  }

  Future<void> setPickedPlayer(PkflPlayerApiModel player) async {
    pickedPlayerController.add(player);
    screenPickedPlayer = player;
    titleAndTextStream.add(await getModels());
  }

  Future<List<PkflPlayerApiModel>> getPlayers() async {
    playerList = await pkflApiService.getPkflPlayers();
    return playerList;
  }

  @override
  Future<List<TitleAndText>> getModels() async {
    if(playerList.isEmpty) {
      return [];
    }
    else {
      return await pkflApiService.getPlayerStats(screenPickedPlayer!.id);
    }
  }
}
