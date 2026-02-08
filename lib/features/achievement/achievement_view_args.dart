import '../../models/api/achievement/achievement_detail.dart';
import '../../models/api/achievement/player_achievement_api_model.dart';

class AchievementViewArgs {
  final AchievementDetail? achievementDetail;
  final PlayerAchievementApiModel? playerAchievement;

  const AchievementViewArgs.detail(this.achievementDetail)
      : playerAchievement = null;

  const AchievementViewArgs.player(this.playerAchievement)
      : achievementDetail = null;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is AchievementViewArgs &&
              runtimeType == other.runtimeType &&
              achievementDetail?.achievement.id == other.achievementDetail?.achievement.id &&
              playerAchievement?.id == other.playerAchievement?.id;

  @override
  int get hashCode =>
      Object.hash(
        achievementDetail?.achievement.id,
        playerAchievement?.id,
      );
}
