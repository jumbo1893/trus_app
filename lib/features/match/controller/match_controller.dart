import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/features/match/repository/match_repository.dart';
import 'package:trus_app/models/match_model.dart';

import '../../../models/season_model.dart';

final matchControllerProvider = Provider((ref) {
  final matchRepository = ref.watch(matchRepositoryProvider);
  return MatchController(matchRepository: matchRepository, ref: ref);
});

class MatchController {
  final MatchRepository matchRepository;
  final ProviderRef ref;

  MatchController({
    required this.matchRepository,
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

  Future<bool> addMatch(
    BuildContext context,
    String name,
    DateTime date,
    bool home,
      List<String> playerIdList,
      String seasonId,
  ) async {
    bool result = await matchRepository.addMatch(context, name, date, home, playerIdList, seasonId);
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
}
