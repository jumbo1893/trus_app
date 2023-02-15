import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/features/fine/match/repository/fine_match_repository.dart';
import 'package:trus_app/features/match/repository/match_repository.dart';
import 'package:trus_app/features/pkfl/repository/pkfl_repository.dart';
import 'package:trus_app/models/helper/player_stats_helper_model.dart';
import 'package:trus_app/models/match_model.dart';
import 'package:trus_app/models/pkfl/pkfl_player_stats.dart';

import '../../../models/pkfl/pkfl_match.dart';
import '../../../models/season_model.dart';
import '../../pkfl/tasks/retrieve_matches_task.dart';

final matchControllerProvider = Provider((ref) {
  final matchRepository = ref.watch(matchRepositoryProvider);
  final fineMatchRepository = ref.watch(fineMatchRepositoryProvider);
  final pkflRepository = ref.watch(pkflRepositoryProvider);
  return MatchController(matchRepository: matchRepository, fineMatchRepository: fineMatchRepository, pkflRepository: pkflRepository, ref: ref);
});

class MatchController {
  final MatchRepository matchRepository;
  final FineMatchRepository fineMatchRepository;
  final PkflRepository pkflRepository;
  final ProviderRef ref;

  MatchController({
    required this.matchRepository,
    required this.fineMatchRepository,
    required this.pkflRepository,
    required this.ref,
  });

  Stream<List<MatchModel>> matches() {
    return matchRepository.getMatches();
  }

  Stream<List<MatchModel>> matchesBySeason(String seasonId) {
    if(seasonId == "" || seasonId == SeasonModel.allSeason().id) {
      return matchRepository.getMatches();
    }
    return matchRepository.getMatchesBySeason(seasonId);
  }

  Stream<List<PlayerStatsHelperModel>> playersStatsInMatch(List<String> playerIdList, String matchId) {
    return matchRepository.getPlayersStatsForMatch(matchId, playerIdList);
  }
  
  Future<bool> addPlayerStatsInMatch(
      BuildContext context,
      String id,
      String matchId,
      String playerId,
      int goalNumber,
      int assistNumber) async {
    bool result = await matchRepository.addPlayerStatsInMatch(context, id, matchId, playerId, goalNumber, assistNumber);
    return result;
  }

  Future<bool> addFinesInMatch(
      BuildContext context,
      String matchId,
      String playerId,
      String fineId,
      int number,
      ) async {
    bool result = await fineMatchRepository.addMultipleFinesInMatch(
        context, matchId, fineId, playerId, number, true);
    return result;
  }

  Future<MatchModel?> addMatch(
    BuildContext context,
    String name,
    DateTime date,
    bool home,
      List<String> playerIdList,
      String seasonId,
  ) async {
    MatchModel? result = await matchRepository.addMatch(context, name, date, home, playerIdList, seasonId);
    return result;
  }

  Future<bool> editMatch(
      BuildContext context,
      String name,
      DateTime date,
      bool home,
      List<String> playerIdList,
      String seasonId,
      MatchModel matchModel,
      ) async {
    bool result = await matchRepository.editMatch(context, name, date, home, playerIdList, seasonId, matchModel);
    return result;
  }

  Future<void> deleteMatch(
      BuildContext context,
      MatchModel matchModel,
      ) async {
    await matchRepository.deleteMatch(context, matchModel);
  }

  Future<PkflMatch?> getLastPkflMatch() async {
    String url = "";
    List<PkflMatch> matches = [];
    url = await pkflRepository.getPkflTeamUrl();
    RetrieveMatchesTask matchesTask = RetrieveMatchesTask(url);
    try {
      await matchesTask.returnPkflMatches().then((value) => matches = value);
    } catch (e, stacktrace) {
      print(stacktrace);
    }

    return returnLastPkflMatch(matches);
  }

  PkflMatch? returnLastPkflMatch(List<PkflMatch> pkflMatches) {
    PkflMatch? returnMatch;
    for (PkflMatch pkflMatch in pkflMatches) {
      if (pkflMatch.date.isAfter(DateTime.now())) {
        if (returnMatch == null || returnMatch.date.isBefore(pkflMatch.date)) {
          returnMatch = pkflMatch;
        }
      }
    }
    return returnMatch;
  }
}
