import 'package:trus_app/config.dart';
import 'package:trus_app/models/api/achievement/achievement_api_model.dart';
import 'package:trus_app/models/api/achievement/player_achievement_api_model.dart';
import 'package:trus_app/models/api/interfaces/json_and_http_converter.dart';
import 'package:trus_app/models/api/interfaces/model_to_string.dart';

import '../../../common/utils/utils.dart';

class AchievementDetail implements JsonAndHttpConverter, ModelToString {
  final AchievementApiModel achievement;
  int? totalCount;
  int? accomplishedCount;
  double? successRate;
  PlayerAchievementApiModel? playerAchievement;
  String? accomplishedPlayers;

  AchievementDetail({
    required this.achievement,
    this.totalCount,
    this.accomplishedCount,
    this.successRate,
    this.playerAchievement,
    this.accomplishedPlayers
  });

  bool get isPlayerAchievementAccomplished {
    return playerAchievement?.accomplished ?? false;
  }

  String get getPlayerAchievementName {
    return playerAchievement?.player.name ?? "-";
  }

  String get getPlayerAchievementDetail {
    return playerAchievement?.detail ?? "-";
  }

  String get getPlayerAchievementMatch {
    return playerAchievement?.getMatchDetail ?? "-";
  }

  String get getSuccessRate {
    return "${castDoubleToPercentage(successRate)}%";
  }

  AchievementDetail.dummy()
      : achievement = AchievementApiModel.dummy();

  @override
  Map<String, dynamic> toJson() {
    return {
      "achievement": achievement,
      "totalCount": totalCount,
      "accomplishedCount": accomplishedCount,
      "successRate": successRate,
      "playerAchievement": playerAchievement,
    };
  }

  @override
  factory AchievementDetail.fromJson(Map<String, dynamic> json) {
    return AchievementDetail(
      achievement: AchievementApiModel.fromJson(json["achievement"]),
      totalCount: json['totalCount'] ?? 0,
      accomplishedCount: json['accomplishedCount'] ?? 0,
      successRate: json['successRate'] ?? 0.0,
      playerAchievement: json["playerAchievement"] != null ? PlayerAchievementApiModel.fromJson(json["playerAchievement"]) : null,
      accomplishedPlayers: json['accomplishedPlayers'] ?? "",
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AchievementDetail &&
          runtimeType == other.runtimeType &&
          achievement.id == other.achievement.id;

  @override
  int get hashCode => achievement.id.hashCode;

  @override
  String httpRequestClass() {
    return achievementApi;
  }

  @override
  int getId() {
    return achievement.getId();
  }

  @override
  String listViewTitle() {
    return achievement.name;
  }

  @override
  String toStringForAdd() {
    return "";
  }

  @override
  String toStringForConfirmationDelete() {
    return "";
  }

  @override
  String toStringForEdit(String originName) {
    return "";
  }

  @override
  String toStringForListView() {
    return "splněno u $getSuccessRate hráčů, $accomplishedCount/$totalCount";
  }

  @override
  String toString() {
    return 'AchievementDetail{achievement: $achievement, totalCount: $totalCount, accomplishedCount: $accomplishedCount, successRate: $successRate, playerAchievement: $playerAchievement, accomplishedPlayers: $accomplishedPlayers}';
  }
}
