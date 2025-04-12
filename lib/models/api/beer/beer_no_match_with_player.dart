import 'package:trus_app/models/api/player/player_api_model.dart';

import '../interfaces/add_to_string.dart';

class BeerNoMatchWithPlayer implements AddToString {
  int? id;
  final PlayerApiModel player;
  int beerNumber;
  int liquorNumber;

  BeerNoMatchWithPlayer({
    this.id,
    required this.player,
    required this.beerNumber,
    required this.liquorNumber,
  });

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "player": player,
      "beerNumber": beerNumber,
      "liquorNumber": liquorNumber,
    };
  }


  factory BeerNoMatchWithPlayer.fromJson(Map<String, dynamic> json) {
    return BeerNoMatchWithPlayer(
      id: json["id"],
      player: PlayerApiModel.fromJson(json["player"]),
      beerNumber: json["beerNumber"] ?? 0,
      liquorNumber: json["liquorNumber"] ?? 0,
    );
  }

  @override
  void addNumber(bool beer) {
    if(beer) {
      beerNumber++;
    }
    else {
      liquorNumber++;
    }
  }

  @override
  int number(bool beer) {
    if(beer) {
      return beerNumber;
    }
    else {
      return liquorNumber;
    }
  }

  @override
  String numberToString(bool beer) {
    if(beer) {
      return beerNumber.toString();
    }
    return liquorNumber.toString();
  }

  @override
  void removeNumber(bool beer) {
    if(beer) {
      if (beerNumber > 0) {
        beerNumber--;
      }
    }
    else {
      if (liquorNumber > 0) {
        liquorNumber--;
      }
    }
  }

  @override
  String toStringForListView() {
    return player.name;
  }
}
