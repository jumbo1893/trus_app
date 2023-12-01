import 'package:trus_app/config.dart';
import 'package:trus_app/models/api/interfaces/json_and_http_converter.dart';
import 'package:trus_app/models/api/interfaces/model_to_string.dart';
import 'package:trus_app/models/api/pkfl/pkfl_player_api_model.dart';

class PkflIndividualStatsApiModel {
  int id;
  PkflPlayerApiModel player;
  int goals;
  int receivedGoals;
  int ownGoals;
  int goalkeepingMinutes;
  int yellowCards;
  int redCards;
  bool bestPlayer;
  bool hattrick;
  bool cleanSheet;
  String? yellowCardComment;
  String? redCardComment;
  int matchId;


  PkflIndividualStatsApiModel({
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
      required this.matchId});


  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "player": player,
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
    };
  }

  factory PkflIndividualStatsApiModel.fromJson(Map<String, dynamic> json) {
    return PkflIndividualStatsApiModel(
      id: json["id"],
      player: PkflPlayerApiModel.fromJson(json["player"]),
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
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PkflIndividualStatsApiModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

}
