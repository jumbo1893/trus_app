
class PlayerGoalCount {
  final int totalGoals;
  final int totalAssists;

  PlayerGoalCount({
    required this.totalGoals,
    required this.totalAssists,
  });

  factory PlayerGoalCount.fromJson(Map<String, dynamic> json) {
    return PlayerGoalCount(
      totalGoals: json["totalGoals"],
      totalAssists: json["totalAssists"],
    );
  }

}
