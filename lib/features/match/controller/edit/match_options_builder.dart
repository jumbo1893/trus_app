// lib/features/match/controller/match_options_builder.dart
import 'package:trus_app/models/api/football/detail/football_match_detail.dart';
import 'package:trus_app/models/api/football/football_match_api_model.dart';
import 'package:trus_app/models/enum/match_detail_options.dart';

class MatchOptionsBuilder {
  const MatchOptionsBuilder();

  // Fixní pořadí tabů
  static const List<MatchDetailOptions> order = [
    MatchDetailOptions.editMatch,
    MatchDetailOptions.footballMatchDetail,
    MatchDetailOptions.homeMatchDetail,
    MatchDetailOptions.awayMatchDetail,
    MatchDetailOptions.mutualMatches,
  ];

  List<MatchDetailOptions> orderOptions(Iterable<MatchDetailOptions> options) {
    final set = options.toSet();
    return order.where(set.contains).toList();
  }

  List<MatchDetailOptions> fromFootballDetail(
      FootballMatchDetail? d, {
        required bool includeEditTab,
      }) {
    final set = <MatchDetailOptions>{};

    if (includeEditTab) set.add(MatchDetailOptions.editMatch);
    if (d == null) return orderOptions(set);

    set.add(MatchDetailOptions.footballMatchDetail);

    if (d.mutualMatches.isNotEmpty) {
      set.add(MatchDetailOptions.mutualMatches);
    }

    final hasBestHome = d.footballMatch
        .returnSecondDetailsOfMatch(true, StringReturnDetail.bestPlayer)
        .isNotEmpty;
    final hasBestAway = d.footballMatch
        .returnSecondDetailsOfMatch(false, StringReturnDetail.bestPlayer)
        .isNotEmpty;

    if (hasBestHome || hasBestAway) {
      set.add(MatchDetailOptions.homeMatchDetail);
      set.add(MatchDetailOptions.awayMatchDetail);
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
