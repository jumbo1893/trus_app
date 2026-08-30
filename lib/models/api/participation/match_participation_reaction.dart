enum MatchParticipationReaction { up, down }

extension MatchParticipationReactionExtension on MatchParticipationReaction {
  String toJson() => switch (this) {
    MatchParticipationReaction.up => 'UP',
    MatchParticipationReaction.down => 'DOWN',
  };

  static MatchParticipationReaction? fromJson(dynamic value) => switch (value) {
    'UP' => MatchParticipationReaction.up,
    'DOWN' => MatchParticipationReaction.down,
    _ => null,
  };
}
