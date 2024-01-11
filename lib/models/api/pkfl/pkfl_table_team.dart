import 'package:trus_app/models/api/pkfl/pkfl_opponent_api_model.dart';

import '../../../config.dart';
import '../interfaces/json_and_http_converter.dart';
import '../interfaces/model_to_string.dart';

class PkflTableTeam implements JsonAndHttpConverter, ModelToString {
  final PkflOpponentApiModel opponent;
  final int rank;
  final int matches;
  final int wins;
  final int draws;
  final int losses;
  final int goalsScored;
  final int goalsReceived;
  final String penalty;
  final int points;
  int? pkflMatchId;

  PkflTableTeam({
    required this.opponent,
    required this.rank,
    required this.matches,
    required this.wins,
    required this.draws,
    required this.losses,
    required this.goalsScored,
    required this.goalsReceived,
    required this.penalty,
    required this.points,
    this.pkflMatchId,
  });

  @override
  Map<String, dynamic> toJson() {
    return {
      "opponent": opponent,
      "rank": rank,
      "matches": matches,
      "wins": wins,
      "draws": draws,
      "losses": losses,
      "goalsScored": goalsScored,
      "goalsReceived": goalsReceived,
      "penalty": penalty,
      "points": points,
      "pkflMatchId": pkflMatchId,
    };
  }

  factory PkflTableTeam.fromJson(Map<String, dynamic> json) {
    return PkflTableTeam(
      opponent: PkflOpponentApiModel.fromJson(json["opponent"]),
      rank: json["rank"],
      matches: json["matches"],
      wins: json["wins"],
      draws: json["draws"],
      losses: json["losses"],
      goalsScored: json["goalsScored"],
      goalsReceived: json["goalsReceived"],
      penalty: json["penalty"],
      points: json["points"],
      pkflMatchId: json["pkflMatchId"],
    );
  }

  @override
  int getId() {
    return pkflMatchId?? -1;
  }

  @override
  String httpRequestClass() {
    return pkflTableApi;
  }

  @override
  String listViewTitle() {
    return "$rank. $opponent";
  }

  @override
  String toStringForAdd() {
    return "";
  }

  @override
  String toStringForConfirmationDelete() {
    return "";
  }

  @override
  String toStringForEdit(String originName) {
    return "";
  }

  @override
  String toStringForListView() {
    return "počet bodů: $points, počet zápasů: $matches, V/R/P: $wins/$draws/$losses, skóre: $goalsScored/$goalsReceived, tresty: $penalty,";

  }
}
