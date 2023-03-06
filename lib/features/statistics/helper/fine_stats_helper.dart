import 'package:trus_app/features/statistics/helper/beer_season_helper.dart';
import 'package:trus_app/features/statistics/screens/match_beer_stats_screen.dart';
import 'package:trus_app/models/enum/fine.dart';
import 'package:trus_app/models/fine_model.dart';
import 'package:trus_app/models/match_model.dart';

import '../../../models/beer_model.dart';
import '../../../models/enum/drink.dart';
import '../../../models/enum/participant.dart';
import '../../../models/fine_match_model.dart';
import '../../../models/helper/beer_stats_helper_model.dart';
import '../../../models/helper/fine_match_stats_helper_model.dart';
import '../../../models/helper/fine_stats_helper_model.dart';
import '../../../models/player_model.dart';
import '../../../models/season_model.dart';
import 'fine_season_helper.dart';

class FineStatsHelper {
  final List<FineModel> fines;
  final List<FineMatchModel> matchFines;

  FineStatsHelper(this.fines, this.matchFines);

  List<FineStatsHelperModel> convertFineModelToFineStatsHelperModelForPlayers(
      List<PlayerModel> players) {
    final List<FineStatsHelperModel> finesWithPlayers = [];
    for (PlayerModel player in players) {
      List<FineMatchModel> listOfFinesMatches = _getListOfFinesByIdForPlayer(player);
      List<FineMatchStatsHelperModel> listOfFines = _getListOfFines(listOfFinesMatches);
      if (listOfFines.isNotEmpty) {
        finesWithPlayers.add(FineStatsHelperModel(listOfFines, player));
      }
    }
    return finesWithPlayers;
  }

  FineModel _getFineById(String id) {
    return fines.firstWhere((e) => e.id == id,
        orElse: () => FineModel.dummy());
  }

  List<FineMatchModel> _getListOfFinesByIdForPlayer(PlayerModel player) {
    return matchFines.where((element) => (element.playerId == player.id && element.number > 0)).toList();
  }

  List<FineStatsHelperModel> convertFineModelToFineStatsHelperModelForMatches(
      List<MatchModel> matches) {
    final List<FineStatsHelperModel> finesWithMatches= [];
    for (MatchModel match in matches) {
      List<FineMatchModel> listOfFinesMatches = _getListOfFinesByIdForMatch(match);
      List<FineMatchStatsHelperModel> listOfFines = _getListOfFines(listOfFinesMatches);
      if (listOfFines.isNotEmpty) {
        finesWithMatches.add(FineStatsHelperModel(listOfFines, null, match));
      }
    }
    return finesWithMatches;
  }

  List<FineMatchModel> _getListOfFinesByIdForMatch(MatchModel matchModel) {
    return matchFines.where((element) => (element.matchId == matchModel.id && element.number > 0)).toList();
  }

  List<FineMatchStatsHelperModel> _getListOfFines (List<FineMatchModel> listOfFinesMatches) {
    List<FineMatchStatsHelperModel> listOfFines = [];
    for (FineMatchModel fineMatchModel in listOfFinesMatches) {
      FineMatchStatsHelperModel fineMatchStatsHelperModel = FineMatchStatsHelperModel(
          id: fineMatchModel.id,
          fine: _getFineById(fineMatchModel.fineId),
          playerId: fineMatchModel.playerId,
          matchId: fineMatchModel.matchId,
          number: fineMatchModel.number);
      if (fineMatchStatsHelperModel.fine != FineModel.dummy()) {
        listOfFines.add(fineMatchStatsHelperModel);
      }
    }
    return listOfFines;
  }


