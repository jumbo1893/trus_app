
import 'package:trus_app/models/pkfl/pkfl_match_detail.dart';
import 'package:trus_app/models/pkfl/pkfl_match_player.dart';

class PkflMatch {
  final DateTime date;
  final String opponent;
  final int round;
  final String league;
  final String stadium;
  final String referee;
  final String result;
  final bool homeMatch;
  final String urlResult;
  PkflMatchDetail? pkflMatchDetail;

  PkflMatch(this.date, this.opponent, this.round, this.league, this.stadium,
      this.referee, this.result, this.homeMatch, this.urlResult, [this.pkflMatchDetail]);


  bool detailEnabled() {
    if (result == (":")) {
      return false;
    }
    return true;
  }

  String toStringNameWithOpponent() {
    if (homeMatch) {
      return "Liščí trus - $opponent";
    }
    return "$opponent - Liščí Trus";
  }

  String _dateToStringWithoutSecondsAndMilliseconds() {
    return date.toString().replaceAll(":00.000", "");
  }

  String returnFirstDetailsOfMatch() {
    String result;
    if (!detailEnabled()) {
      result = "Zápas se ještě nehrál";
    } else {
      result = this.result;
    }
    return "$round. kolo, $league, hrané ${_dateToStringWithoutSecondsAndMilliseconds()}\nStadion: $stadium\nRozhodčí: $referee\nVýsledek: $result";
  }

  String returnSecondDetailsOfMatch() {
  return "\n${pkflMatchDetail!.refereeComment} ${returnBestPlayerText(pkflMatchDetail!.getBestPlayer())}${returnGoalScorersText(pkflMatchDetail!.getGoalScorers())}${returnOwnGoalScorersText(pkflMatchDetail!.getOwnGoalScorers())}${returnYellowCardPlayersText(pkflMatchDetail!.getYellowCardPlayers())}${returnRedCardPlayersText(pkflMatchDetail!.getRedCardPlayers())}";

  }

  String returnBestPlayerText(PkflMatchPlayer? bestPlayer) {
    if (bestPlayer != null) {
      return ("\nHvězda zápasu: ${bestPlayer.name}");
    }
    return "";
  }

  String returnGoalScorersText(List<PkflMatchPlayer> pkflMatchPlayers) {
    String text = "";
    if (pkflMatchPlayers.isNotEmpty) {
      text += ("\n\nStřelci:\n");
      for (PkflMatchPlayer pkflMatchPlayer in pkflMatchPlayers) {
        int goalNumber = pkflMatchPlayer.goals;
        text += "${pkflMatchPlayer.name}: $goalNumber${(goalNumber == 1) ? " gól" : " góly"}\n";
      }
    }
    return text;
  }

  String returnOwnGoalScorersText(List<PkflMatchPlayer> pkflMatchPlayers) {
    String text = "";
    if (pkflMatchPlayers.isNotEmpty) {
      text += ("\nStřelci vlastňáků:\n");
      for (PkflMatchPlayer pkflMatchPlayer in pkflMatchPlayers) {
        text += "${pkflMatchPlayer.name}: ${pkflMatchPlayer.ownGoals}${(pkflMatchPlayer.ownGoals == 1) ? " vlastňák" : " vlastňáky"}\n";
      }
    }
    return text;
  }

  String returnYellowCardPlayersText(List<PkflMatchPlayer> pkflMatchPlayers) {
    String text = "";
    if (pkflMatchPlayers.isNotEmpty) {
      text += ("\nŽluté karty:\n");
      for (PkflMatchPlayer pkflMatchPlayer in pkflMatchPlayers) {
        text += ("${pkflMatchPlayer.name}: ${pkflMatchPlayer.yellowCards}\n");
      }
    }
    return text;
  }

  String returnRedCardPlayersText(List<PkflMatchPlayer> pkflMatchPlayers) {
    String text = "";
    if (pkflMatchPlayers.isNotEmpty) {
      text += ("\nČervené karty:\n");
      for (PkflMatchPlayer pkflMatchPlayer in pkflMatchPlayers) {
        text += ("${pkflMatchPlayer.name}: ${pkflMatchPlayer.redCards}\n");
      }
    }
    return text;
  }



  String toStringForSubtitle() {
    return "Datum: ${_dateToStringWithoutSecondsAndMilliseconds()}, výsledek: $result";
  }

  @override
  String toString() {
    return 'PkflMatch{date: $date, opponent: $opponent, round: $round, league: $league, stadium: $stadium, referee: $referee, result: $result, homeMatch: $homeMatch, urlResult: $urlResult, pkflMatchDetail: $pkflMatchDetail}';
  }
}