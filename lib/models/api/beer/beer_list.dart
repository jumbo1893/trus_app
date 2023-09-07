import 'package:trus_app/models/api/match/match_api_model.dart';
import 'package:trus_app/models/api/player_api_model.dart';
import 'package:trus_app/models/api/season_api_model.dart';

import 'beer_no_match.dart';
import 'beer_no_match_with_player.dart';

class BeerList {
  final int matchId;
  final List<BeerNoMatch> beerList;

  BeerList({
    required this.matchId,
    required this.beerList,
  });

  Map<String, dynamic> toJson() {
    return {
      "matchId": matchId,
      "beerList": beerList,
    };
  }
}
