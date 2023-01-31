
import '../fine_model.dart';
import '../player_model.dart';

class BeerHelperModel {
  final String id;
  int beerNumber;
  int liquorNumber;
  final PlayerModel player;

  BeerHelperModel({
    required this.id,
    required this.player,
    required this.beerNumber,
    required this.liquorNumber,
  });

  void addBeerNumber() {
    beerNumber++;
  }

  void removeBeerNumber() {
    if(beerNumber > 0) {
      beerNumber--;
    }
  }

  void addLiquorNumber() {
    liquorNumber++;
  }

  void removeLiquorNumber() {
    if(liquorNumber > 0) {
      liquorNumber--;
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is BeerHelperModel &&
              runtimeType == other.runtimeType &&
              id == other.id;

  @override
  int get hashCode => id.hashCode;

//

}
