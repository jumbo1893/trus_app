import 'package:trus_app/models/api/match/match_api_model.dart';
import 'package:trus_app/models/api/player_api_model.dart';
import 'package:trus_app/models/api/season_api_model.dart';

import 'beer_no_match_with_player.dart';

class BeerSetupResponse {
  MatchApiModel? match;
  final SeasonApiModel season;
  final List<MatchApiModel> matchList;
  final List<BeerNoMatchWithPlayer> beerList;

  BeerSetupResponse({
    this.match,
    required this.season,
    required this.matchList,
    required this.beerList,
  });


  factory BeerSetupResponse.fromJson(Map<String, dynamic> json) {
    return BeerSetupResponse(
      match: json["match"] != null ? MatchApiModel.fromJson(json["match"]) : null,
      season: SeasonApiModel.fromJson(json["season"]),
      beerList: List<BeerNoMatchWithPlayer>.from((json['beerList'] as List<dynamic>).map((beer) => BeerNoMatchWithPlayer.fromJson(beer))),
      matchList: List<MatchApiModel>.from((json['matchList'] as List<dynamic>).map((match) => MatchApiModel.fromJson(match))),
    );
  }
}
