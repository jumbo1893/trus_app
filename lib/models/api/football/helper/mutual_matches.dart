import 'package:trus_app/models/api/football/football_match_api_model.dart';

class MutualMatches {
  final List<FootballMatchApiModel> mutualMatches;
  final String? aggregateScore;
  final String? aggregateMatches;

  MutualMatches({
    required this.mutualMatches,
    required this.aggregateScore,
    required this.aggregateMatches,
  });

}
