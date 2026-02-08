class PlayerBeerCount {
  final int totalBeers;
  final int totalLiquors;

  PlayerBeerCount({
    required this.totalBeers,
    required this.totalLiquors,
  });

  factory PlayerBeerCount.fromJson(Map<String, dynamic> json) {
    return PlayerBeerCount(
      totalBeers: json["totalBeers"],
      totalLiquors: json["totalLiquors"],
    );
  }

}
