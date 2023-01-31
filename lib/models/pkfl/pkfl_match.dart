
import 'package:trus_app/models/pkfl/pkfl_match_detail.dart';

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


  String toStringNameWithOpponent() {
    if (homeMatch) {
      return "Liščí trus - $opponent";
    }
    return "$opponent - Liščí Trus";
  }

  String _dateToStringWithoutSecondsAndMilliseconds() {
    return date.toString().replaceAll(":00.000", "");
  }

  String toStringForSubtitle() {
    return "Datum: ${_dateToStringWithoutSecondsAndMilliseconds()}, výsledek: $result";
  }

  @override
  String toString() {
    return 'PkflMatch{date: $date, opponent: $opponent, round: $round, league: $league, stadium: $stadium, referee: $referee, result: $result, homeMatch: $homeMatch, urlResult: $urlResult, pkflMatchDetail: $pkflMatchDetail}';
  }
}