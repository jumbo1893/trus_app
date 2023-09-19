import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/models/api/interfaces/model_to_string.dart';
import '../../../common/utils/season_util.dart';
import '../../../models/api/goal/goal_detailed_model.dart';
import '../../../models/api/goal/goal_detailed_response.dart';
import '../../../models/api/season_api_model.dart';
import '../../goal/repository/goal_api_service.dart';
import '../../season/repository/season_api_service.dart';

final goalStatsControllerProvider = Provider((ref) {
  final goalApiRepository = ref.watch(goalApiServiceProvider);
  final seasonApiService = ref.watch(seasonApiServiceProvider);
  return GoalStatsController(
      goalApiRepository: goalApiRepository,
      seasonApiService: seasonApiService,
      ref: ref);
});

class GoalStatsController {
  final GoalApiService goalApiRepository;
  final SeasonApiService seasonApiService;
  final ProviderRef ref;

  GoalStatsController({
    required this.goalApiRepository,
    required this.seasonApiService,
    required this.ref,
  });

  List<SeasonApiModel> seasonList = [];
  List<GoalDetailedModel> goalList = [];
  List<GoalDetailedModel> detailedGoalList = [];
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
  final goalListController =
  StreamController<List<GoalDetailedModel>>.broadcast();
  final detailedGoalListController =
  StreamController<List<GoalDetailedModel>>.broadcast();
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
    await getGoals(season.id, matchStatsOrPlayerStats, filterText);
    if(revertList) {
      revertGoalList();
    }
    goalListController.add(goalList);
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

  Stream<List<GoalDetailedModel>> goalListStream() {
    return goalListController.stream;
  }

  Stream<List<GoalDetailedModel>> detailedGoalListStream() {
    return detailedGoalListController.stream;
  }

  Stream<bool> screenDetailStream() {
    return screenDetailController.stream;
  }

  void initOverallStats() {
    overallStatsController.add(overallStats);
  }

  Future<void> setDetail(ModelToString modelToString) async {
    GoalDetailedModel goalDetailedModel = goalList.firstWhere((element) => element.id == modelToString.getId());
    if(goalDetailedModel.player != null) {
      detailString = "${goalDetailedModel.player!.fan ? "fanouška" : "hráče"} ${goalDetailedModel.player!.name}";
      detailedModelId = goalDetailedModel.player!.id!;

    }
    else if (goalDetailedModel.match != null) {
      detailString = "zápas ${goalDetailedModel.match!.listViewTitle()}";
      detailedModelId = goalDetailedModel.match!.id!;
    }
    else {
      detailString = "?";
      detailedModelId = -1;
    }
    changeScreen(true);
  }

  Future<void> setDetailedStream()  async {
    detailedGoalListController.add([]);
    await getDetailedBeers(detailedModelId!);
    detailedGoalListController.add(detailedGoalList);
  }

  void changeScreen(bool detail) {
    screenDetailController.add(detail);
  }

  void onRevertTap() {
    revertList = !revertList;
    revertGoalList();
  }

  void revertGoalList() {
    goalList = goalList.reversed.toList();
    goalListController.add(goalList);
  }


  Future<void> getFilteredGoals(String? filter) async {
    filterText = filter;
    if (filter != null && filter.isNotEmpty) {
      await getGoals(pickedSeasonId, matchStatsOrPlayerStats, filter);
    }
    else {
      await getGoals(pickedSeasonId, matchStatsOrPlayerStats, null);
    }
    if(revertList) {
      revertGoalList();
    }
    goalListController.add(goalList);
    overallStatsController.add(overallStats);
  }

  Future<void> getGoals(int? seasonId, bool matchStatsOrPlayerStats, String? filter) async {
    GoalDetailedResponse goalDetailedResponse = await goalApiRepository.getDetailedGoal(null, seasonId, null, matchStatsOrPlayerStats, filter);
    goalList = goalDetailedResponse.goalList;
    overallStats = goalDetailedResponse.overallStatsToString();
  }

  Future<void> getDetailedBeers(int id) async {
    GoalDetailedResponse goalDetailedResponse;
    if(matchStatsOrPlayerStats) {
      goalDetailedResponse = await goalApiRepository.getDetailedGoal(id, pickedSeasonId, null, !matchStatsOrPlayerStats, null);
    }
    else {
      goalDetailedResponse = await goalApiRepository.getDetailedGoal(null, pickedSeasonId, id, !matchStatsOrPlayerStats, null);
    }
    detailedGoalList = goalDetailedResponse.goalList;
  }


  Future<List<SeasonApiModel>> getSeasons() async {
    seasonList = await seasonApiService.getSeasons(false, true, true);
    return seasonList;
  }

  Future<List<ModelToString>> getModels(bool matchStatsOrPlayerStats) async {
    this.matchStatsOrPlayerStats = matchStatsOrPlayerStats;
    revertList = false;
    filterText = null;
    return goalList;
  }

  Future<List<ModelToString>> getDetailedModels() async {
    setDetailedStream();
    return detailedGoalList;
  }

}
