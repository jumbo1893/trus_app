import 'dart:async';
import 'dart:collection';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/features/pkfl/tasks/retrieve_match_detail_task.dart';
import 'package:trus_app/features/pkfl/tasks/retrieve_matches_task.dart';
import 'package:trus_app/features/pkfl/tasks/retrieve_season_url_task.dart';
import 'package:trus_app/models/enum/spinner_options.dart';
import 'package:trus_app/models/pkfl/pkfl_match.dart';
import 'package:trus_app/models/pkfl/pkfl_player_stats.dart';
import 'package:trus_app/models/pkfl/pkfl_season.dart';
import '../../../models/helper/percentage_loader_model.dart';
import '../../../models/pkfl/pkfl_match_player.dart';
import '../repository/pkfl_repository.dart';

final pkflStatsControllerProvider = Provider((ref) {
  final pkflRepository = ref.watch(pkflRepositoryProvider);
  return PkflStatsController(pkflRepository: pkflRepository, ref: ref);
});

class PkflStatsController {
  final PkflRepository pkflRepository;
  final ProviderRef ref;
  final streamLoaderTextController =
      StreamController<PercentageLoaderModel>.broadcast();
  final streamLoaderController = StreamController<bool>.broadcast();
  final streamPkflStatsPlayer =
      StreamController<List<PkflPlayerStats>>.broadcast();
  final snackBarController = StreamController<String>.broadcast();
  List<PkflMatch> matchListCurrentSeason = [];
  List<PkflMatch> matchListAllSeasons = [];

  PkflStatsController({
    required this.pkflRepository,
    required this.ref,
  });

  Future<String> url() async {
    return pkflRepository.getPkflTeamUrl();
  }

  Stream<String> snackBar() {
    return snackBarController.stream;
  }

  Stream<PercentageLoaderModel> loaderTextData() {
    return streamLoaderTextController.stream;
  }

  Stream<bool> loaderData() {
    return streamLoaderController.stream;
  }

  Stream<List<PkflPlayerStats>> pkflPlayerStats() {
    return streamPkflStatsPlayer.stream;
  }

  void setPkflPlayerStats(bool currentSeason, SpinnerOption option, bool desc,
      String? filterText) async {
    try {
      streamLoaderController.add(true);
      if (currentSeason) {
        if (matchListCurrentSeason.isEmpty) {
          matchListCurrentSeason = await _setPkflMatches(currentSeason);
        }
        streamPkflStatsPlayer.add(_sortPkflStatsPlayers(
            _initPlayerStatsList(matchListCurrentSeason, filterText),
            desc,
            option));
      } else {
        if (matchListAllSeasons.isEmpty) {
          matchListAllSeasons = await _setPkflMatches(currentSeason);
        }
        streamPkflStatsPlayer.add(_sortPkflStatsPlayers(
            _initPlayerStatsList(matchListAllSeasons, filterText),
            desc,
            option));
      }
      streamLoaderController.add(false);
    } catch (e) {
      snackBarController.add(e.toString());
    }
  }

  Future<List<PkflMatch>> _setPkflMatches(bool currentSeason) async {
    List<PkflMatch> matches = [];
    streamLoaderTextController
        .add(PercentageLoaderModel("připojuji se k webu pkfl"));
    String url = await pkflRepository.getPkflTeamUrl();
    streamLoaderTextController.add(PercentageLoaderModel("načítám sezony"));
    RetrieveSeasonUrlTask retrieveSeasonUrlTask =
        RetrieveSeasonUrlTask(url, currentSeason);
    List<PkflSeason> pkflSeasons =
        await retrieveSeasonUrlTask.returnPkflSeasons();
    streamLoaderTextController.add(PercentageLoaderModel("načítám zápasy"));
    for (PkflSeason pkflSeason in pkflSeasons) {
      streamLoaderTextController
          .add(PercentageLoaderModel("načítám sezonu ${pkflSeason.name}"));
      RetrieveMatchesTask retrieveMatchesTask =
          RetrieveMatchesTask(pkflSeason.url);
      matches.addAll(await retrieveMatchesTask.returnPkflMatches());
    }
    int detailNumber = 1;
    for (PkflMatch pkflMatch in matches) {
      PercentageLoaderModel loader = PercentageLoaderModel(
          "načítám detail zápasu:\n ${pkflMatch.toStringWithOpponentAndDate()}");
      loader.calculatePercentageNumber(detailNumber, pkflSeasons.length);
      streamLoaderTextController.add(loader);
      RetrieveMatchDetailTask retrieveMatchDetailTask =
          RetrieveMatchDetailTask(pkflMatch.urlResult);
      pkflMatch.pkflMatchDetail ??=
          (await retrieveMatchDetailTask.returnPkflMatchDetail());
      detailNumber++;
    }
    return matches;
  }

  List<PkflPlayerStats> _initPlayerStatsList(
      List<PkflMatch> matches, String? filterValue) {
    print(filterValue);
    HashMap<PkflMatchPlayer, PkflPlayerStats> pkflPlayerStatsHashMap =
        HashMap();
    for (PkflMatch pkflMatch in matches) {
      for (PkflMatchPlayer pkflMatchPlayer
          in pkflMatch.pkflMatchDetail!.pkflPlayers) {
        if (filterValue == null ||
            pkflMatchPlayer.name
                .toLowerCase()
                .contains(filterValue.toLowerCase())) {
          PkflPlayerStats? hashStatPlayer =
              pkflPlayerStatsHashMap[pkflMatchPlayer];
          if (hashStatPlayer == null) {
            PkflPlayerStats pkflPlayerStats =
                PkflPlayerStats(pkflMatchPlayer.name);
            pkflPlayerStats.enhanceWithPlayerDetail(pkflMatchPlayer, pkflMatch);
            pkflPlayerStatsHashMap.addAll({pkflMatchPlayer: pkflPlayerStats});
          } else {
            hashStatPlayer.enhanceWithPlayerDetail(pkflMatchPlayer, pkflMatch);
          }
        }
      }
    }
    return pkflPlayerStatsHashMap.values.toList();
  }

