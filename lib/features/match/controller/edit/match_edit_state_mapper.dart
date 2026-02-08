// lib/features/match/controller/match_edit_state_mapper.dart
import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/features/match/state/footbal_match_detail_state.dart';
import 'package:trus_app/features/match/state/match_edit_state.dart';
import 'package:trus_app/models/api/football/detail/football_match_detail.dart';
import 'package:trus_app/models/api/football/football_match_api_model.dart';
import 'package:trus_app/models/api/match/match_setup.dart';
import 'package:trus_app/models/api/player/player_api_model.dart';

class MatchEditStateMapper {
  const MatchEditStateMapper();

  List<PlayerApiModel> playersByIds(List<PlayerApiModel> players, List<int> ids) {
    final out = <PlayerApiModel>[];
    for (final id in ids) {
      final p = players.firstWhereOrNull((e) => e.id == id);
      if (p != null) out.add(p);
    }
    return out;
  }

  MatchEditState applySetup(MatchEditState s, MatchSetup setup) {
    return s.copyWith(
      name: setup.match?.name ?? "",
      date: setup.match?.date ?? DateTime.now(),
      home: setup.match?.home ?? false,
      seasons: AsyncValue.data(setup.seasonList),
      selectedSeason: setup.primarySeason,
      allPlayers: setup.playerList,
      selectedPlayers: playersByIds(
        setup.playerList,
        setup.match?.playerIdList ?? const [],
      ),
      allFans: setup.fanList,
      selectedFans: playersByIds(
        setup.fanList,
        setup.match?.playerIdList ?? const [],
      ),
      footballMatch: setup.match?.footballMatch,
      model: setup.match,
    );
  }

  MatchEditState applyStateByFootballMatch(
      MatchEditState s, {
        required FootballMatchApiModel footballMatch,
        required int userTeamId,
        required MatchSetup setup,
      }) {
    return s.copyWith(
      name: footballMatch.getOpponentName(userTeamId),
      date: footballMatch.date,
      home: footballMatch.isHomeMatch(userTeamId),
      seasons: AsyncValue.data(setup.seasonList),
      selectedSeason: setup.primarySeason,
      allPlayers: setup.playerList,
      selectedPlayers: const [],
      allFans: setup.fanList,
      selectedFans: const [],
      footballMatch: footballMatch,
      model: null,
    );
  }

  FootballMatchDetailState mapFootballDetail(
      FootballMatchDetail d,
      FootballMatchDetailState prev,
      ) {
    return prev.copyWith(
      loading: prev.loading.idle(),
      nameAndResult: d.footballMatch.toStringWithTeamsAndResult(),
      dateAndLeague: d.footballMatch.returnRoundLeagueDate(),
      stadium: d.footballMatch.stadiumToSimpleString(),
      referee: d.footballMatch.refereeToSimpleString(),
      refereeComment: d.footballMatch.refereeCommentToString(),
      homeBestPlayer:
      d.footballMatch.returnSecondDetailsOfMatch(true, StringReturnDetail.bestPlayer),
      homeGoalScorers:
      d.footballMatch.returnSecondDetailsOfMatch(true, StringReturnDetail.goalScorer),
      homeYellowCards:
      d.footballMatch.returnSecondDetailsOfMatch(true, StringReturnDetail.yellowCard),
      homeRedCards:
      d.footballMatch.returnSecondDetailsOfMatch(true, StringReturnDetail.redCard),
      homeOwnGoals:
      d.footballMatch.returnSecondDetailsOfMatch(true, StringReturnDetail.ownGoal),
      awayBestPlayer:
      d.footballMatch.returnSecondDetailsOfMatch(false, StringReturnDetail.bestPlayer),
      awayGoalScorers:
      d.footballMatch.returnSecondDetailsOfMatch(false, StringReturnDetail.goalScorer),
      awayYellowCards:
      d.footballMatch.returnSecondDetailsOfMatch(false, StringReturnDetail.yellowCard),
      awayRedCards:
      d.footballMatch.returnSecondDetailsOfMatch(false, StringReturnDetail.redCard),
      awayOwnGoals:
      d.footballMatch.returnSecondDetailsOfMatch(false, StringReturnDetail.ownGoal),
      aggregateMatches: d.aggregateMatches,
      aggregateScore: d.aggregateScore,
      mutualMatches: AsyncValue.data(d.mutualMatches),
    );
  }
}
