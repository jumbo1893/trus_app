import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/features/mixin/view_controller_mixin.dart';
import 'package:trus_app/models/api/football/detail/football_team_detail.dart';
import 'package:trus_app/models/api/football/football_match_api_model.dart';

import '../../../../models/api/football/helper/mutual_matches.dart';
import '../../../../models/api/football/table_team_api_model.dart';
import '../../../general/read_operations.dart';
import '../../repository/football_api_service.dart';
import '../widget/i_football_team_detail_key.dart';

final footballTableTeamControllerProvider = Provider((ref) {
  final footballApiService = ref.watch(footballApiServiceProvider);
  return FootballTableTeamController(
      footballApiService: footballApiService,
      ref: ref);
});

class FootballTableTeamController with ViewControllerMixin, IFootballTeamDetailKey implements ReadOperations {
  final FootballApiService footballApiService;
  final Ref ref;
  final tabControllerScreenStream = StreamController<int>.broadcast();
  late FootballTeamDetail footballTeamDetail;
  int tabOptionIndex = 0;

  FootballTableTeamController({
    required this.footballApiService,
    required this.ref,
  });

  Future<void> loadNewTeam() async {
    initViewFields(footballTeamDetail.tableTeam.teamName, nameKey());
    initViewFields(footballTeamDetail.tableTeam.toStringForDetail(), leagueRanking());
    initViewFields(footballTeamDetail.averageBirthYearToString(), averageBirthYear());
    initViewFields(footballTeamDetail.bestScorerToString(), bestPlayer());
  }

  Future<List<FootballMatchApiModel>> getMatchList() async {
    if(tabOptionIndex == 1) {
      return await Future.delayed(
          Duration.zero, () => _getMatches(footballTeamDetail.nextMatches));
    }
    return await Future.delayed(
        Duration.zero, () => _getMatches(footballTeamDetail.pastMatches));
  }

  List<FootballMatchApiModel> _getMatches(List<FootballMatchApiModel> matches) {
    if(matches.isNotEmpty) {
      return matches;
    }
    else {
      return _returnListWithNoMatches();
    }
  }

  List<FootballMatchApiModel> _returnListWithNoMatches() {
    List<FootballMatchApiModel> matchList = [];
    matchList.add(FootballMatchApiModel.noMatch());
    return matchList;
  }

  Future<MutualMatches> returnMutualMatches() async {
    return await Future.delayed(
        Duration.zero, () => MutualMatches(mutualMatches: footballTeamDetail.mutualMatches, aggregateScore: footballTeamDetail.aggregateScore, aggregateMatches: footballTeamDetail.aggregateMatches));
  }

  Future<void> initNewTeam() async {
    await Future.delayed(
        Duration.zero, () => loadNewTeam());
  }

  Future<FootballTeamDetail> loadFootballDetail(int footballTeamId) async {
    footballTeamDetail = await _loadDetail(footballTeamId);
    return footballTeamDetail;
  }

  Future<FootballTeamDetail> _loadDetail(int footballTeamId) async {
    return await footballApiService.getFootballTeamDetail(footballTeamId);
  }

  Stream<int> tabControllerScreen() {
    return tabControllerScreenStream.stream;
  }

  void changeDetailTab(int option) {
    tabOptionIndex = option;
    tabControllerScreenStream.add(option);
  }

  @override
  String averageBirthYear() {
    return "table_team_birth_year";
  }

  @override
  String bestPlayer() {
    return "table_team_best_player";
  }

  @override
  String leagueRanking() {
    return "table_team_league_ranking";
  }

  @override
  String nameKey() {
    return "table_team_name";
  }

  @override
  Future<List<TableTeamApiModel>> getModels() async {
    return await footballApiService.getFootballTable();
  }
}
