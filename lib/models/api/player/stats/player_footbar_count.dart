class PlayerFootbarCount {
  final double totalDistance;

  PlayerFootbarCount({
    required this.totalDistance,
  });

  factory PlayerFootbarCount.fromJson(Map<String, dynamic> json) {
    return PlayerFootbarCount(
      totalDistance: json["totalDistance"],
    );
  }

  String totalDistanceInKmToString() {
    double km = totalDistance/1000;
    return km.toStringAsFixed(2);
  }
}
