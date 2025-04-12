import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/features/football/widget/i_football_match_detail_hash_key.dart';
import 'package:trus_app/features/general/read_operations.dart';

import '../../../models/api/football/football_match_api_model.dart';
import '../../mixin/view_controller_mixin.dart';
import '../repository/football_api_service.dart';

final footballMatchControllerProvider = Provider((ref) {
  final footballApiService = ref.watch(footballApiServiceProvider);
  return FootballMatchController(ref: ref, footballApiService: footballApiService);
});

class FootballMatchController with ViewControllerMixin, IFootballMatchDetailHashKey implements ReadOperations {
  final FootballApiService footballApiService;
  final Ref ref;
  final snackBarController = StreamController<String>.broadcast();
  late FootballMatchApiModel footballMatch;
  FootballMatchController({
    required this.footballApiService,
    required this.ref,
  });

  void loadMatchDetail() {
    initViewFields(footballMatch.toStringWithTeamsAndResult(), matchName());
    initViewFields(footballMatch.returnRoundLeagueDate(), dateAndLeague());
    initViewFields(footballMatch.stadiumToSimpleString(), stadium());
    initViewFields(footballMatch.refereeToSimpleString(), referee());
    initViewFields(footballMatch.refereeCommentToString(), refereeComment());
    initViewFields(footballMatch.returnSecondDetailsOfMatch(true, StringReturnDetail.bestPlayer), bestPlayer(true));
    initViewFields(footballMatch.returnSecondDetailsOfMatch(true, StringReturnDetail.goalScorer), goalScorers(true));
    initViewFields(footballMatch.returnSecondDetailsOfMatch(true, StringReturnDetail.yellowCard), yellowCardPlayers(true));
    initViewFields(footballMatch.returnSecondDetailsOfMatch(true, StringReturnDetail.redCard), redCardPlayers(true));
    initViewFields(footballMatch.returnSecondDetailsOfMatch(true, StringReturnDetail.ownGoal), ownGoalPlayers(true));
    initViewFields(footballMatch.returnSecondDetailsOfMatch(false, StringReturnDetail.bestPlayer), bestPlayer(false));
    initViewFields(footballMatch.returnSecondDetailsOfMatch(false, StringReturnDetail.goalScorer), goalScorers(false));
    initViewFields(footballMatch.returnSecondDetailsOfMatch(false, StringReturnDetail.yellowCard), yellowCardPlayers(false));
    initViewFields(footballMatch.returnSecondDetailsOfMatch(false, StringReturnDetail.redCard), redCardPlayers(false));
    initViewFields(footballMatch.returnSecondDetailsOfMatch(false, StringReturnDetail.ownGoal), ownGoalPlayers(false));
  }

  Future<void> setFootballMatch(FootballMatchApiModel footballMatch) async {
    this.footballMatch = footballMatch;
    Future.delayed(
        Duration.zero,
            () => loadMatchDetail());
  }

  Stream<String> snackBar() {
    return snackBarController.stream;
  }

  @override
  Future<List<FootballMatchApiModel>> getModels() async {
    return await footballApiService.getTeamFixtures();
  }

  @override
  String bestPlayer(bool homeTeam) {
    if(homeTeam) {
      return "match_home_best_player";
    }
    return "match_away_best_player";
  }

  @override
  String dateAndLeague() {
    return "match_date_and_league";
  }

  @override
  String goalScorers(bool homeTeam) {
    if(homeTeam) {
      return "match_home_goal_scorers";
    }
    return "match_away_goal_scorers";
  }

  @override
  String ownGoalPlayers(bool homeTeam) {
    if(homeTeam) {
      "match_home_own_goal_scorers";
    }
    return "match_away_own_goal_scorers";
  }

  @override
  String redCardPlayers(bool homeTeam) {
    if(homeTeam) {
      return "match_home_red_card_players";
    }
    return "match_away_red_card_players";
  }

  @override
  String referee() {
    return "match_referee";
  }

  @override
  String result() {
    return "match_result";
  }

  @override
  String stadium() {
    return "match_stadium";
  }

  @override
  String yellowCardPlayers(bool homeTeam) {
    if(homeTeam) {
      return "match_home_yellow_card_players";
    }
    return "match_away_yellow_card_players";
  }

  @override
  String refereeComment() {
    return "match_referee_comment";
  }

  @override
  String matchName() {
    return "match_name";
  }
}
