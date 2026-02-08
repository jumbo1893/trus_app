import '../../../common/widgets/notifier/loader/loading_state.dart';
import '../../../models/api/goal/goal_setup.dart';
import '../../general/state/loading_error_state.dart';
import '../../main/state_back_condition.dart';
import '../goal_screens.dart';

class GoalState extends LoadingErrorState implements StateBackCondition {
  final GoalScreens screen;
  final List<GoalSetup> setups;
  final bool rewriteToFines;
  final int matchId;

  const GoalState({
    required this.screen,
    required this.setups,
    required this.rewriteToFines,
    required this.matchId,
    super.loading,
    super.errors,
    super.successMessage,
  });

  factory GoalState.initial() => const GoalState(
    screen: GoalScreens.addGoals,
    setups: [],
    rewriteToFines: true,
    matchId: -1,
  );

  @override
  GoalState copyWith({
    GoalScreens? screen,
    List<GoalSetup>? setups,
    bool? rewriteToFines,
    LoadingState? loading,
    Map<String, String>? errors,
    String? successMessage,
    int? matchId,
  }) {
    return GoalState(
      screen: screen ?? this.screen,
      setups: setups ?? this.setups,
      rewriteToFines: rewriteToFines ?? this.rewriteToFines,
      loading: loading ?? this.loading,
      errors: errors ?? this.errors,
      successMessage: successMessage ?? this.successMessage,
      matchId: matchId ?? this.matchId,
    );
  }

  @override
  bool isRootBack() => screen == GoalScreens.addAssists;
}
