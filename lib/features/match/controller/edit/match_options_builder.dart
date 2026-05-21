import 'package:trus_app/models/api/football/detail/football_match_detail.dart';
import 'package:trus_app/models/enum/match_detail_options.dart';

class MatchOptionsBuilder {
  const MatchOptionsBuilder();

  static const List<MatchDetailOptions> order = [
    MatchDetailOptions.editMatch,
    MatchDetailOptions.footballMatchDetail,
    MatchDetailOptions.matchStats,
    MatchDetailOptions.mutualMatches,
  ];

  List<MatchDetailOptions> orderOptions(Iterable<MatchDetailOptions> options) {
    final set = options.toSet();
    return order.where(set.contains).toList();
  }

  List<MatchDetailOptions> fromFootballDetail(
      FootballMatchDetail? detail, {
        required bool includeEditTab,
        required bool includeStatsTab,
      }) {
    final set = <MatchDetailOptions>{};

    if (includeEditTab) {
      set.add(MatchDetailOptions.editMatch);
    }

    if (detail != null) {
      set.add(MatchDetailOptions.footballMatchDetail);

      if (detail.mutualMatches.isNotEmpty) {
        set.add(MatchDetailOptions.mutualMatches);
      }
    }

    if (includeStatsTab) {
      set.add(MatchDetailOptions.matchStats);
    }

    return orderOptions(set);
  }

  List<MatchDetailOptions> mergeOrdered(
      List<MatchDetailOptions> current,
      List<MatchDetailOptions> add,
      ) {
    return orderOptions({...current, ...add});
  }
}