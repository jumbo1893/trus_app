class BeerApiModel {
  final int id;
  final int matchId;
  final int playerId;
  final int beerNumber;
  final int liquorNumber;

  BeerApiModel({
    required this.id,
    required this.matchId,
    required this.playerId,
    required this.beerNumber,
    required this.liquorNumber,
  });

  Map<String, dynamic> toJson() {
    return {
      "matchId": matchId,
      "id": id,
      "playerId": playerId,
      "beerNumber": beerNumber,
      "liquorNumber": liquorNumber,
      //"drinkingStart": drinkingStart.millisecondsSinceEpoch,
     // "drinkingEnd": drinkingEnd.millisecondsSinceEpoch,
    };
  }


  @override
  String toString() {
    return 'BeerMatchModel{id: $id, matchId: $matchId, playerId: $playerId, beerNumber: $beerNumber, liquorNumber: $liquorNumber}';
  }

  factory BeerApiModel.fromJson(Map<String, dynamic> json) {
    return BeerApiModel(
      matchId: json['matchId'] ?? 0,
      playerId: json["playerId"] ?? 0,
      beerNumber: json["beerNumber"] ?? 0,
      liquorNumber: json["liquorNumber"] ?? 0,
      id: json["id"] ?? "",
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BeerApiModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

//

}
