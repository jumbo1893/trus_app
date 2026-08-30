import 'package:trus_app/models/api/participation/match_participation_comment.dart';
import 'package:trus_app/models/api/player/player_api_model.dart';

class MatchParticipationMember {
  final PlayerApiModel player;
  final List<MatchParticipationComment> comments;

  const MatchParticipationMember({
    required this.player,
    required this.comments,
  });

  factory MatchParticipationMember.fromJson(Map<String, dynamic> json) {
    return MatchParticipationMember(
      player: PlayerApiModel.fromJson(json['player']),
      comments: (json['comments'] as List<dynamic>? ?? const [])
          .map((item) => MatchParticipationComment.fromJson(item))
          .toList(),
    );
  }
}
