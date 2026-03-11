import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/features/general/state/loading_error_state.dart';
import 'package:trus_app/models/api/footbar/footbar_account_sessions.dart';
import 'package:trus_app/models/api/match/match_api_model.dart';
import 'package:trus_app/models/api/player/player_api_model.dart';

import '../../../models/api/footbar/footbar_session.dart';

class FootbarCompareState extends ErrorState {
  final AsyncValue<List<MatchApiModel>> matches;
  final MatchApiModel? selectedMatch;
  final FootbarAccountSessions? selectedAccountSession;
  final List<FootbarAccountSessions> sessions;
  final AsyncValue<List<PlayerApiModel>> players;
  final PlayerApiModel? leftSelectedPlayer;
  final PlayerApiModel? rightSelectedPlayer;
  final FootbarSession? leftSession;
  final FootbarSession? rightSession;

  const FootbarCompareState({
    required this.matches,
    required this.selectedMatch,
    required this.selectedAccountSession,
    required this.sessions,
    required this.players,
    required this.leftSelectedPlayer,
    required this.rightSelectedPlayer,
    required this.leftSession,
    required this.rightSession,
    super.errors,
  });

  factory FootbarCompareState.initial() => const FootbarCompareState(
        matches: AsyncValue.loading(),
        selectedMatch: null,
        selectedAccountSession: null,
        sessions: [],
        players: AsyncValue.loading(),
        leftSelectedPlayer: null,
        rightSelectedPlayer: null,
        leftSession: null,
        rightSession: null,
      );

  @override
  FootbarCompareState copyWith({
    AsyncValue<List<MatchApiModel>>? matches,
    Object? selectedMatch = _unset,
    Object? selectedAccountSession = _unset,
    List<FootbarAccountSessions>? sessions,
    AsyncValue<List<PlayerApiModel>>? players,
    Object? leftSelectedPlayer = _unset,
    Object? rightSelectedPlayer = _unset,
    Object? leftSession = _unset,
    Object? rightSession = _unset,
    Map<String, String>? errors,
  }) {
    return FootbarCompareState(
      matches: matches ?? this.matches,
      selectedMatch: identical(selectedMatch, _unset)
          ? this.selectedMatch
          : selectedMatch as MatchApiModel?,
      selectedAccountSession: identical(selectedAccountSession, _unset)
          ? this.selectedAccountSession
          : selectedAccountSession as FootbarAccountSessions?,
      sessions: sessions ?? this.sessions,
      players: players ?? this.players,
      leftSelectedPlayer: identical(leftSelectedPlayer, _unset)
          ? this.leftSelectedPlayer
          : leftSelectedPlayer as PlayerApiModel?,
      rightSelectedPlayer: identical(rightSelectedPlayer, _unset)
          ? this.rightSelectedPlayer
          : rightSelectedPlayer as PlayerApiModel?,
      leftSession: identical(leftSession, _unset)
          ? this.leftSession
          : leftSession as FootbarSession?,
      rightSession: identical(rightSession, _unset)
          ? this.rightSession
          : rightSession as FootbarSession?,
      errors: errors ?? this.errors,
    );
  }
}

const _unset = Object();
