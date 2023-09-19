import 'beer_detailed_model.dart';

class BeerDetailedResponse {
  final int playersCount;
  final int matchesCount;
  final int totalBeers;
  final int totalLiquors;
  final List<BeerDetailedModel> beerList;

  BeerDetailedResponse({
    required this.playersCount,
    required this.matchesCount,
    required this.totalBeers,
    required this.totalLiquors,
    required this.beerList,
  });

  factory BeerDetailedResponse.fromJson(Map<String, dynamic> json) {
    return BeerDetailedResponse(
      playersCount: json["playersCount"] ?? 0,
      matchesCount: json["matchesCount"] ?? 0,
      totalBeers: json["totalBeers"] ?? 0,
      totalLiquors: json["totalLiquors"] ?? 0,
      beerList: List<BeerDetailedModel>.from((json['beerList'] as List<dynamic>).map((match) => BeerDetailedModel.fromJson(match))),
    );
  }

  String overallStatsToString() {
    return "$totalBeers piv a $totalLiquors panáků v $playersCount hráčích a $matchesCount zápasech";
  }

  @override
  String toString() {
    return 'BeerDetailedResponse{playersCount: $playersCount, matchesCount: $matchesCount, totalBeers: $totalBeers, totalLiquors: $totalLiquors, beerList: $beerList}';
  }
}
