import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/features/general/state/loading_error_state.dart';
import 'package:trus_app/models/api/match/match_api_model.dart';
import 'package:trus_app/models/api/player/player_api_model.dart';
import 'package:trus_app/models/api/receivedfine/stats/received_fine_stats_detail_models.dart';

class FineMatchState extends ErrorState {
  final AsyncValue<List<MatchApiModel>> matches;
  final MatchApiModel? selectedMatch;
  final List<PlayerApiModel> playersInMatch;
  final List<PlayerApiModel> otherPlayers;
  final List<PlayerApiModel> checkedPlayers;
  final List<PlayerApiModel> allPlayers;
  final Map<int, PlayerWithFinesModel> playerFineSummaryByPlayerId;
  final bool multiCheck;

  const FineMatchState({
    required this.matches,
    required this.selectedMatch,
    required this.playersInMatch,
    required this.otherPlayers,
    required this.checkedPlayers,
    required this.allPlayers,
    required this.playerFineSummaryByPlayerId,
    required this.multiCheck,
    super.errors,
  });

  factory FineMatchState.initial() => const FineMatchState(
    matches: AsyncValue.loading(),
    selectedMatch: null,
    playersInMatch: [],
    otherPlayers: [],
    checkedPlayers: [],
    allPlayers: [],
    playerFineSummaryByPlayerId: {},
    multiCheck: false,
  );

  @override
  FineMatchState copyWith({
    AsyncValue<List<MatchApiModel>>? matches,
    MatchApiModel? selectedMatch,
    bool clearSelectedMatch = false,
    List<PlayerApiModel>? playersInMatch,
    List<PlayerApiModel>? otherPlayers,
    List<PlayerApiModel>? checkedPlayers,
    List<PlayerApiModel>? allPlayers,
    Map<int, PlayerWithFinesModel>? playerFineSummaryByPlayerId,
    bool? multiCheck,
    Map<String, String>? errors,
  }) {
    return FineMatchState(
      matches: matches ?? this.matches,
      selectedMatch:
      clearSelectedMatch ? null : (selectedMatch ?? this.selectedMatch),
      playersInMatch: playersInMatch ?? this.playersInMatch,
      otherPlayers: otherPlayers ?? this.otherPlayers,
      checkedPlayers: checkedPlayers ?? this.checkedPlayers,
      allPlayers: allPlayers ?? this.allPlayers,
      playerFineSummaryByPlayerId:
      playerFineSummaryByPlayerId ?? this.playerFineSummaryByPlayerId,
      multiCheck: multiCheck ?? this.multiCheck,
      errors: errors ?? this.errors,
    );
  }
}