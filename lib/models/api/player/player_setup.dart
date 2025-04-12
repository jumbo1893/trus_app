import 'package:trus_app/models/api/achievement/achievement_player_detail.dart';
import 'package:trus_app/models/api/football/football_player_api_model.dart';
import 'package:trus_app/models/api/football/stats/football_all_individual_stats_api_model.dart';
import 'package:trus_app/models/api/player/player_api_model.dart';

import '../../../config.dart';
import '../interfaces/json_and_http_converter.dart';

class PlayerSetup implements JsonAndHttpConverter {
  PlayerApiModel? player;
  final List<FootballPlayerApiModel> footballPlayerList;
  FootballAllIndividualStatsApiModel? playerStats;
  final FootballPlayerApiModel primaryFootballPlayer;
  AchievementPlayerDetail? achievementPlayerDetail;

  PlayerSetup({
    required this.player,
    required this.footballPlayerList,
    required this.primaryFootballPlayer,
    this.playerStats,
    this.achievementPlayerDetail,
  });

  @override
  Map<String, dynamic> toJson() {
    return {
      "player": player,
      "footballPlayerList": footballPlayerList,
      "playerStats": playerStats,
      "primaryFootballPlayer": primaryFootballPlayer,
      "achievementPlayerDetail": achievementPlayerDetail,
    };
  }

  @override
  factory PlayerSetup.fromJson(Map<String, dynamic> json) {
    return PlayerSetup(
      player: json["player"] != null ? PlayerApiModel.fromJson(json["player"]) : null,
      playerStats: json["playerStats"] != null ? FootballAllIndividualStatsApiModel.fromJson(json["playerStats"]) : null,
      footballPlayerList: List<FootballPlayerApiModel>.from((json['footballPlayerList'] as List<dynamic>).map((footballPlayer) => FootballPlayerApiModel.fromJson(footballPlayer))),
      primaryFootballPlayer: FootballPlayerApiModel.fromJson(json["primaryFootballPlayer"]),
      achievementPlayerDetail: json["achievementPlayerDetail"] != null ? AchievementPlayerDetail.fromJson(json["achievementPlayerDetail"]) : null,
    );
  }

  @override
  String httpRequestClass() {
    return matchApi;
  }

  @override
  String toString() {
    return 'PlayerSetup{player: $player, footballPlayerList: $footballPlayerList, playerStats: $playerStats}';
  }

  String getPlayerStats() {
    if(playerStats == null) {
      return "-";
    }
    return "${playerStats!.matches} zápasů / ${playerStats!.goals} gólů";
  }
}
