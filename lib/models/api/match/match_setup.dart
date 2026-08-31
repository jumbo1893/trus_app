import 'package:trus_app/models/api/football/football_match_api_model.dart';
import 'package:trus_app/models/api/player/player_api_model.dart';
import 'package:trus_app/models/api/season_api_model.dart';

import '../../../config.dart';
import '../interfaces/json_and_http_converter.dart';
import 'match_api_model.dart';

class MatchSetup implements JsonAndHttpConverter {
  MatchApiModel? match;
  FootballMatchApiModel? footballMatch;
  final List<SeasonApiModel> seasonList;
  final List<PlayerApiModel> playerList;
  final List<PlayerApiModel> fanList;
  final List<PlayerApiModel> attendingPlayers;
  final List<PlayerApiModel> attendingFans;
  final SeasonApiModel primarySeason;

  MatchSetup({
    required this.seasonList,
    required this.playerList,
    required this.fanList,
    required this.primarySeason,
    this.attendingPlayers = const [],
    this.attendingFans = const [],
    this.match,
    this.footballMatch,
  });

  @override
  Map<String, dynamic> toJson() {
    return {
      "match": match,
      "seasonList": seasonList,
      "playerList": playerList,
      "fanList": fanList,
      "attendingPlayers": attendingPlayers,
      "attendingFans": attendingFans,
      "primarySeason": primarySeason,
      "footballMatch": footballMatch,
    };
  }

  factory MatchSetup.fromJson(Map<String, dynamic> json) {
    return MatchSetup(
      match: json["match"] != null
          ? MatchApiModel.fromJson(json["match"])
          : null,
      footballMatch: json["footballMatch"] != null
          ? FootballMatchApiModel.fromJson(json["footballMatch"])
          : null,
      seasonList: List<SeasonApiModel>.from(
        (json['seasonList'] as List<dynamic>).map(
          (season) => SeasonApiModel.fromJson(season),
        ),
      ),
      playerList: List<PlayerApiModel>.from(
        (json['playerList'] as List<dynamic>).map(
          (player) => PlayerApiModel.fromJson(player),
        ),
      ),
      fanList: List<PlayerApiModel>.from(
        (json['fanList'] as List<dynamic>).map(
          (fan) => PlayerApiModel.fromJson(fan),
        ),
      ),
      attendingPlayers: List<PlayerApiModel>.from(
        (json['attendingPlayers'] as List<dynamic>? ?? const []).map(
          (player) => PlayerApiModel.fromJson(player),
        ),
      ),
      attendingFans: List<PlayerApiModel>.from(
        (json['attendingFans'] as List<dynamic>? ?? const []).map(
          (fan) => PlayerApiModel.fromJson(fan),
        ),
      ),
      primarySeason: SeasonApiModel.fromJson(json["primarySeason"]),
    );
  }

  @override
  String httpRequestClass() {
    return matchApi;
  }

  @override
  String toString() {
    return 'MatchSetup{match: $match, footballMatch: $footballMatch, seasonList: $seasonList, playerListSize: ${playerList.length}, fanListSize: ${fanList.length}, attendingPlayersSize: ${attendingPlayers.length}, attendingFansSize: ${attendingFans.length}}';
  }
}
