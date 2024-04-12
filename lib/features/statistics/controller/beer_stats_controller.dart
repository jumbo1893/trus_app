import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/features/statistics/controller/stats_controller.dart';
import 'package:trus_app/models/api/interfaces/model_to_string.dart';
import '../../../models/api/beer/beer_detailed_model.dart';
import '../../../models/api/beer/beer_detailed_response.dart';
import '../../beer/repository/beer_api_service.dart';
import '../../season/repository/season_api_service.dart';
import '../stats_screen_enum.dart';

final beerStatsControllerProvider = Provider((ref) {
  final beerApiRepository = ref.watch(beerApiServiceProvider);
  final seasonApiService = ref.watch(seasonApiServiceProvider);
  return BeerStatsController(
      beerApiRepository: beerApiRepository,
      seasonApiService: seasonApiService,
      ref: ref);
});

class BeerStatsController extends StatsController {
  final BeerApiService beerApiRepository;

  BeerStatsController({
    required this.beerApiRepository, required super.seasonApiService, required super.ref,
  });

  @override
  Future<void> setDetail(ModelToString modelToString) async {
    BeerDetailedModel beerDetailedModel = modelList.firstWhere((element) => element.getId() == modelToString.getId()) as BeerDetailedModel;
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
    changeScreen(StatsScreenEnum.detailScreen);
  }

  @override
  Future<void> getModelsFromRepo(int? seasonId, bool matchStatsOrPlayerStats, String? filter) async {
    BeerDetailedResponse beerDetailedResponse = await beerApiRepository.getDetailedBeer(null, seasonId, null, matchStatsOrPlayerStats, filter);
    modelList = beerDetailedResponse.beerList;
    overallStats = beerDetailedResponse.overallStatsToString();
  }

  @override
  Future<void> getDetailedModelsFromRepo(int id) async {
    BeerDetailedResponse beerDetailedResponse;
    if(matchStatsOrPlayerStats) {
      beerDetailedResponse = await beerApiRepository.getDetailedBeer(id, pickedSeasonId, null, !matchStatsOrPlayerStats, null);
    }
    else {
      beerDetailedResponse = await beerApiRepository.getDetailedBeer(null, pickedSeasonId, id, !matchStatsOrPlayerStats, null);
    }
    detailedModelList = beerDetailedResponse.beerList;
  }

  @override
  Future<void> getDoubleDetailedModelsFromRepo(int firstId, int secondId) async {

  }

  @override
  Future<void> setDoubleDetail(ModelToString modelToString) async {

  }

}
