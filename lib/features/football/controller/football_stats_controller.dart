import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/models/api/football/stats/football_all_individual_stats_api_model.dart';
import 'package:trus_app/models/enum/spinner_options.dart';

import '../../../models/api/football/stats/card_comment.dart';
import '../../../models/helper/pkfl_all_individual_stats_with_spinner.dart';
import '../repository/football_api_service.dart';

final footballStatsControllerProvider = Provider((ref) {
  final footballApiService = ref.watch(footballApiServiceProvider);
  return FootballStatsController(
      ref: ref, footballApiService: footballApiService);
});

class FootballStatsController {
  final FootballApiService footballApiService;
  final Ref ref;
  List<FootballAllIndividualStatsApiModel> matchListCurrentSeason = [];
  List<FootballAllIndividualStatsApiModel> matchListAllSeasons = [];
  final pickedOptionController = StreamController<SpinnerOption>.broadcast();
  final matchListController =
      StreamController<FootballAllIndividualStatsWithSpinner>.broadcast();

  bool currentSeason = true;
  SpinnerOption? spinnerOption;
  bool desc = true;
  String? filterText;

  FootballStatsController({
    required this.footballApiService,
    required this.ref,
  });

  Stream<FootballAllIndividualStatsWithSpinner> footballPlayerStats() {
    return matchListController.stream;
  }

  Future<void> setListToStream() async {
    if (currentSeason) {
      if (matchListCurrentSeason.isEmpty) {
        await getModels();
      }
      matchListController.add(_sortFootballStatsPlayers(
          matchListCurrentSeason, desc, noNullSpinnerOption(), filterText));
    } else {
      if (matchListAllSeasons.isEmpty) {
        await getModels();
      }
      matchListController.add(_sortFootballStatsPlayers(
          matchListAllSeasons, desc, noNullSpinnerOption(), filterText));
    }
  }

  SpinnerOption noNullSpinnerOption() {
    spinnerOption ??= SpinnerOption.values[0];
    return spinnerOption!;
  }

  Future<void> setPickedOption(SpinnerOption option) async {
    spinnerOption = option;
    pickedOptionController.add(option);
    await setListToStream();
  }

  void setCurrentOption() {
    spinnerOption ??= SpinnerOption.values[0];
    setPickedOption(spinnerOption!);
  }

  Stream<SpinnerOption> pickedOption() {
    return pickedOptionController.stream;
  }

  Stream<FootballAllIndividualStatsWithSpinner> playerStatsList() {
    return matchListController.stream;
  }

  Future<void> onRevertTap() async {
    desc = !desc;
    await setListToStream();
  }

  Future<void> setSeason(bool currentSeason) async {
    this.currentSeason = currentSeason;
    await setListToStream();
  }

  Future<void> setFilteredText(String? filter) async {
    filterText = filter;
    await setListToStream();
  }

  FootballAllIndividualStatsWithSpinner setFootballAllIndividualStatsWithSpinner(
      List<FootballAllIndividualStatsApiModel> players) {
    return FootballAllIndividualStatsWithSpinner(
        footballAllIndividualStats: players, option: noNullSpinnerOption());
  }

