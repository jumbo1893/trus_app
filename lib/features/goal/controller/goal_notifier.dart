import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/features/goal/goal_screens.dart';
import 'package:trus_app/features/goal/repository/goal_api_service.dart';
import 'package:trus_app/features/goal/state/goal_state.dart';
import 'package:trus_app/features/home/screens/home_screen.dart';
import 'package:trus_app/features/main/screen_controller.dart';
import 'package:trus_app/models/api/goal/goal_api_model.dart';
import 'package:trus_app/models/api/goal/goal_list_multi_add.dart';

import '../../main/back_action.dart';

final goalNotifierProvider =
StateNotifierProvider.autoDispose<GoalNotifier, GoalState>((ref) {
  return GoalNotifier(
    api: ref.read(goalApiServiceProvider),
    screenController: ref.read(screenControllerProvider),
  );
});

class GoalNotifier extends StateNotifier<GoalState>
    implements BackAction {
  final GoalApiService api;
  final ScreenController screenController;

  GoalNotifier({
    required this.api,
    required this.screenController,
  }) : super(GoalState.initial());

  Future<void> setupMatch(int matchId) async {
    state = state.copyWith(
      loading: state.loading.loading("Načítám hráče…"),
    );
    try {
      final setups = await api.setupGoal(matchId);
      state = state.copyWith(
        setups: setups,
        screen: GoalScreens.addGoals,
        loading: state.loading.idle(),
        matchId: matchId
      );
    } catch (e) {
      state = state.copyWith(
        loading: state.loading.errorMessage(e.toString()),
      );
    }
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
    state = state.copyWith(
      loading: state.loading.loading("Ukládám…"),
    );

    final goals = _buildGoalModels();

    final payload = GoalListMultiAdd(
      matchId: state.matchId,
      goalList: goals,
      rewriteToFines: state.rewriteToFines,
    );

    try {
      final result = await api.addMultipleGoals(payload);

      state = state.copyWith(
        loading: state.loading.idle(),
        successMessage: result.toString(),
      );
      screenController.changeFragment(HomeScreen.id);
    } catch (e) {
      state = state.copyWith(
        loading: state.loading.errorMessage(e.toString()),
      );
      rethrow;
    }
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
