import 'package:trus_app/models/api/footbar/footbar_session.dart';
import 'package:trus_app/models/api/match/match_api_model.dart';
import 'package:trus_app/models/api/player/player_api_model.dart';

class FootbarAccountSessions {
  final MatchApiModel match;
  final List<PlayerApiModel> players;
  final PlayerApiModel primaryPlayer;
  final PlayerApiModel secondaryPlayer;
  final List<FootbarSession> sessions;

  FootbarAccountSessions({
    required this.match,
    required this.players,
    required this.primaryPlayer,
    required this.secondaryPlayer,
    required this.sessions,
  });

  factory FootbarAccountSessions.fromJson(Map<String, dynamic> json) {
    return FootbarAccountSessions(
      match: MatchApiModel.fromJson(json["match"]),
      primaryPlayer: PlayerApiModel.fromJson(json["primaryPlayer"]),
      secondaryPlayer: PlayerApiModel.fromJson(json["secondaryPlayer"]),
      players: (json['players'] as List<dynamic>)
          .map((a) => PlayerApiModel.fromJson(a))
          .toList(),
      sessions: (json['sessions'] as List<dynamic>)
          .map((a) => FootbarSession.fromJson(a))
          .toList(),
    );
  }
}
