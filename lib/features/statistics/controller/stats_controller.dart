import 'dart:async';

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

  SeasonModel? selectedSeason;

  Future<SeasonModel> currentSeason() async {
    return statsRepository.getCurrentSeason();
  }


  Stream<List<BeerStatsHelperModel>> beersForPlayersInSeason(SeasonModel? season) {

    return statsRepository.getBeersForPlayersInSeason(season);
  }

  Stream<List<BeerStatsHelperModel>> beersForMatchesInSeason(SeasonModel? season) {

    return statsRepository.getBeersForMatchesInSeason(selectedSeason);
  }

  Stream<List<FineStatsHelperModel>> finesForPlayersInSeason(SeasonModel? season) {

    return statsRepository.getFinesForPlayersInSeason(season);
  }

  Stream<List<FineStatsHelperModel>> finesForMatchesInSeason(SeasonModel? season) {

    return statsRepository.getFinesForMatchesInSeason(season);
  }

  Future<List<MatchModel>> matchNamesById(List<String> matchListId) async {
    return statsRepository.getMatchesById(matchListId);
  }

  Future<List<PlayerModel>> playerNamesById(List<String> playerListId) async {
    return statsRepository.getPlayersById(playerListId);
  }


}
