import 'package:trus_app/config.dart';
import 'package:trus_app/models/api/player_api_model.dart';

import '../interfaces/add_to_string.dart';

class BeerNoMatch {
  int? id;
  final int playerId;
  final int beerNumber;
  final int liquorNumber;

  BeerNoMatch({
    this.id,
    required this.playerId,
    required this.beerNumber,
    required this.liquorNumber,
  });

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "playerId": playerId,
      "beerNumber": beerNumber,
      "liquorNumber": liquorNumber,
    };
  }


  factory BeerNoMatch.fromJson(Map<String, dynamic> json) {
    return BeerNoMatch(
      id: json["id"],
      playerId: json["playerId"],
      beerNumber: json["beerNumber"] ?? 0,
      liquorNumber: json["liquorNumber"] ?? 0,
    );
  }
}
