import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/features/footbar/repository/footbar_api_service.dart';
import 'package:trus_app/features/match/repository/match_api_service.dart';
import 'package:trus_app/features/mixin/dropdown_controller_mixin.dart';
import 'package:trus_app/features/mixin/footbar_compare_controller_mixin.dart';
import 'package:trus_app/models/api/football/football_match_api_model.dart';
import 'package:trus_app/models/api/footbar/footbar_account_sessions.dart';

import '../../../common/utils/season_util.dart';
import '../../../config.dart';
import '../../../models/api/match/match_api_model.dart';
import '../../../models/api/season_api_model.dart';
import '../../main/screen_controller.dart';
import '../../season/repository/season_api_service.dart';

final footbarCompareControllerProvider = Provider((ref) {
  final matchApiService = ref.watch(matchApiServiceProvider);
  final seasonApiService = ref.watch(seasonApiServiceProvider);
  final footbarApiService = ref.watch(footbarApiServiceProvider);
  return FootbarCompareController(
      ref: ref,
    matchApiService: matchApiService,
    seasonApiService: seasonApiService,
    footbarApiService: footbarApiService,);
});

class FootbarCompareController with DropdownControllerMixin, FootbarCompareControllerMixin {
  final SeasonApiService seasonApiService;
  final MatchApiService matchApiService;
  final FootbarApiService footbarApiService;
  final Ref ref;
  List<SeasonApiModel> seasonList = [];
  List<MatchApiModel> matchList = [];
  List<FootbarAccountSessions> sessionsList = [];

  final String seasonKey = "footbar_season";
  final String matchKey = "footbar_match";
  final String footbarAccountListKey = "footbar_compare";

  FootbarCompareController({
    required this.seasonApiService,
    required this.matchApiService,
    required this.footbarApiService,
    required this.ref,
  });


  Future<void> initFootbarCompare() async {
    seasonList = await getSeasons();
    matchList = await getMatches(returnCurrentSeason(seasonList).id!);
    sessionsList = await getSessions(findMatchById(matchList, ref.read(screenControllerProvider).matchId)?.footballMatch);

  }

  Future<void> loadFootbalCompare() async {
    initDropdown(returnCurrentSeason(seasonList), seasonList, seasonKey);
    initDropdown(findMatchById(matchList, ref.read(screenControllerProvider).matchId), matchList, matchKey);
    initViewFields(sessionsList, footbarAccountListKey);
  }

  MatchApiModel? findMatchById(List<MatchApiModel> matchList, int? id) {
    if (matchList.isEmpty) return null;

    // když je id null → vrať první položku
    if (id == null) {
      return matchList.first;
    }

    // najdi první match s daným id
    return matchList.firstWhere(
          (m) => m.id == id,
      orElse: () => matchList.first, // když nenajde, vrátí první
    );
  }


  Future<List<MatchApiModel>> getMatches(int seasonId) async {
    if(seasonId == allSeasonId) {
      return await matchApiService.getMatches();
    }
    else {
      return await matchApiService.getMatchesBySeason(seasonId);
    }
  }

  Future<List<SeasonApiModel>> getSeasons() async {
    seasonList = await seasonApiService.getSeasons(false, true, true);
    return seasonList;
  }

  Future<List<FootbarAccountSessions>> getSessions(FootballMatchApiModel? footballMatch) async {
    if(footballMatch == null) {
      return [];
    }
    else {
      return await footbarApiService.getFootballMatchSessions(footballMatch.id!);
    }
  }

}
