import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/models/api/interfaces/model_to_string.dart';
import 'package:trus_app/models/helper/beer_stats_helper_model.dart';
import 'package:trus_app/models/helper/fine_stats_helper_model.dart';
import 'package:trus_app/models/match_model.dart';
import 'package:trus_app/models/player_model.dart';

import '../../../common/repository/exception/loading_exception.dart';
import '../../../common/utils/season_util.dart';
import '../../../config.dart';
import '../../../models/api/beer/beer_detailed_model.dart';
import '../../../models/api/beer/beer_detailed_response.dart';
import '../../../models/api/season_api_model.dart';
import '../../../models/season_model.dart';
import '../../beer/repository/beer_api_service.dart';
import '../../general/read_operations.dart';
import '../../season/repository/season_api_service.dart';
import '../repository/stats_repository.dart';

final beerStatsControllerProvider = Provider((ref) {
  final beerApiRepository = ref.watch(beerApiServiceProvider);
  final seasonApiService = ref.watch(seasonApiServiceProvider);
  return BeerStatsController(
      beerApiRepository: beerApiRepository,
      seasonApiService: seasonApiService,
      ref: ref);
});

class BeerStatsController {
  final BeerApiService beerApiRepository;
  final SeasonApiService seasonApiService;
  final ProviderRef ref;

  BeerStatsController({
    required this.beerApiRepository,
    required this.seasonApiService,
    required this.ref,
  });

  List<SeasonApiModel> seasonList = [];
  List<BeerDetailedModel> beerList = [];
  List<BeerDetailedModel> detailedBeerList = [];
  String overallStats = "";
  bool matchStatsOrPlayerStats = false;
  bool revertList = false;
  String? filterText;
  int? pickedSeasonId;
  String? detailString;
  int? detailedModelId;


  final seasonListController =
  StreamController<List<SeasonApiModel>>.broadcast();
  final pickedSeasonController =
  StreamController<SeasonApiModel>.broadcast();
  final beerListController =
  StreamController<List<BeerDetailedModel>>.broadcast();
  final detailedBeerListController =
  StreamController<List<BeerDetailedModel>>.broadcast();
  final overallStatsController =
  StreamController<String>.broadcast();
  final screenDetailController =
  StreamController<bool>.broadcast();

  void setPlayerOrMatchScreen(bool matchStatsOrPlayerStats) {
    this.matchStatsOrPlayerStats = matchStatsOrPlayerStats;
  }


  Future<void> setPickedSeason(SeasonApiModel season) async {
    pickedSeasonId = season.id!;
    pickedSeasonController.add(season);
    await getBeers(season.id, matchStatsOrPlayerStats, filterText);
    if(revertList) {
      revertBeerList();
    }
    beerListController.add(beerList);
    overallStatsController.add(overallStats);
  }

  void setCurrentSeason() {
    if(pickedSeasonId == null) {
      setPickedSeason(returnCurrentSeason(seasonList));
    }
    else {
      setPickedSeason(returnSeasonById(seasonList, pickedSeasonId!));
    }
  }

  Stream<List<SeasonApiModel>> seasons() {
    return seasonListController.stream;
  }

  Stream<SeasonApiModel> pickedSeason() {
    return pickedSeasonController.stream;
  }

  Stream<String> overAllStatsStream() {
    return overallStatsController.stream;
  }

  Stream<List<BeerDetailedModel>> beerListStream() {
    return beerListController.stream;
  }

  Stream<List<BeerDetailedModel>> detailedBeerListStream() {
    return detailedBeerListController.stream;
  }

  Stream<bool> screenDetailStream() {
    return screenDetailController.stream;
  }

  void initOverallStats() {
    overallStatsController.add(overallStats);
  }

  Future<void> setDetail(ModelToString modelToString) async {
    BeerDetailedModel beerDetailedModel = beerList.firstWhere((element) => element.id == modelToString.getId());
    if(beerDetailedModel.player != null) {
      detailString = "${beerDetailedModel.player!.fan ? "fanouška" : "hráče"} ${beerDetailedModel.player!.name}";
      detailedModelId = beerDetailedModel.player!.id!;

    }
    else if (beerDetailedModel.match != null) {
      detailString = "zápas ${beerDetailedModel.match!.listViewTitle()}";
      detailedModelId = beerDetailedModel.match!.id!;
    }
    else {
      detailString = "?";
      detailedModelId = -1;
    }
    changeScreen(true);
  }

  Future<void> setDetailedStream()  async {
    detailedBeerListController.add([]);
    await getDetailedBeers(detailedModelId!);
    detailedBeerListController.add(detailedBeerList);
  }

  void changeScreen(bool detail) {
    screenDetailController.add(detail);
  }

  void onRevertTap() {
    revertList = !revertList;
    revertBeerList();
  }

  void revertBeerList() {
    beerList = beerList.reversed.toList();
    beerListController.add(beerList);
  }


  Future<void> getFilteredBeers(String? filter) async {
    filterText = filter;
    if (filter != null && filter.isNotEmpty) {
      await getBeers(pickedSeasonId, matchStatsOrPlayerStats, filter);
    }
    else {
      await getBeers(pickedSeasonId, matchStatsOrPlayerStats, null);
    }
    if(revertList) {
      revertBeerList();
    }
    beerListController.add(beerList);
    overallStatsController.add(overallStats);
  }

  Future<void> getBeers(int? seasonId, bool matchStatsOrPlayerStats, String? filter) async {
    BeerDetailedResponse beerDetailedResponse = await beerApiRepository.getDetailedBeer(null, seasonId, null, matchStatsOrPlayerStats, filter);
    beerList = beerDetailedResponse.beerList;
    overallStats = beerDetailedResponse.overallStatsToString();
  }

  Future<void> getDetailedBeers(int id) async {
    BeerDetailedResponse beerDetailedResponse;
    if(matchStatsOrPlayerStats) {
      beerDetailedResponse = await beerApiRepository.getDetailedBeer(id, pickedSeasonId, null, !matchStatsOrPlayerStats, null);
    }
    else {
      beerDetailedResponse = await beerApiRepository.getDetailedBeer(null, pickedSeasonId, id, !matchStatsOrPlayerStats, null);
    }
    detailedBeerList = beerDetailedResponse.beerList;
  }


  Future<List<SeasonApiModel>> getSeasons() async {
    seasonList = await seasonApiService.getSeasons(false, true, true);
    return seasonList;
  }

  Future<List<ModelToString>> getModels(bool matchStatsOrPlayerStats) async {
    this.matchStatsOrPlayerStats = matchStatsOrPlayerStats;
    revertList = false;
    filterText = null;
    return beerList;
  }

  Future<List<ModelToString>> getDetailedModels() async {
    setDetailedStream();
    return detailedBeerList;
  }

}
