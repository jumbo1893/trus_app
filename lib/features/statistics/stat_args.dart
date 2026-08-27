import '../season/season_args.dart';

const statisticsSeasonArgs = SeasonArgs(false, true, true);

class StatsArgs {
  final String api;
  final bool matchOrPlayer;

  const StatsArgs(this.api, this.matchOrPlayer);
}
