
class FineMultiplePlayerArgs {
  final int matchId;
  final List<int> playerIdList;

  FineMultiplePlayerArgs(this.matchId, this.playerIdList);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FineMultiplePlayerArgs &&
          runtimeType == other.runtimeType &&
          matchId == other.matchId &&
          playerIdList == other.playerIdList;

  @override
  int get hashCode => matchId.hashCode ^ playerIdList.hashCode;
}
