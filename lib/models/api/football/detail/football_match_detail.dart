import 'package:trus_app/models/api/football/detail/best_scorer.dart';
import 'package:trus_app/models/api/football/football_match_api_model.dart';

class FootballMatchDetail {
  final FootballMatchApiModel footballMatch;
  final List<FootballMatchApiModel> mutualMatches;
  String? aggregateScore;
  String? aggregateMatches;
  final int homeTeamAverageBirthYear;
  final int awayTeamAverageBirthYear;
  BestScorer? homeTeamBestScorer;
  BestScorer? awayTeamBestScorer;

  FootballMatchDetail({
    required this.footballMatch,
    required this.mutualMatches,
    this.aggregateScore,
    this.aggregateMatches,
    required this.homeTeamAverageBirthYear,
    required this.awayTeamAverageBirthYear,
    required this.homeTeamBestScorer,
    required this.awayTeamBestScorer,
  });

  FootballMatchDetail.dummy()
      : footballMatch = FootballMatchApiModel.noMatch(),
        mutualMatches = [],
        homeTeamAverageBirthYear = 0,
        awayTeamAverageBirthYear = 0;

  Map<String, dynamic> toJson() {
    return {
      "footballMatch": footballMatch,
      "mutualMatches": mutualMatches,
      "aggregateScore": aggregateScore,
      "aggregateMatches": aggregateMatches,
      "homeTeamAverageBirthYear": homeTeamAverageBirthYear,
      "awayTeamAverageBirthYear": awayTeamAverageBirthYear,
      "homeTeamBestScorer": homeTeamBestScorer,
      "awayTeamBestScorer": awayTeamBestScorer,
    };
  }

  factory FootballMatchDetail.fromJson(Map<String, dynamic> json) {
    return FootballMatchDetail(
      footballMatch: FootballMatchApiModel.fromJson(json["footballMatch"]),
      aggregateScore: json["aggregateScore"],
      aggregateMatches: json["aggregateMatches"],
      mutualMatches: List<FootballMatchApiModel>.from(
          (json['mutualMatches'] as List<dynamic>)
              .map((match) => FootballMatchApiModel.fromJson(match))),
      homeTeamAverageBirthYear: json["homeTeamAverageBirthYear"],
      awayTeamAverageBirthYear: json["awayTeamAverageBirthYear"],
      homeTeamBestScorer: json["homeTeamBestScorer"] != null ? BestScorer.fromJson(
          json["homeTeamBestScorer"]) : null,
      awayTeamBestScorer: json["awayTeamBestScorer"] != null ? BestScorer.fromJson(
          json["awayTeamBestScorer"]) : null,
    );
  }

  @override
  String toString() {
    return 'FootballMachDetail{footballMatch: $footballMatch, commonMatches: $mutualMatches, aggregateScore: $aggregateScore, aggregateMatches: $aggregateMatches}';
  }
}
