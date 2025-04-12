import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/models/helper/title_and_text.dart';

import '../../../models/api/football/football_player_api_model.dart';
import '../../general/read_operations.dart';
import '../repository/football_api_service.dart';

final footballPlayerStatsControllerProvider = Provider((ref) {
  final footballApiService = ref.watch(footballApiServiceProvider);
  return FootballPlayerStatsController(
      footballApiService: footballApiService,
      ref: ref);
});

class FootballPlayerStatsController implements ReadOperations {
  final FootballApiService footballApiService;
  final Ref ref;
  final playerListController =
      StreamController<List<FootballPlayerApiModel>>.broadcast();
  final pickedPlayerController =
  StreamController<FootballPlayerApiModel>.broadcast();
  final titleAndTextStream =
  StreamController<List<TitleAndText>>.broadcast();
  FootballPlayerApiModel? screenPickedPlayer;
  List<FootballPlayerApiModel> playerList = [];

  FootballPlayerStatsController({
    required this.footballApiService,
    required this.ref,
  });

  Stream<List<TitleAndText>> streamText() {
    return titleAndTextStream.stream;
  }

  Stream<List<FootballPlayerApiModel>> players() {
    return playerListController.stream;
  }

  Stream<FootballPlayerApiModel> pickedPlayer() {
    return pickedPlayerController.stream;
  }

  void setCurrentPlayer() {
    if(screenPickedPlayer == null) {
      setPickedPlayer(returnCurrentPlayer(playerList));
    }
    else {
      setPickedPlayer(returnPlayerById(playerList, screenPickedPlayer!.id!));
    }
  }

  FootballPlayerApiModel returnCurrentPlayer(List<FootballPlayerApiModel> playerList) {
    if(playerList.isNotEmpty) {
      return playerList[0];
    }
    return FootballPlayerApiModel(name: "Vyber hráče", id: 0, birthYear: 1900, uri: '');
  }

  FootballPlayerApiModel returnPlayerById(List<FootballPlayerApiModel> playerList, int id) {
    for (FootballPlayerApiModel player in playerList) {
      if (player.id == id) {
        return player;
      }
    }
    return returnCurrentPlayer(playerList);
  }

  Future<void> setPickedPlayer(FootballPlayerApiModel player) async {
    pickedPlayerController.add(player);
    screenPickedPlayer = player;
    titleAndTextStream.add(await getModels());
  }

  Future<List<FootballPlayerApiModel>> getPlayers() async {
    playerList = await footballApiService.getFootballPlayers();
    return playerList;
  }

  @override
  Future<List<TitleAndText>> getModels() async {
    if(playerList.isEmpty) {
      return [];
    }
    else {
      return await footballApiService.getPlayerFacts(screenPickedPlayer!.id!);
    }
  }
}
