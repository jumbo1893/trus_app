import 'package:trus_app/models/helper/beer_stats_helper_model.dart';
import 'package:trus_app/models/helper/fine_stats_helper_model.dart';
import 'package:trus_app/models/match_model.dart';

List<BeerStatsHelperModel> sortStatsByDrinks(
    List<BeerStatsHelperModel> beerStats, bool desc) {
  if (desc) {
    beerStats.sort((b, a) => a
        .getNumberOfBeersAndLiquorsInMatches()
        .compareTo(b.getNumberOfBeersAndLiquorsInMatches()));
    return beerStats;
  }
  beerStats.sort((a, b) => a
      .getNumberOfBeersAndLiquorsInMatches()
      .compareTo(b.getNumberOfBeersAndLiquorsInMatches()));
  return beerStats;
}

List<FineStatsHelperModel> sortStatsByFines(
    List<FineStatsHelperModel> fineStats, bool desc) {
  if (desc) {
    fineStats.sort((b, a) => a
        .getAmountOfFinesInMatches()
        .compareTo(b.getAmountOfFinesInMatches()));
    return fineStats;
  }
  fineStats.sort((a, b) => a
      .getAmountOfFinesInMatches()
      .compareTo(b.getAmountOfFinesInMatches()));
  return fineStats;
}

List<MatchModel> sortMatchesByDate(List<MatchModel> matches, bool desc) {
  if (desc) {
    matches.sort((b, a) => a.date.compareTo(b.date));
    return matches;
  } else {
    matches.sort((a, b) => a.date.compareTo(b.date));
  }
  return matches;
}
