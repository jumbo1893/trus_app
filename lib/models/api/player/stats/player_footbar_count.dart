class PlayerFootbarCount {
  final int totalDistance;

  PlayerFootbarCount({
    required this.totalDistance,
  });

  factory PlayerFootbarCount.fromJson(Map<String, dynamic> json) {
    return PlayerFootbarCount(
      totalDistance: json["totalDistance"],
    );
  }
}
