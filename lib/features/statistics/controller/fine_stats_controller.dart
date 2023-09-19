import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/models/api/interfaces/model_to_string.dart';
import 'package:trus_app/models/api/receivedfine/received_fine_detailed_model.dart';

import '../../../common/utils/season_util.dart';
import '../../../models/api/receivedfine/received_fine_detailed_response.dart';
import '../../../models/api/season_api_model.dart';
import '../../fine/match/repository/fine_match_api_service.dart';
import '../../season/repository/season_api_service.dart';
import '../fine_screen_enum.dart';

final fineStatsControllerProvider = Provider((ref) {
  final receivedFineApiRepository = ref.watch(fineMatchApiServiceProvider);
  final seasonApiService = ref.watch(seasonApiServiceProvider);
  return FineStatsController(
      fineMatchApiService: receivedFineApiRepository,
      seasonApiService: seasonApiService,
      ref: ref);
});

class FineStatsController {
  final FineMatchApiService fineMatchApiService;
  final SeasonApiService seasonApiService;
  final ProviderRef ref;

  FineStatsController({
    required this.fineMatchApiService,
    required this.seasonApiService,
    required this.ref,
  });

  List<SeasonApiModel> seasonList = [];
  List<ReceivedFineDetailedModel> fineList = [];
  List<ReceivedFineDetailedModel> detailedFineList = [];
  List<ReceivedFineDetailedModel> detailedFineFineList = [];
  String overallStats = "";
  bool matchStatsOrPlayerStats = false;
  bool revertList = false;
  String? filterText;
  int? pickedSeasonId;
  String? detailString;
  String? detailDetailString;
  int? detailedModelId;
  int? detailedDetailedModelId;
  ModelToString? detailedModelToString;


  final seasonListController =
  StreamController<List<SeasonApiModel>>.broadcast();
  final pickedSeasonController =
  StreamController<SeasonApiModel>.broadcast();
  final fineListController =
  StreamController<List<ReceivedFineDetailedModel>>.broadcast();
  final detailedFineListController =
  StreamController<List<ReceivedFineDetailedModel>>.broadcast();
  final detailedFineFineListController =
  StreamController<List<ReceivedFineDetailedModel>>.broadcast();
  final overallStatsController =
  StreamController<String>.broadcast();
  final screenDetailController =
  StreamController<FineScreenEnum>.broadcast();

  void setPlayerOrMatchScreen(bool matchStatsOrPlayerStats) {
    this.matchStatsOrPlayerStats = matchStatsOrPlayerStats;
  }


