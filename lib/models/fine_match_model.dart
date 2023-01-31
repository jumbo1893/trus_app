
class FineMatchModel {
  final String id;
  final String matchId;
  final String fineId;
  final String playerId;
  final int number;

  FineMatchModel({
    required this.id,
    required this.matchId,
    required this.fineId,
    required this.playerId,
    required this.number,
  });

  FineMatchModel.dummy()
      : id = "dummy",
        matchId = "dummy",
        fineId = "dummy",
        playerId = "dummy",
        number = 0;

  Map<String, dynamic> toJson() {
    return {
      "matchId": matchId,
      "id": id,
      "fineId": fineId,
      "playerId": playerId,
      "number": number,
    };
  }

  @override
  String toString() {
    return 'FineMatchModel{id: $id, matchId: $matchId, fineId: $fineId, number: $number}';
  }

  factory FineMatchModel.fromJson(Map<String, dynamic> json) {
    return FineMatchModel(
      matchId: json['matchId'] ?? "",
      fineId: json["fineId"] ?? "",
      playerId: json["playerId"] ?? "",
      number: json["number"] ?? 0,
      id: json["id"] ?? "",
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FineMatchModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

//

}
