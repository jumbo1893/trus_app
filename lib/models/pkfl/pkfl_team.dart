
import 'package:trus_app/models/pkfl/pkfl_match_detail.dart';
import 'package:trus_app/models/pkfl/pkfl_match_player.dart';

class PkflTeam {
  final int order;
  final String name;
  final int matches;
  final String winDrawLose;
  final String score;
  final String penalty;
  final int points;

  PkflTeam(this.order, this.name, this.matches, this.winDrawLose, this.score,
       this.penalty, this.points,);



  String toStringForTitle() {

    return "$order. $name";
  }

  String toStringForSubtitle() {
    return "počet bodů: $points, počet zápasů: $matches, V/R/P: $winDrawLose, skóre: $score, tresty: $penalty,";
  }
}