import 'package:trus_app/models/api/goal/goal_api_model.dart';


class GoalListMultiAdd {
  final int matchId;
  final List<GoalApiModel> goalList;
  final bool rewriteToFines;

  GoalListMultiAdd({
    required this.matchId,
    required this.goalList,
    required this.rewriteToFines,
  });

  Map<String, dynamic> toJson() {
    return {
      "matchId": matchId,
      "goalList": goalList,
      "rewriteToFines": rewriteToFines,
    };
  }
}
