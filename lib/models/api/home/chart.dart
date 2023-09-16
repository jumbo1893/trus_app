
import 'coordinate.dart';

class Chart {
  final int fineMaximum;
  final int beerMaximum;
  final List<int> beerLabels;
  final List<int> fineLabels;
  final List<Coordinate> coordinates;


  Chart({
    required this.fineMaximum,
    required this.beerMaximum,
    required this.beerLabels,
    required this.fineLabels,
    required this.coordinates,
  });


  @override
  factory Chart.fromJson(Map<String, dynamic> json) {
    return Chart(
      fineMaximum: json["fineMaximum"] ?? 0,
      beerMaximum: json["beerMaximum"] ?? 0,
      beerLabels: (json['beerLabels'] as List).cast<int>(),
      fineLabels: (json['fineLabels'] as List).cast<int>(),
      coordinates: List<Coordinate>.from((json['coordinates'] as List<dynamic>).map((coordinate) => Coordinate.fromJson(coordinate))),
    );
  }



}
