

class PlayerAchievementCount {
  final int totalAchievements;
  final int accomplishedAchievements;

  PlayerAchievementCount({
    required this.totalAchievements,
    required this.accomplishedAchievements,
  });

  factory PlayerAchievementCount.fromJson(Map<String, dynamic> json) {
    return PlayerAchievementCount(
      totalAchievements: json["totalAchievements"],
      accomplishedAchievements: json["accomplishedAchievements"],
    );
  }
}
