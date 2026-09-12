import 'package:trus_app/models/api/participation/match_participation_comment.dart';
import 'package:trus_app/models/api/player/player_api_model.dart';

class MatchParticipationMember {
  final PlayerApiModel player;
  final List<MatchParticipationComment> comments;
  final bool? playing;
  final PlayerApiModel? respondedBy;
  final bool canDelete;
  bool get isPlaying => playing ?? !player.fan;

  const MatchParticipationMember({
    required this.player,
    required this.comments,
    this.playing,
    this.respondedBy,
    this.canDelete = false,
  });

  factory MatchParticipationMember.fromJson(Map<String, dynamic> json) {
    return MatchParticipationMember(
      player: PlayerApiModel.fromJson(json['player']),
      playing: json['playing'] as bool?,
      respondedBy: json['respondedBy'] == null
          ? null
          : PlayerApiModel.fromJson(json['respondedBy']),
      canDelete: json['canDelete'] == true,
      comments: (json['comments'] as List<dynamic>? ?? const [])
          .map((item) => MatchParticipationComment.fromJson(item))
          .toList(),
    );
  }
}
