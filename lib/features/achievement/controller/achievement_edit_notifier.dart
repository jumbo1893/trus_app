import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/features/achievement/state/achievement_view_state.dart';
import 'package:trus_app/models/api/achievement/achievement_detail.dart';

import '../../../common/widgets/notifier/loader/loading_state.dart';
import '../../../models/enum/crud.dart';
import '../../general/notifier/base_crud_notifier.dart';
import '../../player/screens/view_player_screen.dart';
import '../achievement_view_args.dart';
import '../repository/achievement_repository.dart';
import 'achievement_notifier.dart';

final achievementViewProvider = StateNotifierProvider.autoDispose
    .family<AchievementEditNotifier, AchievementViewState, AchievementViewArgs>(
      (ref, args) {
    return AchievementEditNotifier(
      ref: ref,
      repository: ref.read(achievementRepositoryProvider),
      args: args,
    );
  },
);


class AchievementEditNotifier
    extends BaseCrudNotifier<AchievementDetail, AchievementViewState> {

  final AchievementRepository repository;
  final AchievementViewArgs args;

  AchievementEditNotifier({
    required Ref ref,
    required this.repository,
    required this.args,
  }) : super(ref,
    AchievementViewState.initial(),
  ) {
    Future.microtask(_init);
  }

  void _init() {
    /// 1️⃣ pokud je detail přímo v args (např. z listu)
    if (args.achievementDetail != null) {
      _applyDetail(args.achievementDetail!);
      return;
    }

    /// 2️⃣ detail podle playerAchievement
    if (args.playerAchievement != null) {
      _loadDetail(args.playerAchievement!.id);
    }
  }

  /// =========================
  /// STALE-WHILE-REVALIDATE
  /// =========================

  Future<void> _loadDetail(int id) async {
    final cached = repository.getCachedDetail(id);

    if (cached != null) {
      _applyDetail(cached);
    }
    final result = await runUiWithResult<AchievementDetail>(
          () => repository.fetchDetail(id),
      showLoading: (cached == null),
      successSnack: null,
    );
    if (!mounted) return;
    _applyDetail(result);
  }


  /// =========================
  /// APPLY DETAIL → STATE
  /// =========================
  void _applyDetail(AchievementDetail model) {
    state = AchievementViewState(
      name: model.achievement.name,
      description: model.achievement.description,
      accomplishedPlayers: model.accomplishedPlayers ?? "",
      secondaryCondition: model.achievement.secondaryCondition ?? "",
      successRate: model.getSuccessRate,
      playerAchievementAccomplished:
      model.isPlayerAchievementAccomplished ? "Ano" : "Ne",
      playerAchievementDetail: model.getPlayerAchievementDetail,
      playerAchievementMatch: model.getPlayerAchievementMatch,
      playerName: model.getPlayerAchievementName,
      accomplished: model.isPlayerAchievementAccomplished,
      manually: model.achievement.manually,
      model: model,
    );
  }

  /// =========================
  /// BaseCrudNotifier API
  /// =========================
  @override
  AchievementViewState copyWithState({
    LoadingState? loading,
    Map<String, String>? errors,
    String? successMessage,
  }) {
    return state.copyWith(
      errors: errors,
    );
  }

  /// =========================
  /// CRUD
  /// =========================

  void submitCrud(Crud crud) {
    submit(
      crud: crud,
      loadingText: switch (crud) {
        Crud.create => "",
        Crud.update => "Měním achievement...",
        Crud.delete => "",
      },
      successSnack: switch (crud) {
        Crud.create => "",
        Crud.update => "Achievement změněn",
        Crud.delete => "",
      },
      onSuccessRedirect: ViewPlayerScreen.id,
      invalidateProvider: achievementNotifierProvider,
    );
  }

  @override
  Future<void> update(AchievementDetail model) async {
    final playerAchievement = model.playerAchievement!;
    playerAchievement.changeAccomplished();
    repository.invalidateDetail(playerAchievement.id);
    await repository.api.editPlayerAchievement(
      playerAchievement,
      playerAchievement.id,
    );
  }

  @override
  Future<void> create(AchievementDetail model) async {
    throw UnimplementedError();
  }

  @override
  Future<void> delete(AchievementDetail model) async {
    throw UnimplementedError();
  }

  @override
  AchievementDetail buildModel() {
    return AchievementDetail(
      achievement: state.model!.achievement,
      playerAchievement: state.model!.playerAchievement!,
    );
  }

  @override
  bool validate() => true;
}