  Future<void> setPickedSeason(SeasonApiModel season) async {
    pickedSeasonId = season.id!;
    pickedSeasonController.add(season);
    await getFines(season.id, matchStatsOrPlayerStats, filterText);
    if(revertList) {
      revertFineList();
    }
    fineListController.add(fineList);
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

  Stream<List<ReceivedFineDetailedModel>> fineListStream() {
    return fineListController.stream;
  }

  Stream<List<ReceivedFineDetailedModel>> detailedFineListStream() {
    return detailedFineListController.stream;
  }

  Stream<List<ReceivedFineDetailedModel>> detailedFineFineListStream() {
    return detailedFineFineListController.stream;
  }

  Stream<FineScreenEnum> screenDetailStream() {
    return screenDetailController.stream;
  }

  void initOverallStats() {
    overallStatsController.add(overallStats);
  }

  Future<void> setDetail(ModelToString modelToString) async {
    ReceivedFineDetailedModel receivedFineDetailedModel = fineList.firstWhere((element) => element.id == modelToString.getId());
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
    changeScreen(FineScreenEnum.detailScreen);
  }

  Future<void> setFineDetail(ModelToString modelToString) async {
    ReceivedFineDetailedModel receivedFineDetailedModel = detailedFineList.firstWhere((element) => element.id == modelToString.getId());
    if(receivedFineDetailedModel.player != null) {
      detailDetailString = "Pokuty ${receivedFineDetailedModel.player!.fan ? "fanouška" : "hráče"} ${receivedFineDetailedModel.player!.name} v zápase ${detailedModelToString!.listViewTitle()}";
      detailedDetailedModelId = receivedFineDetailedModel.player!.id!;

    }
    else if (receivedFineDetailedModel.match != null) {
      detailDetailString = "Pokuty hráče ${detailedModelToString!.listViewTitle()} v zápase ${receivedFineDetailedModel.match!.listViewTitle()}";
      detailedDetailedModelId = receivedFineDetailedModel.match!.id!;
    }
    else {
      detailString = "?";
      detailedDetailedModelId = -1;
    }
    changeScreen(FineScreenEnum.fineScreen);
  }

  Future<void> setDetailedStream()  async {
    detailedFineListController.add([]);
    await getDetailedFines(detailedModelId!);
    detailedFineListController.add(detailedFineList);
  }

  Future<void> setDetailedFineStream()  async {
    detailedFineFineListController.add([]);
    await getDetailedDetailedFines(detailedModelId!, detailedDetailedModelId!);
    detailedFineFineListController.add(detailedFineFineList);
  }

  void changeScreen(FineScreenEnum fineScreenEnum) {
    screenDetailController.add(fineScreenEnum);
  }

  void onRevertTap() {
    revertList = !revertList;
    revertFineList();
  }

  void revertFineList() {
    fineList = fineList.reversed.toList();
    fineListController.add(fineList);
  }


  Future<void> getFilteredFines(String? filter) async {
    filterText = filter;
    if (filter != null && filter.isNotEmpty) {
      await getFines(pickedSeasonId, matchStatsOrPlayerStats, filter);
    }
    else {
      await getFines(pickedSeasonId, matchStatsOrPlayerStats, null);
    }
    if(revertList) {
      revertFineList();
    }
    fineListController.add(fineList);
    overallStatsController.add(overallStats);
  }

  Future<void> getFines(int? seasonId, bool matchStatsOrPlayerStats, String? filter) async {
    ReceivedFineDetailedResponse receivedFineDetailedResponse = await fineMatchApiService.getDetailedReceivedFines(null, seasonId, null, matchStatsOrPlayerStats, null, filter);
    fineList = receivedFineDetailedResponse.fineList;
    overallStats = receivedFineDetailedResponse.overallStatsToString();
  }

  Future<void> getDetailedFines(int id) async {
    ReceivedFineDetailedResponse receivedFineDetailedResponse;
    if(matchStatsOrPlayerStats) {
      receivedFineDetailedResponse = await fineMatchApiService.getDetailedReceivedFines(id, pickedSeasonId, null, !matchStatsOrPlayerStats, null, null);
    }
    else {
      receivedFineDetailedResponse = await fineMatchApiService.getDetailedReceivedFines(null, pickedSeasonId, id, !matchStatsOrPlayerStats, null, null);
    }
    detailedFineList = receivedFineDetailedResponse.fineList;
  }

  Future<void> getDetailedDetailedFines(int firstId, int secondId) async {
    ReceivedFineDetailedResponse receivedFineDetailedResponse;
    if(matchStatsOrPlayerStats) {
      receivedFineDetailedResponse = await fineMatchApiService.getDetailedReceivedFines(firstId, null, secondId, null, true, null);
    }
    else {
      receivedFineDetailedResponse = await fineMatchApiService.getDetailedReceivedFines(secondId, null, firstId, null, true, null);
    }
    detailedFineFineList = receivedFineDetailedResponse.fineList;
  }


  Future<List<SeasonApiModel>> getSeasons() async {
    seasonList = await seasonApiService.getSeasons(false, true, true);
    return seasonList;
  }

  Future<List<ModelToString>> getModels(bool matchStatsOrPlayerStats) async {
    this.matchStatsOrPlayerStats = matchStatsOrPlayerStats;
    revertList = false;
    filterText = null;
    return fineList;
  }

  Future<List<ModelToString>> getDetailedModels() async {
    setDetailedStream();
    return detailedFineList;
  }

  Future<List<ModelToString>> getDetailedDetailedModels() async {
    setDetailedFineStream();
    return detailedFineFineList;
  }

}
