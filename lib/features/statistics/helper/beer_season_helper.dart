import 'package:trus_app/models/season_model.dart';

class BeerSeasonHelper {
  int beerNumber;
  int liquorNumber;
  int matchNumber;
  final SeasonModel seasonModel;

  BeerSeasonHelper({required this.seasonModel, this.beerNumber = 0, this.liquorNumber = 0, this.matchNumber = 0});

  void addBeer(int beerNumber) {
    this.beerNumber += beerNumber;
  }

  void addMatch() {
    matchNumber++;
  }

  void addLiquor(int liquorNumber) {
    this.liquorNumber += liquorNumber;
  }

  int getNumberOfDrinks() {
    return beerNumber+liquorNumber;
  }
}