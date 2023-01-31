class BeerModel {
  final String id;
  final String matchId;
  final String playerId;
  final int beerNumber;
  final int liquorNumber;

  BeerModel({
    required this.id,
    required this.matchId,
    required this.playerId,
    required this.beerNumber,
    required this.liquorNumber,
  });

  BeerModel.dummy()
      : id = "dummy",
        matchId = "dummy",
        playerId = "dummy",
        beerNumber = 0,
        liquorNumber = 0;

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

  factory BeerModel.fromJson(Map<String, dynamic> json) {
    return BeerModel(
      matchId: json['matchId'] ?? "",
      playerId: json["playerId"] ?? "",
      beerNumber: json["beerNumber"] ?? 0,
      liquorNumber: json["liquorNumber"] ?? 0,
     // drinkingStart: DateTime.fromMillisecondsSinceEpoch(json['drinkingStart']),
     // drinkingEnd: DateTime.fromMillisecondsSinceEpoch(json['drinkingEnd']),
      id: json["id"] ?? "",
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BeerModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

//

}
