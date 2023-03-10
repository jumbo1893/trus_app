import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/models/beer_model.dart';
import 'package:trus_app/models/helper/beer_helper_model.dart';
import 'package:trus_app/models/player_model.dart';

import '../../../models/match_model.dart';
import '../repository/beer_repository.dart';

final beerControllerProvider = Provider((ref) {
  final beerRepository = ref.watch(beerRepositoryProvider);
  return BeerController(
      beerRepository: beerRepository, ref: ref);
});

class BeerController {
  final BeerRepository beerRepository;
  final ProviderRef ref;

  BeerController({
    required this.beerRepository,
    required this.ref,
  });

  bool simpleScreen = true;

  Stream<List<BeerModel>> beersInMatches() {
    return beerRepository.getBeersInMatches();
  }

  Stream<List<PlayerModel>> players() {
    return beerRepository.getPlayers();
  }

  Stream<List<BeerHelperModel>> beersByMatch(
      MatchModel match) {
    return beerRepository.getBeersInMatch(match);
  }

  Future<bool> addBeerInMatch(
    BuildContext context,
    String id,
    String matchId,
    String playerId,
    int beerNumber,
    int liquorNumber,
  ) async {
    bool result = await beerRepository.addBeerInMatch(
        context, id, matchId, playerId, beerNumber, liquorNumber);
    return result;
  }
}
