class PlayerFineCount {
  final int totalFines;

  PlayerFineCount({
    required this.totalFines,
  });

  factory PlayerFineCount.fromJson(Map<String, dynamic> json) {
    return PlayerFineCount(
      totalFines: json["totalFines"],
    );
  }
}
