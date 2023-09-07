
import 'goal_detailed_model.dart';

class GoalDetailedResponse {
  final int playersCount;
  final int matchesCount;
  final int totalGoals;
  final int totalAssists;
  final List<GoalDetailedModel> goalList;

  GoalDetailedResponse({
    required this.playersCount,
    required this.matchesCount,
    required this.totalGoals,
    required this.totalAssists,
    required this.goalList,
  });

  factory GoalDetailedResponse.fromJson(Map<String, dynamic> json) {
    return GoalDetailedResponse(
      playersCount: json["playersCount"] ?? 0,
      matchesCount: json["matchesCount"] ?? 0,
      totalGoals: json["totalGoals"] ?? 0,
      totalAssists: json["totalAssists"] ?? 0,
      goalList: List<GoalDetailedModel>.from((json['goalList'] as List<dynamic>).map((match) => GoalDetailedModel.fromJson(match))),
    );
  }

  String overallStatsToString() {
    return "$totalGoals gólů a $totalAssists asistencí v $playersCount hráčích a $matchesCount zápasech";
  }
}
