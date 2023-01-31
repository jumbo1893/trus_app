
class PkflMatchPlayer {
  final String name;
  final int goals;
  final int receivedGoals;
  final int ownGoals;
  final int goalkeepingMinutes;
  final int yellowCards;
  final int redCards;
  final bool bestPlayer;
  String? yellowCardComment;
  String? redCardComment;

  PkflMatchPlayer(
      this.name,
      this.goals,
      this.receivedGoals,
      this.ownGoals,
      this.goalkeepingMinutes,
      this.yellowCards,
      this.redCards,
      this.bestPlayer,
       {
         this.yellowCardComment,
         this.redCardComment
});

  bool hattrick() {
    return goals > 2;
  }

  bool cleanSheet() {
    return receivedGoals == 0 && goalkeepingMinutes > 0;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PkflMatchPlayer &&
          runtimeType == other.runtimeType &&
          name == other.name;

  @override
  int get hashCode => name.hashCode;
}