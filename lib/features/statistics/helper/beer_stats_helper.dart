import 'package:trus_app/features/statistics/helper/beer_season_helper.dart';
import 'package:trus_app/models/match_model.dart';

import '../../../models/beer_model.dart';
import '../../../models/enum/drink.dart';
import '../../../models/enum/participant.dart';
import '../../../models/helper/beer_stats_helper_model.dart';
import '../../../models/player_model.dart';
import '../../../models/season_model.dart';

class BeerStatsHelper {
  final List<BeerModel> beers;

  BeerStatsHelper(this.beers);

  List<BeerStatsHelperModel> convertBeerModelToBeerStatsHelperModelForPlayers(
      List<PlayerModel> players) {
    final List<BeerStatsHelperModel> beersWithPlayers = [];
    for (PlayerModel player in players) {
      List<BeerModel> listOfBeers = _getListOfBeersByIdForPlayer(player);
      if (listOfBeers.isNotEmpty) {
        beersWithPlayers.add(BeerStatsHelperModel(listOfBeers, player));
      }
    }
    return beersWithPlayers;
  }

  List<BeerModel> _getListOfBeersByIdForPlayer(PlayerModel player) {
    return beers
        .where((element) => (element.playerId == player.id &&
            (element.beerNumber > 0 || element.liquorNumber > 0)))
        .toList();
  }

  List<BeerStatsHelperModel> convertBeerModelToBeerStatsHelperModelForMatches(
      List<MatchModel> matches) {
    final List<BeerStatsHelperModel> beersWithPlayers = [];
    for (MatchModel match in matches) {
      List<BeerModel> listOfBeers = _getListOfBeersByIdForMatch(match);
      if (listOfBeers.isNotEmpty) {
        beersWithPlayers.add(BeerStatsHelperModel(listOfBeers, null, match));
      }
    }
    return beersWithPlayers;
  }

  List<BeerModel> _getListOfBeersByIdForMatch(MatchModel match) {
    return beers
        .where((element) => (element.matchId == match.id &&
            (element.beerNumber > 0 || element.liquorNumber > 0)))
        .toList();
  }

  List<BeerSeasonHelper> getSeasonWithMostBeers(
      List<BeerStatsHelperModel> beersInMatches, List<SeasonModel> seasons, Drink drink) {
    List<BeerSeasonHelper> beerSeasons = [];
    BeerSeasonHelper beerSeasonHelper = BeerSeasonHelper(seasonModel: SeasonModel.otherSeason());
    _addDrinksToBeerSeasonHelper(beerSeasonHelper, beersInMatches);
    beerSeasons.add(beerSeasonHelper);
    for (SeasonModel season in seasons) {
      BeerSeasonHelper beerSeasonHelper = BeerSeasonHelper(seasonModel: season);
      _addDrinksToBeerSeasonHelper(beerSeasonHelper, beersInMatches);
      beerSeasons.add(beerSeasonHelper);
    }
    return _filterSeasonWithMostBeers(beerSeasons, drink);
  }

  void _addDrinksToBeerSeasonHelper(
      BeerSeasonHelper beerSeason, List<BeerStatsHelperModel> beersInMatches) {
    for (BeerStatsHelperModel beer in beersInMatches) {
      if (beer.match!.seasonId == beerSeason.seasonModel.id) {
        beerSeason.addBeer(beer.getNumberOfDrinksInMatches(
            Drink.beer, Participant.both, null));
        beerSeason.addLiquor(beer.getNumberOfDrinksInMatches(
            Drink.liquor, Participant.both, null));
        beerSeason.addMatch();
      }
    }
  }

  List<BeerSeasonHelper> _filterSeasonWithMostBeers(
      List<BeerSeasonHelper> beerSeasons, Drink drink) {
    List<BeerSeasonHelper> mostBeerSeasons = [];
    for (BeerSeasonHelper beerSeason in beerSeasons) {
      if (mostBeerSeasons.isEmpty) {
        mostBeerSeasons.add(beerSeason);
      } else if ((beerSeason.beerNumber > mostBeerSeasons[0].beerNumber && drink == Drink.beer) || (beerSeason.liquorNumber > mostBeerSeasons[0].liquorNumber && drink == Drink.liquor)) {
        mostBeerSeasons.clear();
        mostBeerSeasons.add(beerSeason);
      } else if ((beerSeason.beerNumber == mostBeerSeasons[0].beerNumber && drink == Drink.beer) || (beerSeason.liquorNumber == mostBeerSeasons[0].liquorNumber && drink == Drink.liquor)) {
        mostBeerSeasons.add(beerSeason);
      }
    }
    return mostBeerSeasons;
  }

