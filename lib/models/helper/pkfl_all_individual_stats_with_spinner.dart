import '../api/pkfl/pkfl_all_individual_stats.dart';
import '../enum/spinner_options.dart';

class PkflAllIndividualStatsWithSpinner {
  final List<PkflAllIndividualStats> pkflAllIndividualStats;
  final SpinnerOption option;

  PkflAllIndividualStatsWithSpinner({
    required this.pkflAllIndividualStats,
    required this.option,
  });
}
