import 'package:flutter/foundation.dart';
import '../../../common/widgets/entry_draft_scope.dart';
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
  Map<String, int> _baseline = {};
  String get draftId => 'goals:${state.matchId}';
  Map<String, int> get draftValues => {
    for (final g in state.setups) ...{
      '${g.player.id}:g': g.goalNumber,
      '${g.player.id}:a': g.assistNumber,
    },
    'rewrite': state.rewriteToFines ? 1 : 0,
  };
  Map<String, int> get draftBaseline => {..._baseline};
  bool get hasChanges => !mapEquals(draftValues, _baseline);
  void restoreDraft(Map<String, int> values) {
    for (final g in state.setups) {
      g.goalNumber = values['${g.player.id}:g'] ?? g.goalNumber;
      g.assistNumber = values['${g.player.id}:a'] ?? g.assistNumber;
    }
    state = state.copyWith(
      setups: [...state.setups],
      rewriteToFines: (values['rewrite'] ?? 1) != 0,
    );
  }

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
    _baseline = {
      for (final g in setups) ...{
        '${g.player.id}:g': g.goalNumber,
        '${g.player.id}:a': g.assistNumber,
      },
      'rewrite': 1,
    };
    state = state.copyWith(
      rewriteToFines: true,
      setups: setups,
      screen: GoalScreens.addGoals,
      matchId: matchId,
    );
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

  Future<void> changeGoals({bool navigate = true}) async {
    final goals = _buildGoalModels();

    final payload = GoalListMultiAdd(
      matchId: state.matchId,
      goalList: goals,
      rewriteToFines: state.rewriteToFines,
    );
    await runUiWithResult<GoalMultiAddResponse>(
      () => api.addMultipleGoals(payload),
      showLoading: true,
      successSnack: null,
    );
    if (!mounted) return;
    _baseline = draftValues;
    state = state.copyWith(setups: [...state.setups]);
    await clearEntryDraft(ref, draftId);
    ui.showSnack(
      state.rewriteToFines
          ? 'Góly a asistence uloženy. Pokuty za góly a hattricky byly přepočítány.'
          : 'Góly a asistence jsou uložené',
    );
    if (mounted && navigate) changeFragment(HomeScreen.id);
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
    state = state.copyWith(screen: GoalScreens.addGoals);
  }

  @override
  bool isRootBack() {
    return state.screen == GoalScreens.addAssists;
  }
}
