import 'beer_no_match.dart';

class BeerList {
  final int matchId;
  final List<BeerNoMatch> beerList;

  BeerList({
    required this.matchId,
    required this.beerList,
  });

  Map<String, dynamic> toJson() {
    return {
      "matchId": matchId,
      "beerList": beerList,
    };
  }
}
