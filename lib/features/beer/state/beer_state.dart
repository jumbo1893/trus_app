import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/features/general/state/loading_error_state.dart';
import 'package:trus_app/models/api/beer/beer_no_match_with_player.dart';
import 'package:trus_app/models/api/match/match_api_model.dart';

import '../../../common/widgets/notifier/loader/loading_state.dart';
import '../beer_screen_mode.dart';

class BeerState extends LoadingErrorState {
  final AsyncValue<List<MatchApiModel>> matches;
  final MatchApiModel? selectedMatch;

  final List<BeerNoMatchWithPlayer> beers;
  final BeerScreenMode mode;

  // paint helper
  final int playerIndex;

  const BeerState({
    required this.matches,
    required this.selectedMatch,
    required this.beers,
    required this.mode,
    required this.playerIndex,
    super.loading,
    super.errors,
    super.successMessage,
  });

  factory BeerState.initial() => const BeerState(
    matches: AsyncValue.loading(),
    selectedMatch: null,
    beers: [],
    mode: BeerScreenMode.list,
    playerIndex: 0,
  );

  @override
  BeerState copyWith({
    AsyncValue<List<MatchApiModel>>? matches,
    MatchApiModel? selectedMatch,
    bool clearSelectedMatch = false,

    List<BeerNoMatchWithPlayer>? beers,
    BeerScreenMode? mode,
    int? playerIndex,

    LoadingState? loading,
    Map<String, String>? errors,
    String? successMessage,
  }) {
    return BeerState(
      matches: matches ?? this.matches,
      selectedMatch: clearSelectedMatch ? null : (selectedMatch ?? this.selectedMatch),
      beers: beers ?? this.beers,
      mode: mode ?? this.mode,
      playerIndex: playerIndex ?? this.playerIndex,
      loading: loading ?? this.loading,
      errors: errors ?? this.errors,
      successMessage: successMessage ?? this.successMessage,
    );
  }

  bool get hasPlayers => beers.isNotEmpty;
}
