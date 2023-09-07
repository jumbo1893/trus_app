import '../enum/fine.dart';
import '../match_model.dart';
import '../player_model.dart';
import 'fine_match_stats_helper_model.dart';

class FineStatsHelperModel {
  //seznam všech pokut s id hráče, zápasu, hráče, pokuty a počtem
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
    List<String> playerIds = [];
    for (FineMatchStatsHelperModel fineModel in listOfFines) {
      if(!playerIds.contains(fineModel.playerId)) {
        playerIds.add(fineModel.playerId);
      }
    }
    return playerIds;
  }

  @override
  String toString() {
    return 'player: ${player!.name}, totalAmount: ${totalAmount()} Kč';
  }

int totalAmount() {
    int overall = 0;
    for (FineMatchStatsHelperModel fine in listOfFines) {
      overall += fine.number*fine.fine.amount;
    }
    return overall;
  }

  /*@override
  String toString() {
    return 'FineStatsHelperModel{listOfFines: ${returnPlayerDetail(match!.id)}, player: ${player!.name}, match: ${match!.name}';
  }*/


}
