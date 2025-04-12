import 'package:trus_app/config.dart';
import 'package:trus_app/models/api/achievement/player_achievement_api_model.dart';
import 'package:trus_app/models/api/interfaces/json_and_http_converter.dart';

class AchievementPlayerDetail implements JsonAndHttpConverter {
  final List<PlayerAchievementApiModel> accomplishedPlayerAchievements;
  final List<PlayerAchievementApiModel> notAccomplishedPlayerAchievements;
  int? totalCount;
  double? successRate;

  AchievementPlayerDetail({
    required this.accomplishedPlayerAchievements,
    required this.notAccomplishedPlayerAchievements,
    this.totalCount,
    this.successRate
  });

  @override
  Map<String, dynamic> toJson() {
    return {
      "achievement": accomplishedPlayerAchievements,
      "totalCount": totalCount,
      "accomplishedCount": notAccomplishedPlayerAchievements,
      "successRate": successRate,
    };
  }

  AchievementPlayerDetail.dummy()
      : accomplishedPlayerAchievements = [],
        notAccomplishedPlayerAchievements = [],
        totalCount = 0,
        successRate = 0;

  @override
  factory AchievementPlayerDetail.fromJson(Map<String, dynamic> json) {
    return AchievementPlayerDetail(
      accomplishedPlayerAchievements: List<PlayerAchievementApiModel>.from((json['accomplishedPlayerAchievements'] as List<dynamic>).map((playerAchievement) => PlayerAchievementApiModel.fromJson(playerAchievement))),
      notAccomplishedPlayerAchievements: List<PlayerAchievementApiModel>.from((json['notAccomplishedPlayerAchievements'] as List<dynamic>).map((playerAchievement) => PlayerAchievementApiModel.fromJson(playerAchievement))),
      totalCount: json['totalCount'] ?? 0,
      successRate: json['successRate'] ?? 0.0,
    );
  }


  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AchievementPlayerDetail &&
          runtimeType == other.runtimeType &&
          accomplishedPlayerAchievements ==
              other.accomplishedPlayerAchievements &&
          notAccomplishedPlayerAchievements ==
              other.notAccomplishedPlayerAchievements &&
          totalCount == other.totalCount &&
          successRate == other.successRate;

  @override
  int get hashCode =>
      accomplishedPlayerAchievements.hashCode ^
      notAccomplishedPlayerAchievements.hashCode ^
      totalCount.hashCode ^
      successRate.hashCode;

  @override
  String httpRequestClass() {
    return achievementApi;
  }
}
