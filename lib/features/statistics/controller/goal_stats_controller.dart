import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/features/statistics/controller/stats_controller.dart';
import 'package:trus_app/models/api/interfaces/model_to_string.dart';
import '../../../models/api/goal/goal_detailed_model.dart';
import '../../../models/api/goal/goal_detailed_response.dart';
import '../../goal/repository/goal_api_service.dart';
import '../../season/repository/season_api_service.dart';
import '../stats_screen_enum.dart';

final goalStatsControllerProvider = Provider((ref) {
  final goalApiRepository = ref.watch(goalApiServiceProvider);
  final seasonApiService = ref.watch(seasonApiServiceProvider);
  return GoalStatsController(
      goalApiRepository: goalApiRepository,
      seasonApiService: seasonApiService,
      ref: ref);
});

class GoalStatsController extends StatsController {
  final GoalApiService goalApiRepository;

  GoalStatsController({
    required this.goalApiRepository,
    required super.seasonApiService,
    required super.ref,
  });

  @override
  Future<void> setDetail(ModelToString modelToString) async {
    GoalDetailedModel goalDetailedModel = modelList
            .firstWhere((element) => element.getId() == modelToString.getId())
        as GoalDetailedModel;
    if (goalDetailedModel.player != null) {
      detailString =
          "${goalDetailedModel.player!.fan ? "fanouška" : "hráče"} ${goalDetailedModel.player!.name}";
      detailedModelId = goalDetailedModel.player!.id!;
    } else if (goalDetailedModel.match != null) {
      detailString = "zápas ${goalDetailedModel.match!.listViewTitle()}";
      detailedModelId = goalDetailedModel.match!.id!;
    } else {
      detailString = "?";
      detailedModelId = -1;
    }
    changeScreen(StatsScreenEnum.detailScreen);
  }

  @override
  Future<void> getModelsFromRepo(
      int? seasonId, bool matchStatsOrPlayerStats, String? filter) async {
    GoalDetailedResponse goalDetailedResponse = await goalApiRepository
        .getDetailedGoal(null, seasonId, null, matchStatsOrPlayerStats, filter);
    modelList = goalDetailedResponse.goalList;
    overallStats = goalDetailedResponse.overallStatsToString();
  }

  @override
  Future<void> getDetailedModelsFromRepo(int id) async {
    GoalDetailedResponse goalDetailedResponse;
    if (matchStatsOrPlayerStats) {
      goalDetailedResponse = await goalApiRepository.getDetailedGoal(
          id, pickedSeasonId, null, !matchStatsOrPlayerStats, null);
    } else {
      goalDetailedResponse = await goalApiRepository.getDetailedGoal(
          null, pickedSeasonId, id, !matchStatsOrPlayerStats, null);
    }
    detailedModelList = goalDetailedResponse.goalList;
  }

  @override
  Future<void> getDoubleDetailedModelsFromRepo(int firstId, int secondId) async {

  }

  @override
  Future<void> setDoubleDetail(ModelToString modelToString) async {

  }
}