  FootballAllIndividualStatsWithSpinner _sortFootballStatsPlayers(
      List<FootballAllIndividualStatsApiModel> playerStatsList,
      bool desc,
      SpinnerOption option,
      String? filterText) {
    List<FootballAllIndividualStatsApiModel> players = [];
    if (filterText != null && filterText.isNotEmpty) {
      for (FootballAllIndividualStatsApiModel playerStats in playerStatsList) {
        if (playerStats.player.name.contains(filterText.trim())) {
          players.add(playerStats);
        }
      }
    } else {
      players.addAll(playerStatsList);
    }
    switch (option) {
      case SpinnerOption.bestPlayerRatio:
        if (desc) {
          players.sort((b, a) => a
              .getBestPlayerMatchesRatio()
              .compareTo(b.getBestPlayerMatchesRatio()));
          return setFootballAllIndividualStatsWithSpinner(players);
        } else {
          players.sort((a, b) => a
              .getBestPlayerMatchesRatio()
              .compareTo(b.getBestPlayerMatchesRatio()));
        }
        return setFootballAllIndividualStatsWithSpinner(players);
      case SpinnerOption.goals:
        if (desc) {
          players.sort((b, a) => a.goals.compareTo(b.goals));
          return setFootballAllIndividualStatsWithSpinner(players);
        } else {
          players.sort((a, b) => a.goals.compareTo(b.goals));
        }
        return setFootballAllIndividualStatsWithSpinner(players);
      case SpinnerOption.bestPlayers:
        if (desc) {
          players.sort((b, a) => a.bestPlayer.compareTo(b.bestPlayer));
          return setFootballAllIndividualStatsWithSpinner(players);
        } else {
          players.sort((a, b) => a.bestPlayer.compareTo(b.bestPlayer));
        }
        return setFootballAllIndividualStatsWithSpinner(players);
      case SpinnerOption.yellowCards:
        if (desc) {
          players.sort((b, a) => a.yellowCards.compareTo(b.yellowCards));
          return setFootballAllIndividualStatsWithSpinner(players);
        } else {
          players.sort((a, b) => a.yellowCards.compareTo(b.yellowCards));
        }
        return setFootballAllIndividualStatsWithSpinner(players);
      case SpinnerOption.redCards:
        if (desc) {
          players.sort((b, a) => a.redCards.compareTo(b.redCards));
          return setFootballAllIndividualStatsWithSpinner(players);
        } else {
          players.sort((a, b) => a.redCards.compareTo(b.redCards));
        }
        return setFootballAllIndividualStatsWithSpinner(players);
      case SpinnerOption.ownGoals:
        if (desc) {
          players.sort((b, a) => a.ownGoals.compareTo(b.ownGoals));
          return setFootballAllIndividualStatsWithSpinner(players);
        } else {
          players.sort((a, b) => a.ownGoals.compareTo(b.ownGoals));
        }
        return setFootballAllIndividualStatsWithSpinner(players);
      case SpinnerOption.matches:
        if (desc) {
          players.sort((b, a) => a.matches.compareTo(b.matches));
          return setFootballAllIndividualStatsWithSpinner(players);
        } else {
          players.sort((a, b) => a.matches.compareTo(b.matches));
        }
        return setFootballAllIndividualStatsWithSpinner(players);
      case SpinnerOption.goalkeepingMinutes:
        if (desc) {
          players.sort(
              (b, a) => a.goalkeepingMinutes.compareTo(b.goalkeepingMinutes));
          return setFootballAllIndividualStatsWithSpinner(players);
        } else {
          players.sort(
              (a, b) => a.goalkeepingMinutes.compareTo(b.goalkeepingMinutes));
        }
        return setFootballAllIndividualStatsWithSpinner(players);
      case SpinnerOption.goalRatio:
        if (desc) {
          players.sort((b, a) =>
              a.getGoalMatchesRatio().compareTo(b.getGoalMatchesRatio()));
          return setFootballAllIndividualStatsWithSpinner(players);
        } else {
          players.sort((a, b) =>
              a.getGoalMatchesRatio().compareTo(b.getGoalMatchesRatio()));
        }
        return setFootballAllIndividualStatsWithSpinner(players);
      case SpinnerOption.receivedGoalsRatio:
        if (desc) {
          players.sort((b, a) => a
              .getReceivedGoalsGoalkeepingMinutesRatio()
              .compareTo(b.getReceivedGoalsGoalkeepingMinutesRatio()));
          return setFootballAllIndividualStatsWithSpinner(players);
        } else {
          players.sort((a, b) => a
              .getReceivedGoalsGoalkeepingMinutesRatio()
              .compareTo(b.getReceivedGoalsGoalkeepingMinutesRatio()));
        }
        return setFootballAllIndividualStatsWithSpinner(players);
      case SpinnerOption.yellowCardRatio:
        if (desc) {
          players.sort((b, a) => a
              .getYellowCardMatchesRatio()
              .compareTo(b.getYellowCardMatchesRatio()));
          return setFootballAllIndividualStatsWithSpinner(players);
        } else {
          players.sort((a, b) => a
              .getYellowCardMatchesRatio()
              .compareTo(b.getYellowCardMatchesRatio()));
        }
        return setFootballAllIndividualStatsWithSpinner(players);
      case SpinnerOption.hattrick:
        if (desc) {
          players.sort((b, a) => a.hattrick.compareTo(b.hattrick));
          return setFootballAllIndividualStatsWithSpinner(players);
        } else {
          players.sort((a, b) => a.hattrick.compareTo(b.hattrick));
        }
        return setFootballAllIndividualStatsWithSpinner(players);
      case SpinnerOption.cleanSheet:
        if (desc) {
          players.sort((b, a) => a.cleanSheet.compareTo(b.cleanSheet));
          return setFootballAllIndividualStatsWithSpinner(players);
        } else {
          players.sort((a, b) => a.cleanSheet.compareTo(b.cleanSheet));
        }
        return setFootballAllIndividualStatsWithSpinner(players);
      case SpinnerOption.yellowCardDetail:
        return filterPlayerWithComments(players, true);
      case SpinnerOption.redCardDetail:
        return filterPlayerWithComments(players, false);
      case SpinnerOption.receivedGoals:
        if (desc) {
          players.sort((b, a) => a.receivedGoals.compareTo(b.receivedGoals));
          return setFootballAllIndividualStatsWithSpinner(players);
        } else {
          players.sort((a, b) => a.receivedGoals.compareTo(b.receivedGoals));
        }
        return setFootballAllIndividualStatsWithSpinner(players);
      case SpinnerOption.matchPoints:
        if (desc) {
          players.sort((b, a) => a
              .getMatchPointsMatchesRatio()
              .compareTo(b.getMatchPointsMatchesRatio()));
          return setFootballAllIndividualStatsWithSpinner(players);
        } else {
          players.sort((a, b) => a
              .getMatchPointsMatchesRatio()
              .compareTo(b.getMatchPointsMatchesRatio()));
        }
        return setFootballAllIndividualStatsWithSpinner(players);
    }
  }

  FootballAllIndividualStatsWithSpinner filterPlayerWithComments(
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
    return setFootballAllIndividualStatsWithSpinner(players);
  }

  Future<FootballAllIndividualStatsWithSpinner> getModels() async {
    if (currentSeason) {
      if (matchListCurrentSeason.isEmpty) {
        matchListCurrentSeason =
            await footballApiService.getPlayerStats(currentSeason);
      }
      return _sortFootballStatsPlayers(
          matchListCurrentSeason, desc, noNullSpinnerOption(), filterText);
    } else {
      if (matchListAllSeasons.isEmpty) {
        matchListAllSeasons =
            await footballApiService.getPlayerStats(currentSeason);
      }
      return _sortFootballStatsPlayers(
          matchListAllSeasons, desc, noNullSpinnerOption(), filterText);
    }
  }
}
