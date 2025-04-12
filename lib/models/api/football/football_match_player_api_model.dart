import 'package:trus_app/models/api/football/football_player_api_model.dart';
import 'package:trus_app/models/api/football/team_api_model.dart';

import '../../../config.dart';
import '../interfaces/json_and_http_converter.dart';
import '../interfaces/model_to_string.dart';

class FootballMatchPlayerApiModel implements JsonAndHttpConverter, ModelToString {
  final int id;
  final FootballPlayerApiModel player;
  final int goals;
  final int receivedGoals;
  final int ownGoals;
  final int goalkeepingMinutes;
  final int yellowCards;
  final int redCards;
  final bool bestPlayer;
  final bool hattrick;
  final bool cleanSheet;
  final String? yellowCardComment;
  final String? redCardComment;
  final int? matchId;
  final TeamApiModel team;

  FootballMatchPlayerApiModel({
    required this.id,
    required this.player,
    required this.goals,
    required this.receivedGoals,
    required this.ownGoals,
    required this.goalkeepingMinutes,
    required this.yellowCards,
    required this.redCards,
    required this.bestPlayer,
    required this.hattrick,
    required this.cleanSheet,
    this.yellowCardComment,
    this.redCardComment,
    this.matchId,
    required this.team,
  });

  factory FootballMatchPlayerApiModel.fromJson(Map<String, dynamic> json) {
    return FootballMatchPlayerApiModel(
      id: json["id"],
      player: FootballPlayerApiModel.fromJson(json["player"]),
      goals: json["goals"],
      receivedGoals: json["receivedGoals"],
      ownGoals: json["ownGoals"],
      goalkeepingMinutes: json["goalkeepingMinutes"],
      yellowCards: json["yellowCards"],
      redCards: json["redCards"],
      bestPlayer: json["bestPlayer"],
      hattrick: json["hattrick"],
      cleanSheet: json["cleanSheet"],
      yellowCardComment: json["yellowCardComment"],
      redCardComment: json["redCardComment"],
      matchId: json["matchId"],
      team: TeamApiModel.fromJson(json["team"]),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "player": player.toJson(),
      "goals": goals,
      "receivedGoals": receivedGoals,
      "ownGoals": ownGoals,
      "goalkeepingMinutes": goalkeepingMinutes,
      "yellowCards": yellowCards,
      "redCards": redCards,
      "bestPlayer": bestPlayer,
      "hattrick": hattrick,
      "cleanSheet": cleanSheet,
      "yellowCardComment": yellowCardComment,
      "redCardComment": redCardComment,
      "matchId": matchId,
      "team": team.toJson(),
    };
  }

  @override
  int getId() {
    return id;
  }

  @override
  String httpRequestClass() {
    return footballTableApi;
  }

  @override
  String listViewTitle() {
    return player.name;
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
    return "rok narození:";

  }
}
