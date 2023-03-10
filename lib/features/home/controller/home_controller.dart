import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/features/beer/repository/beer_repository.dart';
import 'package:trus_app/features/fine/match/repository/fine_match_repository.dart';
import 'package:trus_app/features/match/repository/match_repository.dart';
import 'package:trus_app/features/pkfl/repository/pkfl_repository.dart';
import 'package:trus_app/features/player/repository/player_repository.dart';
import 'package:trus_app/features/season/repository/season_repository.dart';
import 'package:trus_app/features/statistics/repository/stats_repository.dart';
import 'package:trus_app/models/helper/player_stats_helper_model.dart';
import 'package:trus_app/models/match_model.dart';
import 'package:trus_app/models/player_model.dart';

import '../../../models/enum/model.dart';
import '../../../models/pkfl/pkfl_match.dart';
import '../../../models/season_model.dart';
import '../../fine/repository/fine_repository.dart';
import '../../pkfl/tasks/retrieve_matches_task.dart';
import '../random_fact.dart';

final homeControllerProvider = Provider((ref) {
  final matchRepository = ref.watch(matchRepositoryProvider);
  final fineMatchRepository = ref.watch(fineMatchRepositoryProvider);
  final pkflRepository = ref.watch(pkflRepositoryProvider);
  final playerRepository = ref.watch(playerRepositoryProvider);
  final seasonRepository = ref.watch(seasonRepositoryProvider);
  final beerRepository = ref.watch(beerRepositoryProvider);
  final fineRepository = ref.watch(fineRepositoryProvider);
  final statsRepository = ref.watch(statsRepositoryProvider);
  return HomeController(
      matchRepository: matchRepository,
      fineMatchRepository: fineMatchRepository,
      pkflRepository: pkflRepository,
      playerRepository: playerRepository,
      seasonRepository: seasonRepository,
      beerRepository: beerRepository,
      fineRepository: fineRepository,
      statsRepository: statsRepository,
      ref: ref);
});

class HomeController {
  final MatchRepository matchRepository;
  final FineMatchRepository fineMatchRepository;
  final PkflRepository pkflRepository;
  final PlayerRepository playerRepository;
  final SeasonRepository seasonRepository;
  final BeerRepository beerRepository;
  final FineRepository fineRepository;
  final StatsRepository statsRepository;
  final ProviderRef ref;
  final RandomFact randomFact = RandomFact();

  HomeController({
    required this.matchRepository,
    required this.fineMatchRepository,
    required this.pkflRepository,
    required this.playerRepository,
    required this.seasonRepository,
    required this.beerRepository,
    required this.fineRepository,
    required this.statsRepository,
    required this.ref,
  });

  Stream<List<String>> randomFacts() {
    return randomFact.getRandomFactListStream();
  }

  Stream<List<MatchModel>> matches() {
    return matchRepository.getMatches();
  }

  void initRandomFact() {
    randomFact.initStreams(matchRepository.getMatches(), Model.match);
    randomFact.initStreams(fineMatchRepository.getFinesInMatches(), Model.fineMatch);
    randomFact.initStreams(fineMatchRepository.getFines(), Model.fine);
    randomFact.initStreams(playerRepository.getPlayers(), Model.player);
    randomFact.initStreams(beerRepository.getBeersInMatches(), Model.beer);
    randomFact.initStreams(seasonRepository.getSeasons(), Model.seasons);
    randomFact.initStreams(matchRepository.getPlayerStats(), Model.playerStats);

  }

  Stream<List<MatchModel>> matchesBySeason(String seasonId) {
    if (seasonId == "" || seasonId == SeasonModel.allSeason().id) {
      return matchRepository.getMatches();
    }
    return matchRepository.getMatchesBySeason(seasonId);
  }

  Stream<List<PlayerStatsHelperModel>> playersStatsInMatch(
      List<String> playerIdList, String matchId) {
    return matchRepository.getPlayersStatsForMatch(matchId, playerIdList);
  }

  Stream<String> getNextPlayerBirthday() {
    return playerRepository.getPlayers().map((event)  {
      return _returnNextPlayerBirthdayFromList(event);
    });
  }

