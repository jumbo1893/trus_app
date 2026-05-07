import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/features/general/state/loading_error_state.dart';
import 'package:trus_app/models/api/beer/beer_no_match_with_player.dart';
import 'package:trus_app/models/api/match/match_api_model.dart';

class BeerState extends ErrorState {
  final AsyncValue<List<MatchApiModel>> matches;
  final MatchApiModel? selectedMatch;

  final List<BeerNoMatchWithPlayer> beers;
  final List<String> initialBeerValues;
  final bool drawMode;

  final int playerIndex;

  const BeerState({
    required this.matches,
    required this.selectedMatch,
    required this.beers,
    required this.initialBeerValues,
    required this.drawMode,
    required this.playerIndex,
    super.errors,
  });

  factory BeerState.initial() => const BeerState(
    matches: AsyncValue.loading(),
    selectedMatch: null,
    beers: [],
    initialBeerValues: [],
    drawMode: false,
    playerIndex: 0,
  );

  bool get hasPlayers => beers.isNotEmpty;

  bool get hasChanges {
    if (beers.length != initialBeerValues.length) return false;

    for (int i = 0; i < beers.length; i++) {
      final current = '${beers[i].beerNumber}|${beers[i].liquorNumber}';
      if (current != initialBeerValues[i]) {
        return true;
      }
    }
    return false;
  }

  @override
  BeerState copyWith({
    AsyncValue<List<MatchApiModel>>? matches,
    MatchApiModel? selectedMatch,
    bool clearSelectedMatch = false,
    List<BeerNoMatchWithPlayer>? beers,
    List<String>? initialBeerValues,
    bool? drawMode,
    int? playerIndex,
    Map<String, String>? errors,
  }) {
    return BeerState(
      matches: matches ?? this.matches,
      selectedMatch: clearSelectedMatch ? null : (selectedMatch ?? this.selectedMatch),
      beers: beers ?? this.beers,
      initialBeerValues: initialBeerValues ?? this.initialBeerValues,
      drawMode: drawMode ?? this.drawMode,
      playerIndex: playerIndex ?? this.playerIndex,
      errors: errors ?? this.errors,
    );
  }
}