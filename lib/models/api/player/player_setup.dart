import 'package:trus_app/models/api/achievement/achievement_player_detail.dart';
import 'package:trus_app/models/api/football/football_player_api_model.dart';
import 'package:trus_app/models/api/player/player_api_model.dart';

import '../../helper/title_and_text.dart';
import '../interfaces/json_and_http_converter.dart';

class PlayerSetup implements JsonAndHttpConverter {
  PlayerApiModel? player;
  final List<FootballPlayerApiModel> footballPlayerList;
  List<TitleAndText> playerStats;
  final FootballPlayerApiModel primaryFootballPlayer;
  AchievementPlayerDetail? achievementPlayerDetail;

  PlayerSetup({
    required this.player,
    required this.footballPlayerList,
    required this.primaryFootballPlayer,
    required this.playerStats,
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
      playerStats: List<TitleAndText>.from((json['playerStats'] as List<dynamic>).map((titleAndText) => TitleAndText.fromJson(titleAndText))),
      footballPlayerList: List<FootballPlayerApiModel>.from((json['footballPlayerList'] as List<dynamic>).map((footballPlayer) => FootballPlayerApiModel.fromJson(footballPlayer))),
      primaryFootballPlayer: FootballPlayerApiModel.fromJson(json["primaryFootballPlayer"]),
      achievementPlayerDetail: json["achievementPlayerDetail"] != null ? AchievementPlayerDetail.fromJson(json["achievementPlayerDetail"]) : null,
    );
  }

  @override
  String httpRequestClass() {
    return "";
  }

  @override
  String toString() {
    return 'PlayerSetup{player: $player, footballPlayerList: $footballPlayerList, playerStats: $playerStats}';
  }
}
