
class Coordinate {
  final String matchInitials;
  final int beerNumber;
  final int liquorNumber;
  final int fineAmount;


  Coordinate({
    required this.matchInitials,
    required this.beerNumber,
    required this.liquorNumber,
    required this.fineAmount,
  });


  @override
  factory Coordinate.fromJson(Map<String, dynamic> json) {
    return Coordinate(
      matchInitials: json["matchInitials"] ?? "",
      beerNumber: json["beerNumber"] ?? 0,
      liquorNumber: json["liquorNumber"] ?? 0,
      fineAmount: json["fineAmount"] ?? 0,
    );
  }

}
