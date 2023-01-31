
class PkflMatchPlayer {
  String name;
  int goals;
  int receivedGoals;
  int ownGoals;
  int goalkeepingMinutes;
  int yellowCards;
  int redCards;
  bool bestPlayer;
  bool hattrick;
  bool cleanSheet;
  String yellowCardComment;
  String redCardComment;

  PkflMatchPlayer(
      this.name,
      this.goals,
      this.receivedGoals,
      this.ownGoals,
      this.goalkeepingMinutes,
      this.yellowCards,
      this.redCards,
      this.bestPlayer,
      this.hattrick,
      this.cleanSheet,
      this.yellowCardComment,
      this.redCardComment);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PkflMatchPlayer &&
          runtimeType == other.runtimeType &&
          name == other.name;

  @override
  int get hashCode => name.hashCode;
}