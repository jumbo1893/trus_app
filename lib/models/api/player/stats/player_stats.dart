import 'package:trus_app/features/general/cache/i_endpoint_id.dart';
import 'package:trus_app/models/api/player/stats/player_achievement_count.dart';
import 'package:trus_app/models/api/player/stats/player_beer_count.dart';
import 'package:trus_app/models/api/player/stats/player_fine_count.dart';
import 'package:trus_app/models/api/player/stats/player_footbar_count.dart';
import 'package:trus_app/models/api/player/stats/player_goal_count.dart';
import 'package:trus_app/models/api/season_api_model.dart';

class PlayerStats implements IEndpointId {
  final PlayerAchievementCount playerAchievementCount;
  final PlayerBeerCount playerBeerCount;
  final PlayerFineCount playerFineCount;
  final PlayerGoalCount playerGoalCount;
  PlayerFootbarCount? playerFootbarCount;
  final SeasonApiModel season;
  static const String endpoint = "PlayerSetup";

  PlayerStats({
    required this.playerAchievementCount,
    required this.playerBeerCount,
    required this.playerFineCount,
    required this.playerGoalCount,
    required this.season,

    this.playerFootbarCount,
  });

  @override
  factory PlayerStats.fromJson(Map<String, dynamic> json) {
    return PlayerStats(
      playerFootbarCount: json["playerFootbarCount"] != null ? PlayerFootbarCount.fromJson(json["playerFootbarCount"]) : null,
      playerBeerCount: PlayerBeerCount.fromJson(json["playerBeerCount"]),
      playerFineCount: PlayerFineCount.fromJson(json["playerFineCount"]),
      playerGoalCount: PlayerGoalCount.fromJson(json["playerGoalCount"]),
      season: SeasonApiModel.fromJson(json["season"]),
      playerAchievementCount: PlayerAchievementCount.fromJson(json["playerAchievementCount"]),
    );
  }

  @override
  String getEndpointId() {
    return endpoint;
  }
}
