import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';


import '../../../../common/repository/exception/loading_exception.dart';

import '../../../../models/api/match/match_api_model.dart';
import '../../../../models/api/player_api_model.dart';
import '../../../../models/api/receivedfine/received_fine_setup.dart';
import '../../../../models/api/season_api_model.dart';
import '../../../general/match_reader.dart';
import '../../../season/repository/season_api_service.dart';
import '../repository/fine_match_api_service.dart';

final fineMatchControllerProvider = Provider((ref) {
  final fineMatchApiService = ref.watch(fineMatchApiServiceProvider);
  final seasonApiService = ref.watch(seasonApiServiceProvider);
  return FineMatchController(
      ref: ref,
      fineMatchApiService: fineMatchApiService,
      seasonApiService: seasonApiService,);
});

class FineMatchController implements MatchReader {
  final FineMatchApiService fineMatchApiService;
  final SeasonApiService seasonApiService;
  final ProviderRef ref;
  final seasonListController =
  StreamController<List<SeasonApiModel>>.broadcast();
  final pickedSeasonController =
  StreamController<SeasonApiModel>.broadcast();
  final matchListController =
  StreamController<List<MatchApiModel>>.broadcast();
  final multiselectController =
  StreamController<bool>.broadcast();
  final checkedPlayersController =
  StreamController<List<PlayerApiModel>>.broadcast();
  final playerListController =
  StreamController<List<PlayerApiModel>>.broadcast();
  SeasonApiModel? screenPickedSeason;
  List<SeasonApiModel> seasonList = [];
  List<MatchApiModel> matchList = [];
  List<PlayerApiModel> playersInMatchList = [];
  List<PlayerApiModel> otherPlayersList = [];
  List<PlayerApiModel> allPlayersList = [];
  List<PlayerApiModel> checkedPlayersList = [];
  MatchApiModel? pickedMatch;
  late SeasonApiModel initSeason;

  FineMatchController({
    required this.seasonApiService,
    required this.fineMatchApiService,
    required this.ref,
  });

  Future<void> initScreen(int? matchId) async {
    if(matchId == null || matchId == MatchApiModel.dummy().id) {
      await setupFineMatch(null, null);

    }
    else {
      await setupFineMatch(matchId, null);
    }
    initMatchesStream();
    initPlayersStream();
  }

  Future<void> setMatch(MatchApiModel match) async {
    setLoadingScreen(true);
    await setupFineMatch(match.id, initSeason.id);
    cleanCheckPlayers();
    setLoadingScreen(false);
  }

  Future<void> setSeason(SeasonApiModel season) async {
    initSeason = season;
    pickedSeasonController.add(season);
    setLoadingScreen(true);
    await setupFineMatch(null, season.id);
    cleanCheckPlayers();
    setLoadingScreen(false);
  }

  List<int> getCheckedPlayerIdList() {
    List<int> playerIds = [];
    for(PlayerApiModel player in checkedPlayersList) {
      playerIds.add(player.id!);
    }
    return playerIds;
  }

  void initMatchesStream() {
    matchListController.add(matchList);
  }

  void setLoadingScreen(bool loading) {
    if(loading) {
      matchListController.addError(LoadingException());
      playerListController.addError(LoadingException());
    }
    else {
      matchListController.add(matchList);
      playerListController.add(allPlayersList);
    }
  }

  void cleanCheckPlayers() {
    checkedPlayersList = [];
  }

  void checkOnlyPlayers(bool player) {
    cleanCheckPlayers();
    if(!player) {
      checkedPlayersList = playersInMatchList;
    }
    else {
      checkedPlayersList = otherPlayersList;
    }
  }

  void onIconClick(int index) {
    switch (index) {
    //všichni hráči
      case 1:
        {
          checkedPlayersList = allPlayersList;
          break;
        }
    //nehrající
      case 2:
        {
          checkOnlyPlayers(false);
          break;
        }
    //hrající
      case 3:
        {
          checkOnlyPlayers(true);
          break;
        }
    }
    checkedPlayersController.add(checkedPlayersList);
  }

  Stream<List<PlayerApiModel>> checkedPlayers() {
    return checkedPlayersController.stream;
  }

  Stream<List<MatchApiModel>> matches() {
    return matchListController.stream;
  }

  Stream<List<PlayerApiModel>> players() {
    return playerListController.stream;
  }

  Stream<List<SeasonApiModel>> seasons() {
    return seasonListController.stream;
  }

  Stream<SeasonApiModel> pickedSeason() {
    return pickedSeasonController.stream;
  }

  Stream<bool> multiselect() {
    return multiselectController.stream;
  }

  void switchScreen(bool multiselect) {
    cleanCheckPlayers();
    multiselectController.add(multiselect);
    checkedPlayersController.add(checkedPlayersList);
  }

  void setInitSeason() {
    pickedSeasonController.add(initSeason);
    screenPickedSeason = initSeason;
  }

  void setCheckedPlayer(PlayerApiModel player) {
    if(checkedPlayersList.contains(player)) {
      checkedPlayersList.remove(player);
    }
    else {
      checkedPlayersList.add(player);
    }
    checkedPlayersController.add(checkedPlayersList);
  }

  void initPlayersStream() {
    playerListController.add(allPlayersList);
    cleanCheckPlayers();
  }

  Future<List<SeasonApiModel>> getSeasons() async {
    seasonList = await seasonApiService.getSeasons(false, true, true);
    return seasonList;
  }

  List<MatchApiModel> getMatches() {
    return matchList;
  }


  Future<void> setupFineMatch(int? matchId, int? seasonId) async {
    ReceivedFineSetup receivedFineSetup = await fineMatchApiService.setupFineMatch(matchId, seasonId);
    pickedMatch = receivedFineSetup.match;
    playersInMatchList = receivedFineSetup.playersInMatch;
    otherPlayersList = receivedFineSetup.otherPlayers;
    allPlayersList = receivedFineSetup.playersInMatch+receivedFineSetup.otherPlayers;
    matchList = receivedFineSetup.matchList;
    initSeason = receivedFineSetup.season;
  }

  @override
  MatchApiModel? getMatch() {
    return pickedMatch;
  }
}
