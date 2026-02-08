import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/common/widgets/notifier/listview/i_listview_state.dart';
import 'package:trus_app/models/api/football/football_match_api_model.dart';
import 'package:trus_app/models/api/interfaces/model_to_string.dart';

import '../../../common/widgets/notifier/loader/loading_state.dart';

class FootballMatchDetailState implements IListviewState {
  final LoadingState loading;
  final String nameAndResult;
  final String dateAndLeague;
  final String stadium;
  final String referee;
  final String refereeComment;
  final String homeBestPlayer;
  final String homeGoalScorers;
  final String homeYellowCards;
  final String homeRedCards;
  final String homeOwnGoals;
  final String awayBestPlayer;
  final String awayGoalScorers;
  final String awayYellowCards;
  final String awayRedCards;
  final String awayOwnGoals;
  final AsyncValue<List<FootballMatchApiModel>> mutualMatches;
  final String? aggregateScore;
  final String? aggregateMatches;


  const FootballMatchDetailState({
    required this.loading,
    required this.nameAndResult,
    required this.dateAndLeague,
    required this.stadium,
    required this.referee,
    required this.refereeComment,
    required this.homeBestPlayer,
    required this.homeGoalScorers,
    required this.homeYellowCards,
    required this.homeRedCards,
    required this.homeOwnGoals,
    required this.awayBestPlayer,
    required this.awayGoalScorers,
    required this.awayYellowCards,
    required this.awayRedCards,
    required this.awayOwnGoals,
    required this.mutualMatches,
    this.aggregateMatches,
    this.aggregateScore,
  });

  FootballMatchDetailState copyWith({
    LoadingState? loading,
    String? nameAndResult,
    String? dateAndLeague,
    String? stadium,
    String? referee,
    String? refereeComment,
    String? homeBestPlayer,
    String? homeGoalScorers,
    String? homeYellowCards,
    String? homeRedCards,
    String? homeOwnGoals,
    String? awayBestPlayer,
    String? awayGoalScorers,
    String? awayYellowCards,
    String? awayRedCards,
    String? awayOwnGoals,
    AsyncValue<List<FootballMatchApiModel>>? mutualMatches,
    String? aggregateScore,
    String? aggregateMatches,
  }) {
    return FootballMatchDetailState(
      loading: loading ?? this.loading,
      nameAndResult: nameAndResult ?? this.nameAndResult,
      dateAndLeague: dateAndLeague ?? this.dateAndLeague,
      stadium: stadium ?? this.stadium,
      referee: referee ?? this.referee,
      refereeComment: refereeComment ?? this.refereeComment,
      homeBestPlayer: homeBestPlayer ?? this.homeBestPlayer,
      homeGoalScorers: homeGoalScorers ?? this.homeGoalScorers,
      homeYellowCards: homeYellowCards ?? this.homeYellowCards,
      homeRedCards: homeRedCards ?? this.homeRedCards,
      homeOwnGoals: homeOwnGoals ?? this.homeOwnGoals,
      awayBestPlayer: awayBestPlayer ?? this.awayBestPlayer,
      awayGoalScorers: awayGoalScorers ?? this.awayGoalScorers,
      awayYellowCards: awayYellowCards ?? this.awayYellowCards,
      awayRedCards: awayRedCards ?? this.awayRedCards,
      awayOwnGoals: awayOwnGoals ?? this.awayOwnGoals,
      mutualMatches: mutualMatches ?? this.mutualMatches,
      aggregateScore: aggregateScore ?? this.aggregateScore,
      aggregateMatches: aggregateMatches ?? this.aggregateMatches,
    );
  }

  FootballMatchDetailState.init({
    this.loading = const LoadingState(),
    this.nameAndResult = "",
    this.dateAndLeague = "",
    this.stadium = "",
    this.referee = "",
    this.refereeComment = "",
    this.homeBestPlayer = "",
    this.homeGoalScorers = "",
    this.homeYellowCards = "",
    this.homeRedCards = "",
    this.homeOwnGoals = "",
    this.awayBestPlayer = "",
    this.awayGoalScorers = "",
    this.awayYellowCards = "",
    this.awayRedCards = "",
    this.awayOwnGoals = "",
    this.mutualMatches = const AsyncValue.data([]),
    this.aggregateScore,
    this.aggregateMatches,
    });

  @override
  AsyncValue<List<ModelToString>> getListViewItems() {
    return mutualMatches;
  }
}
