import 'package:trus_app/models/api/match/match_api_model.dart';
import 'package:trus_app/models/api/player/player_api_model.dart';
import 'package:trus_app/models/api/receivedfine/stats/received_fine_stats_detail_models.dart';

import '../season_api_model.dart';

class ReceivedFineSetup {
  final MatchApiModel? match;
  final SeasonApiModel season;
  final List<PlayerApiModel> playersInMatch;
  final List<PlayerApiModel> otherPlayers;
  final List<MatchApiModel> matchList;
  final List<PlayerWithFinesModel> playerFineSummaries;

  ReceivedFineSetup({
    required this.match,
    required this.season,
    required this.playersInMatch,
    required this.otherPlayers,
    required this.matchList,
    required this.playerFineSummaries,
  });

  Map<int, PlayerWithFinesModel> get playerFineSummaryByPlayerId => {
    for (final summary in playerFineSummaries)
      summary.player.id: summary,
  };

  factory ReceivedFineSetup.fromJson(Map<String, dynamic> json) {
    return ReceivedFineSetup(
      match: json["match"] != null
          ? MatchApiModel.fromJson(json["match"])
          : null,
      season: SeasonApiModel.fromJson(json["season"]),
      playersInMatch: (json['playersInMatch'] as List<dynamic>? ?? [])
          .map((player) => PlayerApiModel.fromJson(player))
          .toList(),
      otherPlayers: (json['otherPlayers'] as List<dynamic>? ?? [])
          .map((player) => PlayerApiModel.fromJson(player))
          .toList(),
      matchList: (json['matchList'] as List<dynamic>? ?? [])
          .map((match) => MatchApiModel.fromJson(match))
          .toList(),
      playerFineSummaries:
      (json['playerFineSummaries'] as List<dynamic>? ?? [])
          .map((summary) => PlayerWithFinesModel.fromJson(summary))
          .toList(),
    );
  }

  @override
  String toString() {
    return 'ReceivedFineSetup{'
        'match: $match, '
        'playersInMatch: $playersInMatch, '
        'otherPlayers: $otherPlayers, '
        'playerFineSummaries: $playerFineSummaries'
        '}';
  }
}