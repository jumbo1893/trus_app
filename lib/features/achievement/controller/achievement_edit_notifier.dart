import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/features/achievement/state/achievement_view_state.dart';
import 'package:trus_app/models/api/achievement/achievement_detail.dart';

import '../../../common/widgets/notifier/loader/loading_state.dart';
import '../../general/notifier/base_crud_notifier.dart';
import '../../general/repository/api_result.dart';
import '../../main/screen_controller.dart';
import '../achievement_view_args.dart';
import '../repository/achievement_repository.dart';

final achievementViewProvider = StateNotifierProvider.autoDispose
    .family<AchievementEditNotifier, AchievementViewState, AchievementViewArgs>(
      (ref, args) {
    return AchievementEditNotifier(
      repository: ref.read(achievementRepositoryProvider),
      args: args,
      screenController: ref.read(screenControllerProvider),
    );
  },
);


class AchievementEditNotifier
    extends BaseCrudNotifier<AchievementDetail, AchievementViewState> {

  final AchievementRepository repository;
  final AchievementViewArgs args;

  AchievementEditNotifier({
    required this.repository,
    required this.args,
    required ScreenController screenController,
  }) : super(
    AchievementViewState.initial(),
    screenController,
  ) {
    _init();
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
    /// 1️⃣ CACHE → UI
    final cached = repository.getCachedDetail(id);
    if (cached != null) {
      _applyDetail(cached);
    } else {
      state = copyWithState(
        loading: state.loading.loading("Načítám detail…"),
      );
    }

    /// 2️⃣ API NA POZADÍ
    await _refreshFromServer(id);
  }

  Future<void> _refreshFromServer(int id) async {
    final result = await executeApi(
          () => repository.fetchDetail(id),
    );

    if (!mounted) return;

    switch (result) {
      case ApiSuccess<AchievementDetail>():
        _applyDetail(result.data);
        break;

      case ApiError():
      /// ❗ error zobrazujeme jen pokud nebyla cache
        if (state.model == null) {
          state = copyWithState(
            loading: state.loading.errorMessage(result.message),
          );
        }
        break;

      default:
        break;
    }
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
      loading: state.loading.idle(),
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
      loading: loading,
      errors: errors,
      successMessage: successMessage,
    );
  }

  @override
  AchievementDetail buildModel() {
    return AchievementDetail(
      achievement: state.model!.achievement,
      playerAchievement: state.model!.playerAchievement!,
    );
  }

  @override
  Future<ApiResult<void>> create(AchievementDetail model) {
    throw UnimplementedError();
  }

  @override
  Future<ApiResult<void>> delete(AchievementDetail model) {
    throw UnimplementedError();
  }

  @override
  Future<ApiResult<void>> update(AchievementDetail model) {
    final playerAchievement = model.playerAchievement!;
    playerAchievement.changeAccomplished();

    /// ❗ po update můžeš invalidovat cache
    repository.invalidateDetail(playerAchievement.id);

    return executeApi(
          () => repository.api.editPlayerAchievement(
        playerAchievement,
        playerAchievement.id,
      ),
    );
  }

  @override
  bool validate() => true;
}
