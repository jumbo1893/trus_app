import 'package:trus_app/models/api/participation/match_participation_reaction.dart';
import 'package:trus_app/models/api/player/player_api_model.dart';

class MatchParticipationComment {
  final int id;
  final PlayerApiModel author;
  final String text;
  final DateTime createdAt;
  final int upVotes;
  final int downVotes;
  final MatchParticipationReaction? currentUserReaction;
  final List<MatchParticipationComment> replies;

  const MatchParticipationComment({
    required this.id,
    required this.author,
    required this.text,
    required this.createdAt,
    required this.upVotes,
    required this.downVotes,
    required this.currentUserReaction,
    required this.replies,
  });

  factory MatchParticipationComment.fromJson(Map<String, dynamic> json) {
    return MatchParticipationComment(
      id: json['id'],
      author: PlayerApiModel.fromJson(json['author']),
      text: json['text'] ?? '',
      createdAt: DateTime.parse(json['createdAt']),
      upVotes: json['upVotes'] ?? 0,
      downVotes: json['downVotes'] ?? 0,
      currentUserReaction: MatchParticipationReactionExtension.fromJson(
        json['currentUserReaction'],
      ),
      replies: (json['replies'] as List<dynamic>? ?? const [])
          .map((item) => MatchParticipationComment.fromJson(item))
          .toList(),
    );
  }
}
