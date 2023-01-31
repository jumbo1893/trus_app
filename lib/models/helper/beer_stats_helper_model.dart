
import '../enum/drink.dart';
import '../beer_model.dart';
import '../fine_model.dart';
import '../match_model.dart';
import '../player_model.dart';

class BeerStatsHelperModel {
  final List<BeerModel> listOfBeers;
  PlayerModel? player;
  MatchModel? match;

  BeerStatsHelperModel(this.listOfBeers, [this.player, this.match]);

  int getNumberOfBeersInMatches() {
    return _returnNumberOfDrinks(Drink.beer);
  }

  int getNumberOfLiquorsInMatches() {
    return _returnNumberOfDrinks(Drink.liquor);
  }

  int getNumberOfBeersAndLiquorsInMatches() {
    return _returnNumberOfDrinks(Drink.both);
  }

  int _returnNumberOfDrinks(Drink drink) {
    int drinks = 0;
    for(BeerModel beerModel in listOfBeers) {
      switch (drink) {
        case Drink.beer:
          drinks+= beerModel.beerNumber;
          break;
        case Drink.liquor:
          drinks+= beerModel.liquorNumber;
          break;
        case Drink.both:
          drinks+= beerModel.beerNumber + beerModel.liquorNumber;
          break;
      }
    }
    return drinks;
  }

  List<String> getMatchIdsFromPickedPlayer() {
    List<String> matchIds = [];
    for (BeerModel beerModel in listOfBeers) {
      matchIds.add(beerModel.matchId);
    }
    return matchIds;
  }

  List<String> getPlayerIdsFromMatchPlayer() {
    List<String> matchIds = [];
    for (BeerModel beerModel in listOfBeers) {
      matchIds.add(beerModel.playerId);
    }
    return matchIds;
  }

}
