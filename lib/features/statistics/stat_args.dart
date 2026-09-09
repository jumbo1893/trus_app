import 'package:flutter/foundation.dart';
import '../season/season_args.dart';

const statisticsSeasonArgs = SeasonArgs(false, true, true, playedOnly: true);

class StatsArgs {
  final String api;
  final bool matchOrPlayer;
  final Set<int> seasonIds;
  final Set<int> fineIds;

  const StatsArgs(
    this.api,
    this.matchOrPlayer, {
    this.seasonIds = const {},
    this.fineIds = const {},
  });

  @override
  bool operator ==(Object other) =>
      other is StatsArgs &&
      api == other.api &&
      matchOrPlayer == other.matchOrPlayer &&
      setEquals(seasonIds, other.seasonIds) &&
      setEquals(fineIds, other.fineIds);

  @override
  int get hashCode => Object.hash(
    api,
    matchOrPlayer,
    Object.hashAllUnordered(seasonIds),
    Object.hashAllUnordered(fineIds),
  );
}
