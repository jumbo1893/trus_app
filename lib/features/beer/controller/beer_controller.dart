import 'dart:async';
import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/models/api/interfaces/add_to_string.dart';
import 'package:trus_app/models/api/interfaces/confirm_to_string.dart';

import '../../../common/repository/exception/loading_exception.dart';
import '../../../models/api/beer/beer_list.dart';
import '../../../models/api/beer/beer_multi_add_response.dart';
import '../../../models/api/beer/beer_no_match.dart';
import '../../../models/api/beer/beer_no_match_with_player.dart';
import '../../../models/api/beer/beer_setup_response.dart';
import '../../../models/api/match/match_api_model.dart';
import '../../../models/api/season_api_model.dart';
import '../../general/confirm_operations.dart';
import '../../general/match_reader.dart';
import '../../general/stream_add_controller.dart';
import '../../season/repository/season_api_service.dart';
import '../lines/player_lines.dart';
import '../repository/beer_api_service.dart';

final beerControllerProvider = Provider((ref) {
  final beerApiRepository = ref.watch(beerApiServiceProvider);
  final seasonApiService = ref.watch(seasonApiServiceProvider);
  return BeerController(
      ref: ref,
      beerApiRepository: beerApiRepository,
    seasonApiService: seasonApiService,);
});

class BeerController implements MatchReader, StreamAddController, ConfirmOperations {
  final SeasonApiService seasonApiService;
  final BeerApiService beerApiRepository;
  final ProviderRef ref;
  final seasonListController =
  StreamController<List<SeasonApiModel>>.broadcast();
  final pickedSeasonController =
  StreamController<SeasonApiModel>.broadcast();
  final matchListController =
  StreamController<List<MatchApiModel>>.broadcast();
  final beerListController =
  StreamController<List<BeerNoMatchWithPlayer>>.broadcast();
  final switchScreenController =
  StreamController<bool>.broadcast();
  final paintReloadController =
  StreamController<PlayerLines>.broadcast();
  SeasonApiModel? screenPickedSeason;
  List<SeasonApiModel> seasonList = [];
  late SeasonApiModel initSeason;
  List<MatchApiModel> matchList = [];
  MatchApiModel? pickedMatch;
  List<BeerNoMatchWithPlayer> beerList = [];
  List<BeerNoMatchWithPlayer> newBeerList = [];
  bool isSimpleScreen = true;

  BeerController({
    required this.seasonApiService,
    required this.beerApiRepository,
    required this.ref,
  });

  Future<void> initScreen(int? matchId) async {
    if(matchId == null || matchId == MatchApiModel.dummy().id) {
      await setupBeers(null, null);
    }
    else {
      await setupBeers(matchId, null);
    }
    initMatchesStream();
    initBeerStream();
  }

  void initMatchesStream() {
    matchListController.add(matchList);
  }

  void initBeerStream() {
    beerListController.add(beerList);
  }

  Future<void> setMatch(MatchApiModel match) async {
    setLoadingScreen(true);
    await setupBeers(match.id, initSeason.id);
    setLoadingScreen(false);
  }


  Future<void> setSeason(SeasonApiModel season) async {
    initSeason = season;
    pickedSeasonController.add(season);
    setLoadingScreen(true);
    await setupBeers(null, season.id);
    setLoadingScreen(false);
  }

  void setLoadingScreen(bool loading) {
    if(loading) {
      matchListController.addError(LoadingException());
      beerListController.addError(LoadingException());
    }
    else {
      matchListController.add(matchList);
      beerListController.add(beerList);
    }
  }


  Future<List<SeasonApiModel>> getSeasons() async {
    seasonList = await seasonApiService.getSeasons(false, true, true);
    return seasonList;
  }

  Stream<List<MatchApiModel>> matches() {
    return matchListController.stream;
  }

  Stream<List<SeasonApiModel>> seasons() {
    return seasonListController.stream;
  }

  Stream<SeasonApiModel> pickedSeason() {
    return pickedSeasonController.stream;
  }

  Stream<bool> screen() {
    return switchScreenController.stream;
  }

  Stream<PlayerLines> reload() {
    return paintReloadController.stream;
  }

  void switchScreen() {
    isSimpleScreen = !isSimpleScreen;
    switchScreenController.add(isSimpleScreen);
  }

  List<MatchApiModel> getMatches() {
    return matchList;
  }

  void setInitSeason() {
    pickedSeasonController.add(initSeason);
    screenPickedSeason = initSeason;
  }


  Future<void> setupBeers(int? matchId, int? seasonId) async {
    BeerSetupResponse beerSetupResponse = await beerApiRepository.setupBeers(matchId, seasonId);
    pickedMatch = beerSetupResponse.match;
    beerList = beerSetupResponse.beerList;
    matchList = beerSetupResponse.matchList;
    initSeason = beerSetupResponse.season;
    initPlayerLines();
    playerIndex = 0;
    paintReloadController.add(playerLinesList[0]);
  }

  @override
  MatchApiModel? getMatch() {
    return pickedMatch;
  }

  Future<BeerMultiAddResponse> _saveFinesToRepository(BeerList beerList) async {
    return await beerApiRepository.addBeers(beerList);
  }

  List<BeerNoMatch> _convertBeerNoMatchWithPlayerListToBeerNoMatchList(List<BeerNoMatchWithPlayer> beerListWithPlayers) {
    List<BeerNoMatch> returnList = [];
    for(BeerNoMatchWithPlayer beer in beerListWithPlayers) {
      returnList.add(BeerNoMatch(playerId: beer.player.id!, beerNumber: beer.beerNumber, liquorNumber: beer.liquorNumber, id: beer.id));
    }
    return returnList;
  }

  @override
  void addNumber(int index, bool beer) {
    beerList[index].addNumber(beer);
  }

  @override
  void removeNumber(int index, bool beer) {
    beerList[index].removeNumber(beer);
  }

  @override
  Future<ConfirmToString> addModel(int? notUsed) async {
    BeerList returnBeerList = BeerList(matchId: pickedMatch!.id!, beerList: _convertBeerNoMatchWithPlayerListToBeerNoMatchList(beerList));
    return await _saveFinesToRepository(returnBeerList);
  }

  @override
  Stream<List<AddToString>> streamModels() {
    return beerListController.stream;
  }

  @override
  void initStream() {
    beerListController.add(beerList);
  }


  //metody pro paint
  final Random random = Random();
  List<PlayerLines> playerLinesList = [];
  int playerIndex = 0;

  void initPlayerLines() {
    playerLinesList = [];
    for (int i = 0; i < beerList.length; i++) {
      playerLinesList.add(PlayerLines());
      for (int j = 0; j < beerList[i].beerNumber; j++) {
        playerLinesList[i].addAllBeerPositions(returnRandomNumbersForLines());
      }
      for (int j = 0; j < beerList[i].liquorNumber; j++) {
        playerLinesList[i]
            .addAllLiquorPositions(returnRandomNumbersForLines());
      }
    }
  }

  List<double> returnRandomNumbersForLines() {
    return [random.nextDouble(), random.nextDouble(), random.nextDouble(), random.nextDouble()];
  }

  void initStreamPaint() {
    paintReloadController.add(playerLinesList[playerIndex]);
  }

}
