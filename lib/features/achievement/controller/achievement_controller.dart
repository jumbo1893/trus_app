import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/features/achievement/repository/achievement_api_service.dart';
import 'package:trus_app/features/achievement/widget/i_achievement_hash_key.dart';
import 'package:trus_app/features/achievement/widget/i_achievement_needed_fields.dart';
import 'package:trus_app/features/general/crud_operations.dart';
import 'package:trus_app/features/mixin/view_controller_mixin.dart';
import 'package:trus_app/models/api/achievement/achievement_detail.dart';
import 'package:trus_app/models/api/achievement/player_achievement_api_model.dart';
import 'package:trus_app/models/api/interfaces/model_to_string.dart';

import '../../general/read_operations.dart';

final achievementControllerProvider = Provider((ref) {
  final achievementApiService = ref.watch(achievementApiServiceProvider);
  return AchievementController(
      achievementApiService: achievementApiService, ref: ref);
});

class AchievementController with ViewControllerMixin implements ReadOperations, IAchievementHashKey, IAchievementNeededFields, CrudOperations {
  final AchievementApiService achievementApiService;
  final Ref ref;
  late AchievementDetail achievementDetail;

  AchievementController({
    required this.achievementApiService,
    required this.ref,
  });

  void loadViewAchievement() {
    initViewFields(achievementDetail.getPlayerAchievementName, playerName());
    initViewFields(achievementDetail.achievement.name, nameKey());
    initViewFields(achievementDetail.achievement.description, description());
    initViewFields(achievementDetail.achievement.secondaryCondition?? "-", secondaryCondition());
    initViewFields(achievementDetail.isPlayerAchievementAccomplished? "Ano" : "Ne", accomplished());
    initViewFields(achievementDetail.getPlayerAchievementDetail, detail());
    initViewFields(achievementDetail.getPlayerAchievementMatch, match());
    initViewFields(achievementDetail.getSuccessRate, successRate());
    initViewFields(achievementDetail.accomplishedPlayers?? "", playerList());
  }

  void loadListAchievement(AchievementDetail achievement) {
    initViewFields(achievement.achievement.name, nameKey());
    initViewFields(achievement.achievement.description, description());
    initViewFields(achievement.achievement.secondaryCondition?? "-", secondaryCondition());
    initViewFields(achievement.getSuccessRate, successRate());
    initViewFields(achievement.accomplishedPlayers?? "", playerList());
  }

  Future<void> achievement(AchievementDetail achievement) async {
    achievementDetail = achievement;
    Future.delayed(
        Duration.zero,
            () => loadListAchievement(achievement));
  }

  Future<void> setupAchievementDetail(int id) async {
    achievementDetail = await _getAchievementDetail(id);
  }

  Future<void> viewAchievement() async {
    Future.delayed(Duration.zero, () => loadViewAchievement());
  }

  Future<AchievementDetail> _getAchievementDetail(int id) async {
    return await achievementApiService.getAchievementDetail(id);
  }

  @override
  Future<List<AchievementDetail>> getModels() async {
    return await achievementApiService.getAllDetailed();
  }

  @override
  String accomplished() {
    return "achievement_accomplished";
  }

  @override
  String description() {
    return "achievement_description";
  }

    @override
  String detail() {
      return "achievement_detail";
  }

  @override
  String match() {
    return "achievement_match";
  }

  @override
  String nameKey() {
    return "achievement_name";
  }

  @override
  String secondaryCondition() {
    return "achievement_secondary_condition";
  }

  @override
  String successRate() {
    return "achievement_success_rate";
  }

  @override
  String playerName() {
    return "achievement_player_name";
  }

  @override
  String playerList() {
    return "achievement_player_list";
  }

  @override
  bool isNeededToShowSecondaryConditionField() {
    return achievementDetail.achievement.secondaryCondition != null;
  }

  @override
  bool isNeededToShowPlayerAchievementsFields() {
    return achievementDetail.playerAchievement != null;
  }

  @override
  bool isNeededToShowMatchField() {
    return (isNeededToShowPlayerAchievementsFields() && (achievementDetail.playerAchievement!.match != null || achievementDetail.playerAchievement!.footballMatch != null));
  }

  @override
  bool isNeededToShowDetailField() {
    return (isNeededToShowPlayerAchievementsFields() && achievementDetail.playerAchievement!.detail != null && achievementDetail.playerAchievement!.detail!.isNotEmpty);
  }

  @override
  bool isNeededToShowPlayerListField() {
    return (achievementDetail.accomplishedPlayers != null && achievementDetail.accomplishedPlayers!.isNotEmpty);
  }

  @override
  Future<ModelToString?> addModel() {
    // TODO: implement addModel
    throw UnimplementedError();
  }

  @override
  Future<String> deleteModel(int id) async {
    throw UnimplementedError();
  }

  @override
  Future<String?> editModel(int id) async {
    PlayerAchievementApiModel playerAchievementApiModel = achievementDetail.playerAchievement!;
    playerAchievementApiModel.changeAccomplished();
    PlayerAchievementApiModel response = await achievementApiService.editPlayerAchievement(playerAchievementApiModel, id);
    return response.toStringForEdit("");
  }

  @override
  bool isNeededToShowChangeAccomplishedButton() {
    return (isNeededToShowPlayerAchievementsFields() && (achievementDetail.achievement.manually));
  }
}
