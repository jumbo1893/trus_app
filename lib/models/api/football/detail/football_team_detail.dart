import 'package:trus_app/models/api/football/detail/best_scorer.dart';
import 'package:trus_app/models/api/football/football_match_api_model.dart';
import 'package:trus_app/models/api/football/table_team_api_model.dart';

class FootballTeamDetail {
  final TableTeamApiModel tableTeam;
  final List<FootballMatchApiModel> mutualMatches;
  final List<FootballMatchApiModel> nextMatches;
  final List<FootballMatchApiModel> pastMatches;
  String? aggregateScore;
  String? aggregateMatches;
  final int averageBirthYear;
  BestScorer? bestScorer;

  FootballTeamDetail({
    required this.tableTeam,
    required this.mutualMatches,
    required this.nextMatches,
    required this.pastMatches,
    this.aggregateScore,
    this.aggregateMatches,
    required this.averageBirthYear,
    this.bestScorer,
  });

  Map<String, dynamic> toJson() {
    return {
      "footballMatch": tableTeam,
      "mutualMatches": mutualMatches,
      "aggregateScore": aggregateScore,
      "aggregateMatches": aggregateMatches,
      "nextMatches": nextMatches,
      "pastMatches": pastMatches,
      "averageBirthYear": averageBirthYear,
      "bestScorer": bestScorer,
    };
  }

  factory FootballTeamDetail.fromJson(Map<String, dynamic> json) {
    return FootballTeamDetail(
      tableTeam: TableTeamApiModel.fromJson(json["tableTeam"]),
      aggregateScore: json["aggregateScore"],
      aggregateMatches: json["aggregateMatches"],
      mutualMatches: List<FootballMatchApiModel>.from(
          (json['mutualMatches'] as List<dynamic>)
              .map((match) => FootballMatchApiModel.fromJson(match))),
      nextMatches: List<FootballMatchApiModel>.from(
          (json['nextMatches'] as List<dynamic>)
              .map((match) => FootballMatchApiModel.fromJson(match))),
      pastMatches: List<FootballMatchApiModel>.from(
          (json['pastMatches'] as List<dynamic>)
              .map((match) => FootballMatchApiModel.fromJson(match))),
      bestScorer: json["bestScorer"] != null ? BestScorer.fromJson(
          json["bestScorer"]) : null,
      averageBirthYear: json["averageBirthYear"],
    );
  }

  String bestScorerToString() {
    return bestScorer==null? "" : "${bestScorer!.player.name}, gólů: ${bestScorer!.totalGoals}";
  }

  String averageBirthYearToString() {
    return "$averageBirthYear";
  }

  @override
  String toString() {
    return 'FootballTeamDetail{tableTeam: $tableTeam, mutualMatches: $mutualMatches, nextMatches: $nextMatches, pastMatches: $pastMatches, aggregateScore: $aggregateScore, aggregateMatches: $aggregateMatches, averageBirthYear: $averageBirthYear, bestScorer: $bestScorer}';
  }
}