  ///dodáme parametr playerBeers obohacený bud o zápasy či o hráče. Sezona se může používat jenom pro obohacené beerStats o zápasy, jinak vyplňujeme null. Pokud nechceme piva dle sezony vyplňujeme null
  List<BeerStatsHelperModel> getBeerStatsHelperModelsWithMostBeers(
      List<BeerStatsHelperModel> playerBeers, String? seasonId, Drink drink) {
    List<BeerStatsHelperModel> returnBeers = [];
    for (BeerStatsHelperModel beer in playerBeers) {
      if (seasonId == null || beer.match!.seasonId == seasonId) {
        if (returnBeers.isEmpty) {
          returnBeers.add(beer);
        } else if (beer.getNumberOfDrinksInMatches(
            drink, Participant.both, null) >
            returnBeers[0].getNumberOfDrinksInMatches(
                drink, Participant.both, null)) {
          returnBeers.clear();
          returnBeers.add(beer);
        } else if (beer.getNumberOfDrinksInMatches(
            drink, Participant.both, null) ==
            returnBeers[0].getNumberOfDrinksInMatches(
                drink, Participant.both, null)) {
          returnBeers.add(beer);
        }
      }
    }
    return returnBeers;
  }

  ///dodáme parametr playerBeers obohacený bud o zápasy či o hráče. Sezona se může používat jenom pro obohacené beerStats o zápasy, jinak vyplňujeme null. Pokud nechceme piva dle sezony vyplňujeme null
  List<BeerStatsHelperModel> getMatchWithHighestAverageBeers(
      List<BeerStatsHelperModel> playerBeers,
      String? seasonId,
      bool highest,
      Drink drink) {
    List<BeerStatsHelperModel> returnBeers = [];
    double average = 0;
    for (BeerStatsHelperModel beer in playerBeers) {
      if (seasonId == null || beer.match!.seasonId == seasonId) {
        if(beer.getNumberOfDrinksInMatches(drink, Participant.both, null) > 0) {
          if (returnBeers.isEmpty) {
            returnBeers.add(beer);
            average =
                beer.getNumberOfDrinksInMatches(drink, Participant.both, null) /
                    beer.getNumberOfPlayersInMatch(Participant.both, null);
          } else if ((highest && beer.getNumberOfDrinksInMatches(
              drink, Participant.both, null) /
              beer.getNumberOfPlayersInMatch(Participant.both, null) >
              average) || !highest && beer.getNumberOfDrinksInMatches(
              drink, Participant.both, null) /
              beer.getNumberOfPlayersInMatch(Participant.both, null) <
              average) {
            average =
                beer.getNumberOfDrinksInMatches(drink, Participant.both, null) /
                    beer.getNumberOfPlayersInMatch(Participant.both, null);
            returnBeers.clear();
            returnBeers.add(beer);
          } else if (beer.getNumberOfDrinksInMatches(
              drink, Participant.both, null) /
              beer.getNumberOfPlayersInMatch(Participant.both, null) ==
              average) {
            returnBeers.add(beer);
          }
        }
      }
    }
    return returnBeers;
  }

  ///velikost listu playerIdList a matchIdList musí být stejná!!! na každý zápas jeden player
  List<BeerModel> getNumberOfBeersInMatchForPlayer(List<PlayerModel> playerIdList, List<MatchModel> matchIdList, List<BeerModel> beerModelList) {
    List<BeerModel> returnBeers = [];
    outerLoop:
    for (int i = 0; i < playerIdList.length; i++) {
      bool found = false;
      innerLopp: for (BeerModel beerModel in beerModelList) {
        if (beerModel.matchId == matchIdList[i].id && beerModel.playerId == playerIdList[i].id) {
          returnBeers.add(beerModel);
          found = true;
          break innerLopp;
        }
      }
      if(!found) {
        returnBeers.add(BeerModel.dummy());
      }
    }
    return returnBeers;
  }
}
