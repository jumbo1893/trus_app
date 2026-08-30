import 'package:trus_app/models/api/football/football_match_api_model.dart';
import 'package:trus_app/models/api/participation/match_participation_status.dart';
import 'package:trus_app/models/api/player/player_api_model.dart';

class MatchParticipationPrompt {
  final FootballMatchApiModel footballMatch;
  final PlayerApiModel? currentPlayer;
  final MatchParticipationStatus? currentStatus;
  final bool reconsideration;
  final List<PlayerApiModel> eligiblePlayers;

  const MatchParticipationPrompt({
    required this.footballMatch,
    required this.currentPlayer,
    required this.currentStatus,
    required this.reconsideration,
    required this.eligiblePlayers,
  });

  factory MatchParticipationPrompt.fromJson(Map<String, dynamic> json) {
    return MatchParticipationPrompt(
      footballMatch: FootballMatchApiModel.fromJson(json['footballMatch']),
      currentPlayer: json['currentPlayer'] != null
          ? PlayerApiModel.fromJson(json['currentPlayer'])
          : null,
      currentStatus: MatchParticipationStatusExtension.fromJson(
        json['currentStatus'],
      ),
      reconsideration: json['reconsideration'] ?? false,
      eligiblePlayers: (json['eligiblePlayers'] as List<dynamic>? ?? const [])
          .map((item) => PlayerApiModel.fromJson(item))
          .toList(),
    );
  }
}
