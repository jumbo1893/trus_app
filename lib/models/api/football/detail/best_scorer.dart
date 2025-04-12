import 'package:trus_app/models/api/football/football_player_api_model.dart';
import 'package:trus_app/models/api/football/league_api_model.dart';
import 'package:trus_app/models/api/football/team_api_model.dart';

class BestScorer {
  final FootballPlayerApiModel player;
  int? totalGoals;
  final TeamApiModel team;
  final LeagueApiModel league;

  BestScorer({
    required this.player,
    this.totalGoals,
    required this.team,
    required this.league,
  });

  factory BestScorer.fromJson(Map<String, dynamic> json) {
    return BestScorer(
      player: FootballPlayerApiModel.fromJson(json["player"]),
      team: TeamApiModel.fromJson(json["team"]),
      league: LeagueApiModel.fromJson(json["league"]),
      totalGoals: json["totalGoals"] ?? 0,
    );
  }

  @override
  String toString() {
    return "${player.name} ($totalGoals)";
  }
}