  String _returnNextPlayerBirthdayFromList(List<PlayerModel> players) {
    List<PlayerModel> returnPlayers = [];
    for (PlayerModel playerModel in players) {
      if (returnPlayers.isEmpty) {
        returnPlayers.add(playerModel);
      } else if (playerModel.compareBirthday(returnPlayers[0]) == 0) {
        returnPlayers.clear();
        returnPlayers.add(playerModel);
      }
      else if (playerModel.compareBirthday(returnPlayers[0]) == 2) {
        returnPlayers.add(playerModel);
      }
    }
    if (returnPlayers.isEmpty) {
      return "Nelze najít dny do narozenin hráčů, hrajou vůbec nějaký za Trus?";
    } else if (!returnPlayers[0].isTodayBirthDay()) {
      if (returnPlayers.length == 1) {
        if (returnPlayers[0].fan) {
          return "Příští rundu platí věrný fanoušek ${returnPlayers[0].name}, který bude mít za ${returnPlayers[0].nextBirthdayToString()} své ${returnPlayers[0].calculateAge() + 1}. narozeniny";
        } else {
          return "Příští rundu platí ${returnPlayers[0].name}, který bude mít za ${returnPlayers[0].nextBirthdayToString()} své ${returnPlayers[0].calculateAge() + 1}. narozeniny";
        }
      } else {
        String text = "Příští rundu platí ";
        for (int i = 0; i < returnPlayers.length; i++) {
          if (i == returnPlayers.length - 1) {
            text += "${returnPlayers[i].name} ";
          } else if (i == returnPlayers.length - 2) {
            text += "${returnPlayers[i].name} a ";
          } else {
            text += "${returnPlayers[i].name}, ";
          }
        }
        text += "kteří mají za ${returnPlayers[0].nextBirthdayToString()} své ";
        for (int i = 0; i < returnPlayers.length; i++) {
          text += "${returnPlayers[i].calculateAge() + 1}.";
          if (i == returnPlayers.length - 1) {
            text += " narozeniny";
          } else if (i == returnPlayers.length - 2) {
            text += " a ";
          } else {
            text += ", ";
          }
        }
        return text;
      }
    } else {
      if (returnPlayers.length == 1) {
        if (returnPlayers[0].fan) {
          return ("Dnes slaví narozeniny fanoušek ${returnPlayers[0].name}, který má ${returnPlayers[0].calculateAge()} let. Už ten sud vyval a ať ti slouží splávek!");
        } else {
          return ("Dnes slaví narozeniny ${returnPlayers[0].name}, který má ${returnPlayers[0].calculateAge()} let. Už ten sud vyval a ať ti slouží splávek! Na Trus!!");
        }
      } else {
        String text = "Dnešní oslavenci jsou ";
        for (int i = 0; i < returnPlayers.length; i++) {
          if (i == returnPlayers.length - 1) {
            text += "${returnPlayers[i].name} ";
          } else if (i == returnPlayers.length - 2) {
            text += "${returnPlayers[i].name} a ";
          } else {
            text += "${returnPlayers[i].name}, ";
          }
        }
        text += "kteří mají slaví své nádherné ";
        for (int i = 0; i < returnPlayers.length; i++) {
          text += "${returnPlayers[i].calculateAge()}.";
          if (i == returnPlayers.length - 1) {
            text +=
                " narozeniny. Pánové, všichni doufáme že se pochlapíte. Na Trus!!!!";
          } else if (i == returnPlayers.length - 2) {
            text += " a ";
          } else {
            text += ", ";
          }
        }
        return text;
      }
    }
  }

  Future<PkflMatch?> getNextPkflMatch() async {
    String url = "";
    List<PkflMatch> matches = [];
    url = await pkflRepository.getPkflTeamUrl();
    RetrieveMatchesTask matchesTask = RetrieveMatchesTask(url);
    try {
      await matchesTask.returnPkflMatches().then((value) => matches = value);
    } catch (e, stacktrace) {
      print(stacktrace);
    }

    return returnNextPkflMatch(matches);
  }

  PkflMatch? returnNextPkflMatch(List<PkflMatch> pkflMatches) {
    PkflMatch? returnMatch;
    for (PkflMatch pkflMatch in pkflMatches) {
      if (pkflMatch.date.isAfter(DateTime.now())) {
        if (returnMatch == null || pkflMatch.date.isBefore(returnMatch.date)) {
          returnMatch = pkflMatch;
        }
      }
    }
    return returnMatch;
  }


}
