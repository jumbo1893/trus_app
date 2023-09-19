import 'package:trus_app/config.dart';
import 'package:trus_app/models/api/interfaces/json_and_http_converter.dart';

class GoalApiModel implements JsonAndHttpConverter {
  int? id;
  final int goalNumber;
  final int assistNumber;
  final int playerId;
  final int matchId;

  GoalApiModel({
    required this.goalNumber,
    required this.assistNumber,
    required this.playerId,
    required this.matchId,
    this.id,
  });

  GoalApiModel.dummy()
      : id = 0,
        goalNumber = 0,
        assistNumber = 0,
        playerId = 0,
        matchId = 0;


  @override
  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "goalNumber": goalNumber,
      "assistNumber": assistNumber,
      "playerId": playerId,
      "matchId": matchId,
    };
  }

  @override
  factory GoalApiModel.fromJson(Map<String, dynamic> json) {
    return GoalApiModel(
      goalNumber: json["goalNumber"] ?? 0,
      id: json["id"] ?? 0,
      assistNumber: json["assistNumber"] ?? 0,
      playerId: json["playerId"] ?? 0,
      matchId: json["matchId"] ?? 0,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GoalApiModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String httpRequestClass() {
    return goalApi;
  }

  @override
  String toString() {
    return 'GoalApiModel{id: $id, goalNumber: $goalNumber, assistNumber: $assistNumber, playerId: $playerId, matchId: $matchId}';
  }
}
