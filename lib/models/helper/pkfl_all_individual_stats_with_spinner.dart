import '../api/football/stats/football_all_individual_stats_api_model.dart';
import '../enum/spinner_options.dart';

class FootballAllIndividualStatsWithSpinner {
  final List<FootballAllIndividualStatsApiModel> footballAllIndividualStats;
  final SpinnerOption option;

  FootballAllIndividualStatsWithSpinner({
    required this.footballAllIndividualStats,
    required this.option,
  });
}
