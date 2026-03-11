
class FinePlayerArgs {
  final int matchId;
  final int playerId;

  FinePlayerArgs(this.matchId, this.playerId);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FinePlayerArgs &&
          runtimeType == other.runtimeType &&
          matchId == other.matchId &&
          playerId == other.playerId;

  @override
  int get hashCode => matchId.hashCode ^ playerId.hashCode;
}
