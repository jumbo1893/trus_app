import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/features/general/state/loading_error_state.dart';
import 'package:trus_app/models/api/beer/beer_no_match_with_player.dart';
import 'package:trus_app/models/api/beer/pub_attendance.dart';
import 'package:trus_app/models/api/match/match_api_model.dart';

class BeerState extends ErrorState {
  final AsyncValue<List<MatchApiModel>> matches;
  final MatchApiModel? selectedMatch;
  final PubAttendance? pubAttendance;

  final List<BeerNoMatchWithPlayer> beers;
  final List<String> initialBeerValues;
  final bool saving;
  final bool saveFailed;

  final int playerIndex;

  const BeerState({
    required this.matches,
    required this.selectedMatch,
    required this.pubAttendance,
    required this.beers,
    required this.initialBeerValues,
    required this.saving,
    required this.saveFailed,
    required this.playerIndex,
    super.errors,
  });

  factory BeerState.initial() => const BeerState(
    matches: AsyncValue.loading(),
    selectedMatch: null,
    pubAttendance: null,
    beers: [],
    initialBeerValues: [],
    saving: false,
    saveFailed: false,
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
    PubAttendance? pubAttendance,
    bool clearPubAttendance = false,
    bool clearSelectedMatch = false,
    List<BeerNoMatchWithPlayer>? beers,
    List<String>? initialBeerValues,
    bool? saving,
    bool? saveFailed,
    int? playerIndex,
    Map<String, String>? errors,
  }) {
    return BeerState(
      matches: matches ?? this.matches,
      selectedMatch: clearSelectedMatch
          ? null
          : (selectedMatch ?? this.selectedMatch),
      pubAttendance: clearPubAttendance
          ? null
          : (pubAttendance ?? this.pubAttendance),
      beers: beers ?? this.beers,
      initialBeerValues: initialBeerValues ?? this.initialBeerValues,
      saving: saving ?? this.saving,
      saveFailed: saveFailed ?? this.saveFailed,
      playerIndex: playerIndex ?? this.playerIndex,
      errors: errors ?? this.errors,
    );
  }
}
