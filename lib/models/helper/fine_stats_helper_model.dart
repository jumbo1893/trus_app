import '../enum/fine.dart';
import '../enum/participant.dart';
import '../match_model.dart';
import '../player_model.dart';
import 'fine_match_stats_helper_model.dart';

class FineStatsHelperModel {
  final List<FineMatchStatsHelperModel> listOfFines;
  PlayerModel? player;
  MatchModel? match;

  FineStatsHelperModel(this.listOfFines, [this.player, this.match]);

  int getNumberOrAmountOfFines(Fine fine) {
    int fines = 0;
    for(FineMatchStatsHelperModel fineMatch in listOfFines) {
      switch (fine) {
        case Fine.number:
          fines+= fineMatch.number;
          break;
        case Fine.amount:
          fines+= fineMatch.number*fineMatch.fine.amount;
          break;
      }
    }
    return fines;
  }

  ///parametr players povinný, pokud není participant=both
  int getNumberOfPlayersInMatch(Participant participant, List<PlayerModel>? players) {
    int number = 0;
    for(String id in getPlayerIdsFromMatchPlayer()) {
      if(participant == Participant.both || (_isPlayer(players!, id) && participant == Participant.player) || (!_isPlayer(players, id) && participant == Participant.fan)) {
        number++;
      }
    }
    return number;
  }

  bool _isPlayer(List<PlayerModel> players, String playerId) {;
    return !players
        .firstWhere((element) => (element.id == playerId))
        .fan;
  }

  String returnPlayerDetail(String matchId) {
    String detail = "";
    int totalFineNumber = 0;
    int totalAmountNumber = 0;
    int totalFinesNumber = 0;
    for (FineMatchStatsHelperModel fine in listOfFines) {
      if(fine.matchId == matchId) {
        detail += "${fine.number} pokuta ${fine.fine.name} v celkové částce ${fine.fine.amount*fine.number} Kč \n";
        totalFineNumber += fine.number;
        totalAmountNumber += fine.fine.amount*fine.number;
        totalFinesNumber++;
      }
    }
    if(totalFinesNumber > 1) {
      detail += "$totalFineNumber pokuty celkem, v součtu $totalAmountNumber Kč \n";
    }
    return detail;
  }

  String returnMatchDetail(String playerId) {
    String detail = "";
    int totalFineNumber = 0;
    int totalAmountNumber = 0;
    int totalFinesNumber = 0;
    for (FineMatchStatsHelperModel fine in listOfFines) {
      if(fine.playerId == playerId) {
        detail += "${fine.number} pokuta ${fine.fine.name} v celkové částce ${fine.fine.amount*fine.number} Kč \n";
        totalFineNumber += fine.number;
        totalAmountNumber += fine.fine.amount*fine.number;
        totalFinesNumber++;
      }
    }
    if(totalFinesNumber > 1) {
      detail += "$totalFineNumber pokuty celkem, v součtu $totalAmountNumber Kč \n";
    }
    return detail;
  }

  List<String> getMatchIdsFromPickedPlayer() {
    var uniqueMatches = <String>{};
    listOfFines.where((fine) => uniqueMatches.add(fine.matchId)).toList();
    return [...{...uniqueMatches}];
  }

  List<String> getPlayerIdsFromMatchPlayer() {
    List<String> matchIds = [];
    for (FineMatchStatsHelperModel fineModel in listOfFines) {
      matchIds.add(fineModel.playerId);
    }
    return matchIds;
  }
}
