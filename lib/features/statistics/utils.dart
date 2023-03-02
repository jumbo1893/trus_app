import 'package:trus_app/models/helper/beer_stats_helper_model.dart';
import 'package:trus_app/models/helper/fine_stats_helper_model.dart';
import 'package:trus_app/models/helper/player_stats_helper_model.dart';
import 'package:trus_app/models/match_model.dart';

import '../../models/enum/drink.dart';
import '../../models/enum/fine.dart';
import '../../models/enum/participant.dart';

List<BeerStatsHelperModel> sortStatsByDrinks(
    List<BeerStatsHelperModel> beerStats, bool desc) {
  if (desc) {
    beerStats.sort((b, a) => a
        .getNumberOfDrinksInMatches(Drink.both, Participant.both, null)
        .compareTo(b.getNumberOfDrinksInMatches(Drink.both, Participant.both, null)));
    return beerStats;
  }
  beerStats.sort((a, b) => a
      .getNumberOfDrinksInMatches(Drink.both, Participant.both, null)
      .compareTo(b.getNumberOfDrinksInMatches(Drink.both, Participant.both, null)));
  return beerStats;
}

List<FineStatsHelperModel> sortStatsByFines(
    List<FineStatsHelperModel> fineStats, bool desc) {
  if (desc) {
    fineStats.sort((b, a) => a
        .getNumberOrAmountOfFines(Fine.amount)
        .compareTo(b.getNumberOrAmountOfFines(Fine.amount)));
    return fineStats;
  }
  fineStats.sort((a, b) => a
      .getNumberOrAmountOfFines(Fine.amount)
      .compareTo(b.getNumberOrAmountOfFines(Fine.amount)));
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

List<PlayerStatsHelperModel> sortByGoalsOrAssists(List<PlayerStatsHelperModel> players, bool desc, bool goal) {
  if (goal) {
    if (desc) {
      players.sort((b, a) => a.goalNumber.compareTo(b.goalNumber));
      return players;
    } else {
      players.sort((a, b) => a.goalNumber.compareTo(b.goalNumber));
    }
    return players;
  }
  if (desc) {
    players.sort((b, a) => a.assistNumber.compareTo(b.assistNumber));
    return players;
  } else {
    players.sort((a, b) => a.assistNumber.compareTo(b.assistNumber));
  }
  return players;
}
