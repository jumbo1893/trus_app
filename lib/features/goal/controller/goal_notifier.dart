import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/features/general/notifier/app_notifier.dart';
import 'package:trus_app/features/goal/goal_screens.dart';
import 'package:trus_app/features/goal/repository/goal_api_service.dart';
import 'package:trus_app/features/goal/state/goal_state.dart';
import 'package:trus_app/features/home/screens/home_screen.dart';
import 'package:trus_app/features/main/controller/screen_variables_notifier.dart';
import 'package:trus_app/models/api/goal/goal_api_model.dart';
import 'package:trus_app/models/api/goal/goal_list_multi_add.dart';
import 'package:trus_app/models/api/goal/goal_setup.dart';

import '../../../models/api/goal/goal_multi_add_response.dart';
import '../../main/back_action.dart';

final goalNotifierProvider =
    StateNotifierProvider.autoDispose<GoalNotifier, GoalState>((ref) {
  return GoalNotifier(
    ref: ref,
    api: ref.read(goalApiServiceProvider),
    screenController: ref.read(screenVariablesNotifierProvider.notifier),
  );
});

class GoalNotifier extends AppNotifier<GoalState> implements BackAction {
  final GoalApiService api;
  final ScreenVariablesNotifier screenController;

  GoalNotifier({
    required Ref ref,
    required this.api,
    required this.screenController,
  }) : super(ref, GoalState.initial());

  Future<void> setupMatch(int matchId) async {
    final setups = await runUiWithResult<List<GoalSetup>>(
      () => api.setupGoal(matchId),
      showLoading: true,
      successSnack: null,
    );
    state = state.copyWith(
        setups: setups, screen: GoalScreens.addGoals, matchId: matchId);
  }

  // ==========================================================
  // NAVIGATION
  // ==========================================================

  void navigateToAssistScreen() {
    state = state.copyWith(screen: GoalScreens.addAssists);
  }

  void navigateToGoalScreen() {
    state = state.copyWith(screen: GoalScreens.addGoals);
  }

  // ==========================================================
  // SWITCH
  // ==========================================================

  void setRewriteToFines(bool value) {
    state = state.copyWith(rewriteToFines: value);
  }

  // ==========================================================
  // LISTVIEW / ADD BUILDER
  // ==========================================================

  void addNumber(int index, bool goal) {
    final list = [...state.setups];
    list[index].addNumber(goal);
    state = state.copyWith(setups: list);
  }

  void removeNumber(int index, bool goal) {
    final list = [...state.setups];
    list[index].removeNumber(goal);
    state = state.copyWith(setups: list);
  }

  // ==========================================================
  // CONFIRM
  // ==========================================================

  void changeGoals() async {
    final goals = _buildGoalModels();

    final payload = GoalListMultiAdd(
      matchId: state.matchId,
      goalList: goals,
      rewriteToFines: state.rewriteToFines,
    );
    final result = await runUiWithResult<GoalMultiAddResponse>(
      () => api.addMultipleGoals(payload),
      showLoading: true,
      successResultSnack: true
    );
    changeFragment(HomeScreen.id);
  }

  List<GoalApiModel> _buildGoalModels() {
    return state.setups
        .map(
          (s) => GoalApiModel(
            id: s.id,
            matchId: state.matchId,
            playerId: s.player.getId(),
            goalNumber: s.goalNumber,
            assistNumber: s.assistNumber,
          ),
        )
        .toList();
  }

  @override
  void backToRoot() {
    state = state.copyWith(
      screen: GoalScreens.addGoals,
    );
  }

  @override
  bool isRootBack() {
    return state.screen == GoalScreens.addAssists;
  }
}
