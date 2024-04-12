import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/features/statistics/controller/stats_controller.dart';
import 'package:trus_app/models/api/interfaces/model_to_string.dart';
import 'package:trus_app/models/api/receivedfine/received_fine_detailed_model.dart';

import '../../../models/api/receivedfine/received_fine_detailed_response.dart';
import '../../fine/match/repository/fine_match_api_service.dart';
import '../../season/repository/season_api_service.dart';
import '../stats_screen_enum.dart';

final fineStatsControllerProvider = Provider((ref) {
  final receivedFineApiRepository = ref.watch(fineMatchApiServiceProvider);
  final seasonApiService = ref.watch(seasonApiServiceProvider);
  return FineStatsController(
      fineMatchApiService: receivedFineApiRepository,
      seasonApiService: seasonApiService,
      ref: ref);
});

class FineStatsController extends StatsController {
  final FineMatchApiService fineMatchApiService;

  FineStatsController({
    required this.fineMatchApiService, required super.seasonApiService, required super.ref,

  });

  @override
  Future<void> setDetail(ModelToString modelToString) async {
    ReceivedFineDetailedModel receivedFineDetailedModel = modelList.firstWhere((element) => element.getId() == modelToString.getId()) as ReceivedFineDetailedModel;
    if(receivedFineDetailedModel.player != null) {
      detailString = "${receivedFineDetailedModel.player!.fan ? "fanouška" : "hráče"} ${receivedFineDetailedModel.player!.name}";
      detailedModelToString = receivedFineDetailedModel.player!;
      detailedModelId = receivedFineDetailedModel.player!.id!;

    }
    else if (receivedFineDetailedModel.match != null) {
      detailString = " zápas ${receivedFineDetailedModel.match!.listViewTitle()}";
      detailedModelToString = receivedFineDetailedModel.match!;
      detailedModelId = receivedFineDetailedModel.match!.id!;
    }
    else {
      detailString = "?";
      detailedModelId = -1;
    }
    changeScreen(StatsScreenEnum.detailScreen);
  }

  @override
  Future<void> setDoubleDetail(ModelToString modelToString) async {
    ReceivedFineDetailedModel receivedFineDetailedModel = detailedModelList.firstWhere((element) => element.getId() == modelToString.getId()) as ReceivedFineDetailedModel;
    if(receivedFineDetailedModel.player != null) {
      doubleDetailString = "Pokuty ${receivedFineDetailedModel.player!.fan ? "fanouška" : "hráče"} ${receivedFineDetailedModel.player!.name} v zápase ${detailedModelToString!.listViewTitle()}";
      doubleDetailedModelId = receivedFineDetailedModel.player!.id!;

    }
    else if (receivedFineDetailedModel.match != null) {
      doubleDetailString = "Pokuty hráče ${detailedModelToString!.listViewTitle()} v zápase ${receivedFineDetailedModel.match!.listViewTitle()}";
      doubleDetailedModelId = receivedFineDetailedModel.match!.id!;
    }
    else {
      doubleDetailString = "?";
      doubleDetailedModelId = -1;
    }
    changeScreen(StatsScreenEnum.fineScreen);
  }

  @override
  Future<void> getModelsFromRepo(int? seasonId, bool matchStatsOrPlayerStats, String? filter) async {
    ReceivedFineDetailedResponse receivedFineDetailedResponse = await fineMatchApiService.getDetailedReceivedFines(null, seasonId, null, matchStatsOrPlayerStats, null, filter);
    modelList = receivedFineDetailedResponse.fineList;
    overallStats = receivedFineDetailedResponse.overallStatsToString();
  }

  @override
  Future<void> getDetailedModelsFromRepo(int id) async {
    ReceivedFineDetailedResponse receivedFineDetailedResponse;
    if(matchStatsOrPlayerStats) {
      receivedFineDetailedResponse = await fineMatchApiService.getDetailedReceivedFines(id, pickedSeasonId, null, !matchStatsOrPlayerStats, null, null);
    }
    else {
      receivedFineDetailedResponse = await fineMatchApiService.getDetailedReceivedFines(null, pickedSeasonId, id, !matchStatsOrPlayerStats, null, null);
    }
    detailedModelList = receivedFineDetailedResponse.fineList;
  }

  @override
  Future<void> getDoubleDetailedModelsFromRepo(int firstId, int secondId) async {
    ReceivedFineDetailedResponse receivedFineDetailedResponse;
    if(matchStatsOrPlayerStats) {
      receivedFineDetailedResponse = await fineMatchApiService.getDetailedReceivedFines(firstId, null, secondId, null, true, null);
    }
    else {
      receivedFineDetailedResponse = await fineMatchApiService.getDetailedReceivedFines(secondId, null, firstId, null, true, null);
    }
    doubleDetailedModelList = receivedFineDetailedResponse.fineList;
  }
}
