import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/models/api/interfaces/model_to_string.dart';

import '../../../common/utils/season_util.dart';
import '../../../models/api/season_api_model.dart';
import '../../season/repository/season_api_service.dart';
import '../stats_screen_enum.dart';


abstract class StatsController {
  final SeasonApiService seasonApiService;
  final Ref ref;

  StatsController({
    required this.seasonApiService,
    required this.ref,
  });

  List<SeasonApiModel> seasonList = [];
  List<ModelToString> modelList = [];
  List<ModelToString> detailedModelList = [];
  List<ModelToString> doubleDetailedModelList = [];
  String overallStats = "";
  bool matchStatsOrPlayerStats = false;
  bool revertList = false;
  String? filterText;
  int? pickedSeasonId;
  String? detailString;
  int? detailedModelId;
  String? doubleDetailString;
  int? doubleDetailedModelId;
  ModelToString? detailedModelToString;


  final seasonListController =
  StreamController<List<SeasonApiModel>>.broadcast();
  final pickedSeasonController =
  StreamController<SeasonApiModel>.broadcast();
  final modelListController =
  StreamController<List<ModelToString>>.broadcast();
  final detailedModelListController =
  StreamController<List<ModelToString>>.broadcast();
  final doubleDetailedModelListController =
  StreamController<List<ModelToString>>.broadcast();
  final overallStatsController =
  StreamController<String>.broadcast();
  final screenDetailController =
  StreamController<StatsScreenEnum>.broadcast();


  Future<void> setPickedSeason(SeasonApiModel season) async {
    modelList = [];
    modelListController.add([]);
    pickedSeasonId = season.id!;
    pickedSeasonController.add(season);
    await getModelsFromRepo(season.id, matchStatsOrPlayerStats, filterText);
    if(revertList) {
      revertModelList();
    }
    modelListController.add(modelList);
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

  Stream<SeasonApiModel> pickedSeason() {
    return pickedSeasonController.stream;
  }

  Stream<String> overAllStatsStream() {
    return overallStatsController.stream;
  }

  Stream<List<ModelToString>> listStream() {
    return modelListController.stream;
  }

  Stream<List<ModelToString>> detailedListStream() {
    return detailedModelListController.stream;
  }

  Stream<List<ModelToString>> doubleDetailedListStream() {
    return doubleDetailedModelListController.stream;
  }

  Stream<StatsScreenEnum> screenDetailStream() {
    return screenDetailController.stream;
  }

  void initOverallStats() {
    overallStatsController.add(overallStats);
  }

  Future<void> setDetail(ModelToString modelToString);

  Future<void> setDoubleDetail(ModelToString modelToString);

  Future<void> setDetailedStream() async {
    detailedModelListController.add([]);
    await getDetailedModelsFromRepo(detailedModelId!);
    detailedModelListController.add(detailedModelList);
  }

  Future<void> setDoubleDetailedStream()  async {
    doubleDetailedModelListController.add([]);
    await getDoubleDetailedModelsFromRepo(detailedModelId!, doubleDetailedModelId!);
    doubleDetailedModelListController.add(doubleDetailedModelList);
  }

  void changeScreen(StatsScreenEnum statsScreenEnum) {
    screenDetailController.add(statsScreenEnum);
  }

  void onRevertTap() {
    revertList = !revertList;
    revertModelList();
  }

  void revertModelList() {
    modelList = modelList.reversed.toList();
    modelListController.add(modelList);
  }


  Future<void> getFilteredModels(String? filter) async {
    filterText = filter;
    if (filter != null && filter.isNotEmpty) {
      await getModelsFromRepo(pickedSeasonId, matchStatsOrPlayerStats, filter);
    }
    else {
      await getModelsFromRepo(pickedSeasonId, matchStatsOrPlayerStats, null);
    }
    if(revertList) {
      revertModelList();
    }
    modelListController.add(modelList);
    overallStatsController.add(overallStats);
  }

  Future<void> getModelsFromRepo(int? seasonId, bool matchStatsOrPlayerStats, String? filter);

  Future<void> getDetailedModelsFromRepo(int id);

  Future<void> getDoubleDetailedModelsFromRepo(int firstId, int secondId);


  Future<List<SeasonApiModel>> getSeasons() async {
    seasonList = await seasonApiService.getSeasons(false, true, true);
    return seasonList;
  }

  Future<List<ModelToString>> getModels(bool matchStatsOrPlayerStats) async {
    this.matchStatsOrPlayerStats = matchStatsOrPlayerStats;
    revertList = false;
    filterText = null;
    return modelList;
  }

  Future<List<ModelToString>> getDetailedModels() async {
    setDetailedStream();
    return detailedModelList;
  }

  Future<List<ModelToString>> getDoubleDetailedModels() async {
    setDoubleDetailedStream();
    return doubleDetailedModelList;
  }

  String? getDetailString() {
    return detailString;
  }

}