  List<PkflPlayerStats> _sortPkflStatsPlayers(
      List<PkflPlayerStats> players, bool desc, SpinnerOption option) {
    switch (option) {
      case SpinnerOption.bestPlayerRatio:
        if (desc) {
          players.sort((b, a) => a
              .getBestPlayerMatchesRatio()
              .compareTo(b.getBestPlayerMatchesRatio()));
          return players;
        } else {
          players.sort((a, b) => a
              .getBestPlayerMatchesRatio()
              .compareTo(b.getBestPlayerMatchesRatio()));
        }
        return players;
      case SpinnerOption.goals:
        if (desc) {
          players.sort((b, a) => a.goals.compareTo(b.goals));
          return players;
        } else {
          players.sort((a, b) => a.goals.compareTo(b.goals));
        }
        return players;
      case SpinnerOption.bestPlayers:
        if (desc) {
          players.sort((b, a) => a.bestPlayer.compareTo(b.bestPlayer));
          return players;
        } else {
          players.sort((a, b) => a.bestPlayer.compareTo(b.bestPlayer));
        }
        return players;
      case SpinnerOption.yellowCards:
        if (desc) {
          players.sort((b, a) => a.yellowCards.compareTo(b.yellowCards));
          return players;
        } else {
          players.sort((a, b) => a.yellowCards.compareTo(b.yellowCards));
        }
        return players;
      case SpinnerOption.redCards:
        if (desc) {
          players.sort((b, a) => a.redCards.compareTo(b.redCards));
          return players;
        } else {
          players.sort((a, b) => a.redCards.compareTo(b.redCards));
        }
        return players;
      case SpinnerOption.ownGoals:
        if (desc) {
          players.sort((b, a) => a.ownGoals.compareTo(b.ownGoals));
          return players;
        } else {
          players.sort((a, b) => a.ownGoals.compareTo(b.ownGoals));
        }
        return players;
      case SpinnerOption.matches:
        if (desc) {
          players.sort((b, a) => a.matches.compareTo(b.matches));
          return players;
        } else {
          players.sort((a, b) => a.matches.compareTo(b.matches));
        }
        return players;
      case SpinnerOption.goalkeepingMinutes:
        if (desc) {
          players.sort(
              (b, a) => a.goalkeepingMinutes.compareTo(b.goalkeepingMinutes));
          return players;
        } else {
          players.sort(
              (a, b) => a.goalkeepingMinutes.compareTo(b.goalkeepingMinutes));
        }
        return players;
      case SpinnerOption.goalRatio:
        if (desc) {
          players.sort((b, a) =>
              a.getGoalMatchesRatio().compareTo(b.getGoalMatchesRatio()));
          return players;
        } else {
          players.sort((a, b) =>
              a.getGoalMatchesRatio().compareTo(b.getGoalMatchesRatio()));
        }
        return players;
      case SpinnerOption.receivedGoalsRatio:
        if (desc) {
          players.sort((b, a) => a
              .getReceivedGoalsGoalkeepingMinutesRatio()
              .compareTo(b.getReceivedGoalsGoalkeepingMinutesRatio()));
          return players;
        } else {
          players.sort((a, b) => a
              .getReceivedGoalsGoalkeepingMinutesRatio()
              .compareTo(b.getReceivedGoalsGoalkeepingMinutesRatio()));
        }
        return players;
      case SpinnerOption.yellowCardRatio:
        if (desc) {
          players.sort((b, a) => a
              .getYellowCardMatchesRatio()
              .compareTo(b.getYellowCardMatchesRatio()));
          return players;
        } else {
          players.sort((a, b) => a
              .getYellowCardMatchesRatio()
              .compareTo(b.getYellowCardMatchesRatio()));
        }
        return players;
      case SpinnerOption.hattrick:
        if (desc) {
          players.sort((b, a) => a.hattrick.compareTo(b.hattrick));
          return players;
        } else {
          players.sort((a, b) => a.hattrick.compareTo(b.hattrick));
        }
        return players;
      case SpinnerOption.cleanSheet:
        if (desc) {
          players.sort((b, a) => a.cleanSheet.compareTo(b.cleanSheet));
          return players;
        } else {
          players.sort((a, b) => a.cleanSheet.compareTo(b.cleanSheet));
        }
        return players;
      case SpinnerOption.cardDetail:
        return filterPlayerWithComments(players);
      case SpinnerOption.receivedGoals:
        if (desc) {
          players.sort((b, a) => a.receivedGoals.compareTo(b.receivedGoals));
          return players;
        } else {
          players.sort((a, b) => a.receivedGoals.compareTo(b.receivedGoals));
        }
        return players;
    }
  }

  List<PkflPlayerStats> filterPlayerWithComments(
      List<PkflPlayerStats> allPlayers) {
    List<PkflPlayerStats> players = [];
    for (PkflPlayerStats playerStats in allPlayers) {
      if (playerStats.cardDetail.isNotEmpty) {
        for (String cardDetail in playerStats.cardDetail) {
          PkflPlayerStats pkflPlayerStats = PkflPlayerStats(playerStats.name);
          pkflPlayerStats.singleCardDetail = cardDetail;
          players.add(pkflPlayerStats);
        }
      }
    }
    return players;
  }
}
