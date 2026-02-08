import 'package:trus_app/models/api/football/league_api_model.dart';

import '../../../config.dart';
import '../interfaces/json_and_http_converter.dart';
import '../interfaces/model_to_string.dart';

class TableTeamApiModel implements JsonAndHttpConverter, ModelToString {
  int? id;
  final int rank;
  final int matches;
  final int wins;
  final int draws;
  final int losses;
  final int goalsScored;
  final int goalsReceived;
  final String penalty;
  final int points;
  final int teamId;
  final String teamName;
  final LeagueApiModel league;

  TableTeamApiModel({
    this.id,
    required this.rank,
    required this.matches,
    required this.wins,
    required this.draws,
    required this.losses,
    required this.goalsScored,
    required this.goalsReceived,
    required this.penalty,
    required this.points,
    required this.teamId,
    required this.teamName,
    required this.league,
  });

  TableTeamApiModel.dummy()
      : id = -100,
        rank = 0,
        matches = 0,
        wins = 0,
        draws = 0,
        losses = 0,
        goalsScored = 0,
        goalsReceived = 0,
        penalty = "",
        points = 0,
        teamId = 0,
        teamName = "",
        league = LeagueApiModel.dummy();

  @override
  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "rank": rank,
      "matches": matches,
      "wins": wins,
      "draws": draws,
      "losses": losses,
      "goalsScored": goalsScored,
      "goalsReceived": goalsReceived,
      "penalty": penalty,
      "points": points,
      "teamId": teamId,
      "league": league,
      "teamName": teamName,
    };
  }

  factory TableTeamApiModel.fromJson(Map<String, dynamic> json) {
    return TableTeamApiModel(
      id: json["id"],
      rank: json["rank"],
      matches: json["matches"],
      wins: json["wins"],
      draws: json["draws"],
      losses: json["losses"],
      goalsScored: json["goalsScored"],
      goalsReceived: json["goalsReceived"],
      penalty: json["penalty"],
      points: json["points"],
      teamId: json["teamId"],
      teamName: json["teamName"],
      league: LeagueApiModel.fromJson(json["league"]),
    );
  }

  String toStringForDetail() {
    return "počet bodů: $points, počet zápasů: $matches, V/R/P: $wins/$draws/$losses, skóre: $goalsScored:$goalsReceived";
  }


  @override
  String toString() {
    return 'TableTeamApiModel{id: $id, rank: $rank, matches: $matches, wins: $wins, draws: $draws, losses: $losses, goalsScored: $goalsScored, goalsReceived: $goalsReceived, penalty: $penalty, points: $points, teamId: $teamId, teamName: $teamName, league: $league}';
  }

  @override
  int getId() {
    return id?? -1;
  }

  @override
  String httpRequestClass() {
    return footballTableApi;
  }

  @override
  String listViewTitle() {
    return "$rank. $teamName";
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

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TableTeamApiModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
