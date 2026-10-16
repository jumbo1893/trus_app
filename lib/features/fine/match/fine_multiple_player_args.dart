import 'package:flutter/foundation.dart';

class FineMultiplePlayerArgs {
  final int matchId;
  final List<int> playerIdList;

  FineMultiplePlayerArgs(this.matchId, List<int> playerIdList)
      : playerIdList = List.unmodifiable(playerIdList.toSet().toList()..sort());

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FineMultiplePlayerArgs &&
          runtimeType == other.runtimeType &&
          matchId == other.matchId &&
          listEquals(playerIdList, other.playerIdList);

  @override
  int get hashCode => Object.hash(matchId, Object.hashAll(playerIdList));
}
