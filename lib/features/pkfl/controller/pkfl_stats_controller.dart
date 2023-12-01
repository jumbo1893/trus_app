import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/models/enum/spinner_options.dart';
import '../../../models/api/pkfl/pkfl_all_individual_stats.dart';
import '../../../models/api/pkfl/pkfl_card_comment.dart';
import '../../../models/helper/pkfl_all_individual_stats_with_spinner.dart';
import '../repository/pkfl_api_service.dart';
import '../repository/pkfl_repository.dart';

final pkflStatsControllerProvider = Provider((ref) {
  final pkflRepository = ref.watch(pkflRepositoryProvider);
  final pkflApiService = ref.watch(pkflApiServiceProvider);
  return PkflStatsController(
      pkflRepository: pkflRepository, ref: ref, pkflApiService: pkflApiService);
});

class PkflStatsController {
  final PkflRepository pkflRepository;
  final PkflApiService pkflApiService;
  final ProviderRef ref;
  List<PkflAllIndividualStats> matchListCurrentSeason = [];
  List<PkflAllIndividualStats> matchListAllSeasons = [];
  final pickedOptionController = StreamController<SpinnerOption>.broadcast();
  final matchListController =
      StreamController<PkflAllIndividualStatsWithSpinner>.broadcast();

  bool currentSeason = true;
  SpinnerOption? spinnerOption;
  bool desc = true;
  String? filterText;

  PkflStatsController({
    required this.pkflRepository,
    required this.pkflApiService,
    required this.ref,
  });

  Stream<PkflAllIndividualStatsWithSpinner> pkflPlayerStats() {
    return matchListController.stream;
  }

