
import '../enum/drink.dart';
import '../beer_model.dart';
import '../enum/participant.dart';
import '../match_model.dart';
import '../player_model.dart';

class BeerStatsHelperModel {
  final List<BeerModel> listOfBeers;
  PlayerModel? player;
  MatchModel? match;

  BeerStatsHelperModel(this.listOfBeers, [this.player, this.match]);

  int getNumberOfDrinksInMatches(Drink drink, Participant participant, List<PlayerModel>? players) {
    return _returnNumberOfDrinks(drink, participant, players);
  }

  ///parametr players povinný, pokud není participant=both
  int _returnNumberOfDrinks(Drink drink, Participant participant, List<PlayerModel>? players) {
    int drinks = 0;
    for(BeerModel beerModel in listOfBeers) {
      if(participant == Participant.both || (_isPlayer(players!, beerModel.playerId) && participant == Participant.player) || (!_isPlayer(players, beerModel.playerId) && participant == Participant.fan)) {
        switch (drink) {
          case Drink.beer:
            drinks += beerModel.beerNumber;
            break;
          case Drink.liquor:
            drinks += beerModel.liquorNumber;
            break;
          case Drink.both:
            drinks += beerModel.beerNumber + beerModel.liquorNumber;
            break;
        }
      }
    }
    return drinks;
  }

  ///parametr players povinný, pokud není participant=both
  int getNumberOfPlayersInMatch(Participant participant, List<PlayerModel>? players) {
    int number = 0;
    for(String id in match!.playerIdList) {

      if(participant == Participant.both || (_isPlayer(players!, id) && participant == Participant.player) || (!_isPlayer(players, id) && participant == Participant.fan)) {
        number++;
      }
    }
    return number;
  }

  bool isPlayerInPlayerList(String id, List<PlayerModel> players) {
    List<String> playerIds = [];
    for (PlayerModel player in players) {
      playerIds.add(player.id);
    }

    return playerIds.contains(id);
  }

  bool _isPlayer(List<PlayerModel> players, String playerId) {
    
    return !players
        .firstWhere((element) => (element.id == playerId))
        .fan;
  }

  List<String> getMatchIdsFromPickedPlayer() {
    List<String> matchIds = [];
    for (BeerModel beerModel in listOfBeers) {
      matchIds.add(beerModel.matchId);
    }
    return matchIds;
  }

  List<String> getPlayerIdsFromMatchPlayer() {
    List<String> playerIds = [];
    for (BeerModel beerModel in listOfBeers) {
      playerIds.add(beerModel.playerId);
    }
    return playerIds;
  }

}
