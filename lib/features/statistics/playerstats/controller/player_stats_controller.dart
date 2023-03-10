import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/models/match_model.dart';
import 'package:trus_app/models/player_model.dart';

import '../../../../models/helper/player_stats_helper_model.dart';
import '../../../../models/season_model.dart';
import '../../repository/stats_repository.dart';

final playerStatsControllerProvider = Provider((ref) {
  final statsRepository = ref.watch(statsRepositoryProvider);
  return PlayerStatsController(statsRepository: statsRepository, ref: ref);
});

class PlayerStatsController {
  final StatsRepository statsRepository;
  final ProviderRef ref;

  PlayerStatsController({
    required this.statsRepository,
    required this.ref,
  });

  SeasonModel? selectedSeason;

  Future<SeasonModel> currentSeason() async {
    return statsRepository.getCurrentSeason();
  }


  Stream<List<PlayerStatsHelperModel>> playerStatsForPlayersInSeason(SeasonModel? season) {

    return statsRepository.getPlayerStatsForPlayersInSeason(season);
  }

  Future<List<MatchModel>> matchNamesById(List<String> matchListId) async {
    return statsRepository.getMatchesById(matchListId);
  }

  Future<List<PlayerModel>> playerNamesById(List<String> playerListId) async {
    return statsRepository.getPlayersById(playerListId);
  }


}
