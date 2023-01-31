import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/models/helper/beer_stats_helper_model.dart';
import 'package:trus_app/models/helper/fine_stats_helper_model.dart';
import 'package:trus_app/models/match_model.dart';
import 'package:trus_app/models/player_model.dart';

import '../../../models/season_model.dart';
import '../repository/stats_repository.dart';

final statsControllerProvider = Provider((ref) {
  final statsRepository = ref.watch(statsRepositoryProvider);
  return StatsController(statsRepository: statsRepository, ref: ref);
});

class StatsController {
  final StatsRepository statsRepository;
  final ProviderRef ref;

  StatsController({
    required this.statsRepository,
    required this.ref,
  });

  Stream<List<BeerStatsHelperModel>> beersForPlayersInSeason(String seasonId) {

    return statsRepository.getBeersForPlayersInSeason(seasonId);
  }

  Stream<List<BeerStatsHelperModel>> beersForMatchesInSeason(String seasonId) {

    return statsRepository.getBeersForMatchesInSeason(seasonId);
  }

  Stream<List<FineStatsHelperModel>> finesForPlayersInSeason(String seasonId) {

    return statsRepository.getFinesForPlayersInSeason(seasonId);
  }

  Stream<List<FineStatsHelperModel>> finesForMatchesInSeason(String seasonId) {

    return statsRepository.getFinesForMatchesInSeason(seasonId);
  }

  Future<List<MatchModel>> matchNamesById(List<String> matchListId) async {
    return statsRepository.getMatchesById(matchListId);
  }

  Future<List<PlayerModel>> playerNamesById(List<String> playerListId) async {
    return statsRepository.getPlayersById(playerListId);
  }


}
