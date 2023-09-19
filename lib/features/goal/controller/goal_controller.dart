import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/features/general/confirm_operations.dart';
import 'package:trus_app/models/api/goal/goal_api_model.dart';
import 'package:trus_app/models/api/goal/goal_multi_add_response.dart';
import 'package:trus_app/models/api/goal/goal_setup.dart';
import 'package:trus_app/models/api/interfaces/confirm_to_string.dart';


import '../../../models/api/goal/goal_list_multi_add.dart';
import '../../../models/api/interfaces/add_to_string.dart';
import '../../general/future_add_controller.dart';
import '../goal_screens.dart';
import '../repository/goal_api_service.dart';

final goalControllerProvider = Provider((ref) {
  final goalApiService = ref.watch(goalApiServiceProvider);
  return GoalController(
      goalApiService: goalApiService,
      ref: ref);
});

class GoalController implements FutureAddController, ConfirmOperations {
  final GoalApiService goalApiService;
  final ProviderRef ref;
  final screenController =
  StreamController<GoalScreens>.broadcast();
  final rewriteFinesController = StreamController<bool>.broadcast();
  List<GoalSetup> goalSetupList = [];
  bool rewriteFinesInMatch = true;

  GoalController({
    required this.goalApiService,
    required this.ref,
  });

  Stream<GoalScreens> screen() {
    return screenController.stream;
  }

  Stream<bool> rewriteFines() {
    return rewriteFinesController.stream;
  }

  void setRewriteFines(bool rewrite) {
    rewriteFinesInMatch = rewrite;
    rewriteFinesController.add(rewriteFinesInMatch);
  }

  void initRewriteStream() {
    rewriteFinesController.add(rewriteFinesInMatch);
  }


  void navigateToGoalScreen() {
    screenController.add(GoalScreens.addGoals);
  }

  void navigateToAssistScreen() {
    screenController.add(GoalScreens.addAssists);
  }

  @override
  Future<List<AddToString>> getModels() async {
    return goalSetupList;
  }

  @override
  void addNumber(int index, bool goal) {
    goalSetupList[index].addNumber(goal);
  }

  @override
  void removeNumber(int index, bool goal) {
    goalSetupList[index].removeNumber(goal);
  }

  Future<void> setupMatch(int id) async {
    navigateToGoalScreen();
    goalSetupList = await goalApiService.setupGoal(id);
  }

  List<GoalApiModel> setListOfGoalApiModels(int matchId) {
    List<GoalApiModel> goalApiModels = [];
    for (GoalSetup goalSetup in goalSetupList) {
      goalApiModels.add(GoalApiModel(goalNumber: goalSetup.goalNumber,
          assistNumber: goalSetup.assistNumber,
          playerId: goalSetup.player.getId(),
          matchId: matchId,
          id: goalSetup.id));
    }
    return goalApiModels;
  }

  Future<GoalMultiAddResponse> _saveGoalsToRepository(GoalListMultiAdd goalListMultiAdd) async {
    return await goalApiService.addMultipleGoals(goalListMultiAdd);
  }

  @override
  Future<ConfirmToString> addModel(int matchId) async {
    GoalListMultiAdd goalListMultiAdd = GoalListMultiAdd(matchId: matchId, goalList: setListOfGoalApiModels(matchId), rewriteToFines: rewriteFinesInMatch);
    return await _saveGoalsToRepository(goalListMultiAdd);
  }
}
