import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/features/general/global_variables_controller.dart';
import 'package:trus_app/features/general/notifier/global_variables_notifier.dart';
import 'package:trus_app/features/general/notifier/safe_state_notifier.dart';
import 'package:trus_app/features/general/repository/api_result.dart';
import 'package:trus_app/features/main/controller/screen_variables_notifier.dart';
import 'package:trus_app/features/home/controller/home_notifier.dart';
import 'package:trus_app/features/home/repository/home_repository.dart';
import 'package:trus_app/features/match_participation/participation_flow.dart';
import 'package:trus_app/features/match_participation/repository/match_participation_repository.dart';
import 'package:trus_app/features/match_participation/screens/match_participation_screen.dart';
import 'package:trus_app/features/match_participation/state/match_participation_state.dart';
import 'package:trus_app/features/player/screens/add_player_screen.dart';
import 'package:trus_app/models/api/participation/match_participation_detail.dart';
import 'package:trus_app/models/api/participation/match_participation_status.dart';
import 'package:trus_app/models/api/participation/match_participation_reaction.dart';
import 'package:trus_app/models/api/player/player_api_model.dart';

final matchParticipationNotifierProvider = StateNotifierProvider.autoDispose
    .family<MatchParticipationNotifier, MatchParticipationState, int>(
      (ref, footballMatchId) => MatchParticipationNotifier(
        ref: ref,
        footballMatchId: footballMatchId,
        repository: ref.read(matchParticipationRepositoryProvider),
      ),
    );

class MatchParticipationNotifier
    extends SafeStateNotifier<MatchParticipationState> {
  final int footballMatchId;
  final MatchParticipationRepository repository;

  MatchParticipationNotifier({
    required Ref ref,
    required this.footballMatchId,
    required this.repository,
  }) : super(ref, MatchParticipationState.initial()) {
    Future.microtask(load);
  }

  Future<void> load() async {
    final detail = await AsyncValue.guard(
      () => runUiWithResult(
        () => repository.fetchDetail(footballMatchId),
        showLoading: false,
        successSnack: null,
      ),
    );
    if (!mounted) return;
    safeSetState(state.copyWith(detail: detail));
  }

  Future<void> respond(
    MatchParticipationStatus status, {
    PlayerApiModel? player,
    String? comment,
  }) async {
    late final ApiResult<MatchParticipationDetail> result;
    try {
      result = await runUi<MatchParticipationDetail>(
        () => repository.respond(
          footballMatchId: footballMatchId,
          status: status,
          playerId: player?.id,
          comment: comment,
        ),
        loadingMessage: 'Ukládám účast…',
        successSnack: 'Odpověď byla uložena',
      );
    } catch (_) {
      return;
    }
    if (!mounted) return;
    if (result case ApiFieldError<MatchParticipationDetail>()) {
      final fallbackMessage = result.fieldErrors.isEmpty
          ? 'Hráče se nepodařilo spárovat.'
          : result.fieldErrors.values.first;
      ui.showErrorDialog(
        result.fieldErrors['player'] ??
            result.fieldErrors['playerId'] ??
            fallbackMessage,
      );
      return;
    }
    if (result is! ApiSuccess<MatchParticipationDetail>) return;

    final detail = result.data;
    _applyCurrentPlayer(detail.currentPlayer);
    safeSetState(state.copyWith(detail: AsyncValue.data(detail)));
    ref.read(homeRepositoryProvider).invalidateSetup();
    ref.invalidate(homeNotifierProvider);
  }

  Future<void> addComment(String text, {int? parentCommentId}) async {
    try {
      final detail = await runUiWithResult<MatchParticipationDetail>(
        () => repository.addComment(
          footballMatchId: footballMatchId,
          text: text,
          parentCommentId: parentCommentId,
        ),
        loadingMessage: 'Ukládám komentář…',
        successSnack: 'Komentář byl přidán',
      );
      if (!mounted) return;
      safeSetState(state.copyWith(detail: AsyncValue.data(detail)));
    } catch (_) {
      return;
    }
  }

  Future<void> reactToComment(
    int commentId,
    MatchParticipationReaction reaction,
  ) async {
    try {
      final detail = await runUiWithResult<MatchParticipationDetail>(
        () =>
            repository.reactToComment(commentId: commentId, reaction: reaction),
        showLoading: false,
        successSnack: null,
      );
      if (!mounted) return;
      safeSetState(state.copyWith(detail: AsyncValue.data(detail)));
    } catch (_) {
      return;
    }
  }

  Future<void> deleteComment(int commentId) async {
    try {
      final detail = await runUiWithResult<MatchParticipationDetail>(
        () => repository.deleteComment(commentId),
        loadingMessage: 'Mažu komentář…',
        successSnack: 'Komentář byl smazán',
      );
      if (!mounted) return;
      safeSetState(state.copyWith(detail: AsyncValue.data(detail)));
    } catch (_) {
      return;
    }
  }

  void startNewPlayerFlow(MatchParticipationStatus status, {String? comment}) {
    ref
        .read(pendingParticipationProvider.notifier)
        .state = PendingParticipation(
      footballMatchId: footballMatchId,
      status: status,
      comment: comment,
    );
    ref
        .read(screenVariablesNotifierProvider.notifier)
        .setFootballMatchId(footballMatchId);
    changeFragment(AddPlayerScreen.id);
  }

  void openDetail() {
    ref
        .read(screenVariablesNotifierProvider.notifier)
        .setFootballMatchId(footballMatchId);
    changeFragment(MatchParticipationScreen.id);
  }

  void _applyCurrentPlayer(PlayerApiModel? player) {
    if (player == null) return;
    ref.read(globalVariablesControllerProvider).setPlayerApiModel(player);
    ref.read(globalVariablesProvider.notifier).setPlayer(player);
  }
}
