import 'package:trus_app/models/api/player_api_model.dart';
import 'package:trus_app/models/api/season_api_model.dart';

import '../../../config.dart';
import '../interfaces/json_and_http_converter.dart';
import '../pkfl/pkfl_match_api_model.dart';
import 'match_api_model.dart';

class MatchSetup implements JsonAndHttpConverter {
  MatchApiModel? match;
  PkflMatchApiModel? pkflMatch;
  final List<SeasonApiModel> seasonList;
  final List<PlayerApiModel> playerList;
  final List<PlayerApiModel> fanList;
  final SeasonApiModel primarySeason;

  MatchSetup({
    required this.seasonList,
    required this.playerList,
    required this.fanList,
    required this.primarySeason,
    this.match,
    this.pkflMatch,
  });

  @override
  Map<String, dynamic> toJson() {
    return {
      "match": match,
      "seasonList": seasonList,
      "playerList": playerList,
      "fanList": fanList,
      "primarySeason": primarySeason,
      "pkflMatch": pkflMatch,
    };
  }

  @override
  factory MatchSetup.fromJson(Map<String, dynamic> json) {
    return MatchSetup(
      match: json["match"] != null ? MatchApiModel.fromJson(json["match"]) : null,
      pkflMatch: json["pkflMatch"] != null ? PkflMatchApiModel.fromJson(json["pkflMatch"]) : null,
      seasonList: List<SeasonApiModel>.from((json['seasonList'] as List<dynamic>).map((season) => SeasonApiModel.fromJson(season))),
      playerList: List<PlayerApiModel>.from((json['playerList'] as List<dynamic>).map((player) => PlayerApiModel.fromJson(player))),
      fanList: List<PlayerApiModel>.from((json['fanList'] as List<dynamic>).map((fan) => PlayerApiModel.fromJson(fan))),
      primarySeason: SeasonApiModel.fromJson(json["primarySeason"]),
    );
  }

  @override
  String httpRequestClass() {
    return matchApi;
  }

  @override
  String toString() {
    return 'MatchSetup{match: $match, pkflMatch: $pkflMatch, seasonList: $seasonList, playerList: $playerList, fanList: $fanList}';
  }
}
