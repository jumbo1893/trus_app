import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/features/football/controller/current_season_notifier.dart';
import 'package:trus_app/features/football/repository/football_api_service.dart';
import 'package:trus_app/features/football/state/football_stats_state.dart';
import 'package:trus_app/models/api/interfaces/dropdown_item.dart';
import 'package:trus_app/models/api/season_api_model.dart';
import 'package:trus_app/models/enum/spinner_options.dart';

import '../../../common/widgets/notifier/dropdown/dropdown_state.dart';
import '../../../common/widgets/notifier/dropdown/i_dropdown_notifier.dart';
import '../../../config.dart';
import '../../../models/api/football/stats/card_comment.dart';
import '../../../models/api/football/stats/football_all_individual_stats_api_model.dart';
import '../../../models/api/interfaces/model_to_string.dart';
final footballStatsNotifierProvider =
StateNotifierProvider<FootballStatsNotifier, FootballStatsState>((ref) {
  return FootballStatsNotifier(
    ref: ref,
    footballApiService: ref.read(footballApiServiceProvider),
  );
});

class FootballStatsNotifier extends StateNotifier<FootballStatsState> implements IDropdownNotifier {
  final Ref ref;
  final FootballApiService footballApiService;

  FootballStatsNotifier({
    required this.ref,
    required this.footballApiService,
  }) : super(FootballStatsState.initial()) {
    ref.listen<DropdownState>(currentSeasonNotifierProvider, (_, next) {
      SeasonApiModel? season = next.selected as SeasonApiModel?;
      if (season != null) {
        _loadStats(season.id! != allSeasonId);
      }
    }, fireImmediately: true);
  }

  Future<void> _loadStats(bool currentSeason) async {
    state = state.copyWith(
      dropdownTexts: const AsyncValue.loading(),
      stats: const AsyncValue.loading(),
    );
    final response = await footballApiService.getPlayerStats(currentSeason);
    final SpinnerOption selected =
        (state.selectedText as SpinnerOption?) ?? SpinnerOption.values.first;

    state = state.copyWith(
      dropdownTexts: const AsyncValue.data(SpinnerOption.values),
      selectedText: selected,
      stats: AsyncValue.data(
        _getStatsBySelectedText(response, selected),
      ),
      allStats: response
    );
  }

  List<ModelToString> _getStatsBySelectedText(List<FootballAllIndividualStatsApiModel> stats, SpinnerOption spinnerOption) {
    List<ModelToString> titleAndString = [];
    List<FootballAllIndividualStatsApiModel> newStats = [];
    newStats.addAll(_sortFootballStatsPlayers(stats, spinnerOption));
    for(FootballAllIndividualStatsApiModel stat in newStats) {
      titleAndString.add(stat.getModelToStringBySpinnerOption(spinnerOption));
    }
    return titleAndString;
  }

  List<FootballAllIndividualStatsApiModel> _sortFootballStatsPlayers(
      List<FootballAllIndividualStatsApiModel> players,
      SpinnerOption option) {
    switch (option) {
      case SpinnerOption.bestPlayerRatio:
        players.sort((b, a) => a
            .getBestPlayerMatchesRatio()
            .compareTo(b.getBestPlayerMatchesRatio()));
        break;
      case SpinnerOption.goals:
          players.sort((b, a) => a.goals.compareTo(b.goals));
          break;
      case SpinnerOption.bestPlayers:
          players.sort((b, a) => a.bestPlayer.compareTo(b.bestPlayer));
          break;
      case SpinnerOption.yellowCards:
          players.sort((b, a) => a.yellowCards.compareTo(b.yellowCards));
          break;
      case SpinnerOption.redCards:
          players.sort((b, a) => a.redCards.compareTo(b.redCards));
          break;
      case SpinnerOption.ownGoals:
          players.sort((b, a) => a.ownGoals.compareTo(b.ownGoals));
          break;
      case SpinnerOption.matches:
          players.sort((b, a) => a.matches.compareTo(b.matches));
          break;
      case SpinnerOption.goalkeepingMinutes:
          players.sort(
                  (b, a) => a.goalkeepingMinutes.compareTo(b.goalkeepingMinutes));
          break;
      case SpinnerOption.goalRatio:
          players.sort((b, a) =>
              a.getGoalMatchesRatio().compareTo(b.getGoalMatchesRatio()));
          break;
      case SpinnerOption.receivedGoalsRatio:
          players.sort((b, a) => a
              .getReceivedGoalsGoalkeepingMinutesRatio()
              .compareTo(b.getReceivedGoalsGoalkeepingMinutesRatio()));
          break;
      case SpinnerOption.yellowCardRatio:
          players.sort((b, a) => a
              .getYellowCardMatchesRatio()
              .compareTo(b.getYellowCardMatchesRatio()));
          break;
      case SpinnerOption.hattrick:
          players.sort((b, a) => a.hattrick.compareTo(b.hattrick));
          break;
      case SpinnerOption.cleanSheet:
          players.sort((b, a) => a.cleanSheet.compareTo(b.cleanSheet));
          break;
      case SpinnerOption.yellowCardDetail:
        return filterPlayerWithComments(players, true);
      case SpinnerOption.redCardDetail:
        return filterPlayerWithComments(players, false);
      case SpinnerOption.receivedGoals:
          players.sort((b, a) => a.receivedGoals.compareTo(b.receivedGoals));
          break;
      case SpinnerOption.matchPoints:
          players.sort((b, a) => a
              .getMatchPointsMatchesRatio()
              .compareTo(b.getMatchPointsMatchesRatio()));
    }
    return players;
  }

  List<FootballAllIndividualStatsApiModel> filterPlayerWithComments(
      List<FootballAllIndividualStatsApiModel> allPlayers, bool yellow) {
    List<FootballAllIndividualStatsApiModel> players = [];
    for (FootballAllIndividualStatsApiModel playerStats in allPlayers) {
      if (yellow) {
        if (playerStats.yellowCardComments.isNotEmpty) {
          for (CardComment comment in playerStats.yellowCardComments) {
            List<CardComment> comments = [];
            comments.add(comment);
            FootballAllIndividualStatsApiModel footballAllIndividualStats =
            FootballAllIndividualStatsApiModel(
                matches: 0,
                player: playerStats.player,
                goals: 0,
                receivedGoals: 0,
                ownGoals: 0,
                goalkeepingMinutes: 0,
                yellowCards: 0,
                redCards: 0,
                bestPlayer: 0,
                hattrick: 0,
                cleanSheet: 0,
                yellowCardComments: comments,
                redCardComments: [],
                matchPoints: 0);
            players.add(footballAllIndividualStats);
          }
        }
      } else {
        if (playerStats.redCardComments.isNotEmpty) {
          for (CardComment comment in playerStats.redCardComments) {
            List<CardComment> comments = [];
            comments.add(comment);
            FootballAllIndividualStatsApiModel footballAllIndividualStats =
            FootballAllIndividualStatsApiModel(
                matches: 0,
                player: playerStats.player,
                goals: 0,
                receivedGoals: 0,
                ownGoals: 0,
                goalkeepingMinutes: 0,
                yellowCards: 0,
                redCards: 0,
                bestPlayer: 0,
                hattrick: 0,
                cleanSheet: 0,
                yellowCardComments: [],
                redCardComments: comments,
                matchPoints: 0);
            players.add(footballAllIndividualStats);
          }
        }
      }
    }
    return players;
  }

  @override
  selectDropdown(DropdownItem item) {
    state = state.copyWith(
      selectedText: item,
      stats: AsyncValue.data(_getStatsBySelectedText(state.allStats, item as SpinnerOption)),
    );
  }
}