  List<FineSeasonHelper> getSeasonWithMostFines(
      List<FineStatsHelperModel> finesInMatches, List<SeasonModel> seasons, Fine fine) {
    List<FineSeasonHelper> fineSeasons = [];
    FineSeasonHelper fineSeasonHelper = FineSeasonHelper(seasonModel: SeasonModel.otherSeason());
    _addFinesToFineSeasonHelper(fineSeasonHelper, finesInMatches);
    fineSeasons.add(fineSeasonHelper);
    for (SeasonModel season in seasons) {
      FineSeasonHelper fineSeasonHelper = FineSeasonHelper(seasonModel: season);
      _addFinesToFineSeasonHelper(fineSeasonHelper, finesInMatches);
      fineSeasons.add(fineSeasonHelper);
    }

    return _filterSeasonWithMostFines(fineSeasons, fine);
  }

  void _addFinesToFineSeasonHelper(
      FineSeasonHelper fineSeason, List<FineStatsHelperModel> finesInMatches) {
    for (FineStatsHelperModel fine in finesInMatches) {
      if (fine.match!.seasonId == fineSeason.seasonModel.id) {
        fineSeason.addFine(fine.getNumberOrAmountOfFines(Fine.number));
        fineSeason.addFineAmount(fine.getNumberOrAmountOfFines(Fine.amount));
        fineSeason.addMatch();
      }
    }
  }

  List<FineSeasonHelper> _filterSeasonWithMostFines(
      List<FineSeasonHelper> fineSeasons, Fine fine) {
    List<FineSeasonHelper> mostFineSeasons = [];
    for (FineSeasonHelper fineSeason in fineSeasons) {
      if (mostFineSeasons.isEmpty) {
        mostFineSeasons.add(fineSeason);
      } else if (fineSeason.getNumberOrAmount(fine) > mostFineSeasons[0].getNumberOrAmount(fine)) {
        mostFineSeasons.clear();
        mostFineSeasons.add(fineSeason);
      } else if (fineSeason.getNumberOrAmount(fine) == mostFineSeasons[0].getNumberOrAmount(fine)) {
        mostFineSeasons.add(fineSeason);
      }
    }
    return mostFineSeasons;
  }

  ///dodáme parametr playerFines obohacený bud o zápasy či o hráče. Sezona se může používat jenom pro obohacené playerFines o zápasy, jinak vyplňujeme null. Pokud nechceme pokuty dle sezony vyplňujeme null
  ///Parametr enumFine - amount pro celkovovou částku, number pro počet
  List<FineStatsHelperModel> getFineStatsHelperModelsWithMostFines(
      List<FineStatsHelperModel> playerFines, String? seasonId, Fine enumFine) {
    List<FineStatsHelperModel> returnFines = [];
    for (FineStatsHelperModel fine in playerFines) {
      if (seasonId == null || fine.match!.seasonId == seasonId) {
        if (returnFines.isEmpty) {
          returnFines.add(fine);
        } else if (fine.getNumberOrAmountOfFines(enumFine) >
            returnFines[0].getNumberOrAmountOfFines(enumFine)) {
          returnFines.clear();
          returnFines.add(fine);
        } else if (fine.getNumberOrAmountOfFines(enumFine) ==
            returnFines[0].getNumberOrAmountOfFines(enumFine)) {
          returnFines.add(fine);
        }
      }
    }
    return returnFines;
  }

  ///parametr players povinný, pokud není participant=both
  int getNumberOfPlayersInMatch(Participant participant, List<PlayerModel>? players, MatchModel match) {
    int number = 0;
    for(String id in match.playerIdList) {
      if(participant == Participant.both || (_isPlayer(players!, id) && participant == Participant.player) || (!_isPlayer(players, id) && participant == Participant.fan)) {
        number++;
      }
    }
    return number;
  }

  int getNumberOfPlayers(Participant participant, List<PlayerModel> players) {
    int number = 0;
    for(PlayerModel player in players) {
      if(participant == Participant.both || (!player.fan && participant == Participant.player) || (player.fan && participant == Participant.fan)) {
        number++;
      }
    }
    return number;
  }

  bool _isPlayer(List<PlayerModel> players, String playerId) {
    return !players
        .firstWhere((element) => (element.id == playerId))
        .fan;
  }
}