  Future<void> setListToStream() async {
    if (currentSeason) {
      if (matchListCurrentSeason.isEmpty) {
        await getModels();
      }
      matchListController.add(_sortPkflStatsPlayers(
          matchListCurrentSeason, desc, noNullSpinnerOption(), filterText));
    } else {
      if (matchListAllSeasons.isEmpty) {
        await getModels();
      }
      matchListController.add(_sortPkflStatsPlayers(
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

  Stream<PkflAllIndividualStatsWithSpinner> playerStatsList() {
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

  PkflAllIndividualStatsWithSpinner setPkflAllIndividualStatsWithSpinner(
      List<PkflAllIndividualStats> players) {
    return PkflAllIndividualStatsWithSpinner(
        pkflAllIndividualStats: players, option: noNullSpinnerOption());
  }

  PkflAllIndividualStatsWithSpinner _sortPkflStatsPlayers(
      List<PkflAllIndividualStats> playerStatsList,
      bool desc,
      SpinnerOption option,
      String? filterText) {
    List<PkflAllIndividualStats> players = [];
    if (filterText != null && filterText.isNotEmpty) {
      for (PkflAllIndividualStats playerStats in playerStatsList) {
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
          return setPkflAllIndividualStatsWithSpinner(players);
        } else {
          players.sort((a, b) => a
              .getBestPlayerMatchesRatio()
              .compareTo(b.getBestPlayerMatchesRatio()));
        }
        return setPkflAllIndividualStatsWithSpinner(players);
      case SpinnerOption.goals:
        if (desc) {
          players.sort((b, a) => a.goals.compareTo(b.goals));
          return setPkflAllIndividualStatsWithSpinner(players);
        } else {
          players.sort((a, b) => a.goals.compareTo(b.goals));
        }
        return setPkflAllIndividualStatsWithSpinner(players);
      case SpinnerOption.bestPlayers:
        if (desc) {
          players.sort((b, a) => a.bestPlayer.compareTo(b.bestPlayer));
          return setPkflAllIndividualStatsWithSpinner(players);
        } else {
          players.sort((a, b) => a.bestPlayer.compareTo(b.bestPlayer));
        }
        return setPkflAllIndividualStatsWithSpinner(players);
      case SpinnerOption.yellowCards:
        if (desc) {
          players.sort((b, a) => a.yellowCards.compareTo(b.yellowCards));
          return setPkflAllIndividualStatsWithSpinner(players);
        } else {
          players.sort((a, b) => a.yellowCards.compareTo(b.yellowCards));
        }
        return setPkflAllIndividualStatsWithSpinner(players);
      case SpinnerOption.redCards:
        if (desc) {
          players.sort((b, a) => a.redCards.compareTo(b.redCards));
          return setPkflAllIndividualStatsWithSpinner(players);
        } else {
          players.sort((a, b) => a.redCards.compareTo(b.redCards));
        }
        return setPkflAllIndividualStatsWithSpinner(players);
      case SpinnerOption.ownGoals:
        if (desc) {
          players.sort((b, a) => a.ownGoals.compareTo(b.ownGoals));
          return setPkflAllIndividualStatsWithSpinner(players);
        } else {
          players.sort((a, b) => a.ownGoals.compareTo(b.ownGoals));
        }
        return setPkflAllIndividualStatsWithSpinner(players);
      case SpinnerOption.matches:
        if (desc) {
          players.sort((b, a) => a.matches.compareTo(b.matches));
          return setPkflAllIndividualStatsWithSpinner(players);
        } else {
          players.sort((a, b) => a.matches.compareTo(b.matches));
        }
        return setPkflAllIndividualStatsWithSpinner(players);
      case SpinnerOption.goalkeepingMinutes:
        if (desc) {
          players.sort(
              (b, a) => a.goalkeepingMinutes.compareTo(b.goalkeepingMinutes));
          return setPkflAllIndividualStatsWithSpinner(players);
        } else {
          players.sort(
              (a, b) => a.goalkeepingMinutes.compareTo(b.goalkeepingMinutes));
        }
        return setPkflAllIndividualStatsWithSpinner(players);
      case SpinnerOption.goalRatio:
        if (desc) {
          players.sort((b, a) =>
              a.getGoalMatchesRatio().compareTo(b.getGoalMatchesRatio()));
          return setPkflAllIndividualStatsWithSpinner(players);
        } else {
          players.sort((a, b) =>
              a.getGoalMatchesRatio().compareTo(b.getGoalMatchesRatio()));
        }
        return setPkflAllIndividualStatsWithSpinner(players);
      case SpinnerOption.receivedGoalsRatio:
        if (desc) {
          players.sort((b, a) => a
              .getReceivedGoalsGoalkeepingMinutesRatio()
              .compareTo(b.getReceivedGoalsGoalkeepingMinutesRatio()));
          return setPkflAllIndividualStatsWithSpinner(players);
        } else {
          players.sort((a, b) => a
              .getReceivedGoalsGoalkeepingMinutesRatio()
              .compareTo(b.getReceivedGoalsGoalkeepingMinutesRatio()));
        }
        return setPkflAllIndividualStatsWithSpinner(players);
      case SpinnerOption.yellowCardRatio:
        if (desc) {
          players.sort((b, a) => a
              .getYellowCardMatchesRatio()
              .compareTo(b.getYellowCardMatchesRatio()));
          return setPkflAllIndividualStatsWithSpinner(players);
        } else {
          players.sort((a, b) => a
              .getYellowCardMatchesRatio()
              .compareTo(b.getYellowCardMatchesRatio()));
        }
        return setPkflAllIndividualStatsWithSpinner(players);
      case SpinnerOption.hattrick:
        if (desc) {
          players.sort((b, a) => a.hattrick.compareTo(b.hattrick));
          return setPkflAllIndividualStatsWithSpinner(players);
        } else {
          players.sort((a, b) => a.hattrick.compareTo(b.hattrick));
        }
        return setPkflAllIndividualStatsWithSpinner(players);
      case SpinnerOption.cleanSheet:
        if (desc) {
          players.sort((b, a) => a.cleanSheet.compareTo(b.cleanSheet));
          return setPkflAllIndividualStatsWithSpinner(players);
        } else {
          players.sort((a, b) => a.cleanSheet.compareTo(b.cleanSheet));
        }
        return setPkflAllIndividualStatsWithSpinner(players);
      case SpinnerOption.yellowCardDetail:
        return filterPlayerWithComments(players, true);
      case SpinnerOption.redCardDetail:
        return filterPlayerWithComments(players, false);
      case SpinnerOption.receivedGoals:
        if (desc) {
          players.sort((b, a) => a.receivedGoals.compareTo(b.receivedGoals));
          return setPkflAllIndividualStatsWithSpinner(players);
        } else {
          players.sort((a, b) => a.receivedGoals.compareTo(b.receivedGoals));
        }
        return setPkflAllIndividualStatsWithSpinner(players);
      case SpinnerOption.matchPoints:
        if (desc) {
          players.sort((b, a) => a
              .getMatchPointsMatchesRatio()
              .compareTo(b.getMatchPointsMatchesRatio()));
          return setPkflAllIndividualStatsWithSpinner(players);
        } else {
          players.sort((a, b) => a
              .getMatchPointsMatchesRatio()
              .compareTo(b.getMatchPointsMatchesRatio()));
        }
        return setPkflAllIndividualStatsWithSpinner(players);
    }
  }

  PkflAllIndividualStatsWithSpinner filterPlayerWithComments(
      List<PkflAllIndividualStats> allPlayers, bool yellow) {
    List<PkflAllIndividualStats> players = [];
    for (PkflAllIndividualStats playerStats in allPlayers) {
      if (yellow) {
        if (playerStats.yellowCardComments.isNotEmpty) {
          for (PkflCardComment comment in playerStats.yellowCardComments) {
            List<PkflCardComment> comments = [];
            comments.add(comment);
            PkflAllIndividualStats pkflAllIndividualStats =
                PkflAllIndividualStats(
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
            players.add(pkflAllIndividualStats);
          }
        }
      } else {
        if (playerStats.redCardComments.isNotEmpty) {
          for (PkflCardComment comment in playerStats.redCardComments) {
            List<PkflCardComment> comments = [];
            comments.add(comment);
            PkflAllIndividualStats pkflAllIndividualStats =
                PkflAllIndividualStats(
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
            players.add(pkflAllIndividualStats);
          }
        }
      }
    }
    return setPkflAllIndividualStatsWithSpinner(players);
  }

  Future<PkflAllIndividualStatsWithSpinner> getModels() async {
    if (currentSeason) {
      if (matchListCurrentSeason.isEmpty) {
        matchListCurrentSeason =
            await pkflApiService.getPkflAllIndividualStats(currentSeason);
      }
      return _sortPkflStatsPlayers(
          matchListCurrentSeason, desc, noNullSpinnerOption(), filterText);
    } else {
      if (matchListAllSeasons.isEmpty) {
        matchListAllSeasons =
            await pkflApiService.getPkflAllIndividualStats(currentSeason);
      }
      return _sortPkflStatsPlayers(
          matchListAllSeasons, desc, noNullSpinnerOption(), filterText);
    }
  }
}
