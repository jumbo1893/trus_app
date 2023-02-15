class PlayerStatsModel {
  final String id;
  final String matchId;
  final String playerId;
  final int goalNumber;
  final int assistNumber;

  PlayerStatsModel({
    required this.id,
    required this.matchId,
    required this.playerId,
    required this.goalNumber,
    required this.assistNumber,
  });

  PlayerStatsModel.dummy()
      : id = "dummy",
        matchId = "dummy",
        playerId = "dummy",
        goalNumber = 0,
        assistNumber = 0;

  Map<String, dynamic> toJson() {
    return {
      "matchId": matchId,
      "id": id,
      "playerId": playerId,
      "goalNumber": goalNumber,
      "assistNumber": assistNumber,
    };
  }


  @override
  String toString() {
    return 'PlayerStatsModel{id: $id, matchId: $matchId, playerId: $playerId, goalNumber: $goalNumber, assistNumber: $assistNumber}';
  }

  factory PlayerStatsModel.fromJson(Map<String, dynamic> json) {
    return PlayerStatsModel(
      matchId: json['matchId'] ?? "",
      playerId: json["playerId"] ?? "",
      goalNumber: json["goalNumber"] ?? 0,
      assistNumber: json["assistNumber"] ?? 0,
      id: json["id"] ?? "",
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlayerStatsModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

//

}
