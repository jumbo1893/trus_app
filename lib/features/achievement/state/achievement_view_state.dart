import 'package:trus_app/models/api/achievement/achievement_detail.dart';

import '../../../common/widgets/notifier/loader/loading_state.dart';
import '../../general/state/base_crud_state.dart';

class AchievementViewState extends BaseCrudState<AchievementDetail> {
  final String name;
  final String description;
  final String secondaryCondition;
  final String successRate;
  final String accomplishedPlayers;
  final String? playerName;
  final String? playerAchievementAccomplished;
  final String? playerAchievementDetail;
  final String? playerAchievementMatch;
  final bool? manually;
  final bool? accomplished;

  const AchievementViewState({
    required this.name,
    required this.description,
    required this.secondaryCondition,
    required this.successRate,
    required this.accomplishedPlayers,
    this.playerName,
    this.playerAchievementAccomplished,
    this.playerAchievementDetail,
    this.playerAchievementMatch,
    this.manually,
    this.accomplished,
    AchievementDetail? model,
    super.loading,
    super.errors,
    super.successMessage,
  }) : super(model: model);

  factory AchievementViewState.initial() {
    return const AchievementViewState(
      name: "",
      description: "",
      secondaryCondition: "",
      successRate: "",
      accomplishedPlayers: "",
      errors: {},
    );
  }

  @override
  AchievementViewState copyWith({
    String? name,
    String? description,
    String? secondaryCondition,
    String? successRate,
    String? accomplishedPlayers,
    AchievementDetail? model,
    LoadingState? loading,
    Map<String, String>? errors,
    String? successMessage,
  }) {
    return AchievementViewState(
      name: name ?? this.name,
      description: description ?? this.description,
      secondaryCondition: secondaryCondition ?? this.secondaryCondition,
      successRate: successRate ?? this.successRate,
      accomplishedPlayers: accomplishedPlayers ?? this.accomplishedPlayers,
      model: model ?? this.model,
      loading: loading ?? this.loading,
      errors: errors ?? this.errors,
      successMessage: successMessage,
    );
  }
}
