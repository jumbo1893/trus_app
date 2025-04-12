
import '../player/player_api_model.dart';
import 'coordinate.dart';

class Chart {
  final int fineMaximum;
  final int beerMaximum;
  final List<int> beerLabels;
  final List<int> fineLabels;
  final List<Coordinate> coordinates;
  final PlayerApiModel player;
  final bool mainPlayer;


  Chart({
    required this.fineMaximum,
    required this.beerMaximum,
    required this.beerLabels,
    required this.fineLabels,
    required this.coordinates,
    required this.player,
    required this.mainPlayer,
  });

  Chart.dummy()
      : fineMaximum = 0,
        beerMaximum = 0,
        beerLabels = [],
        mainPlayer = false,
        fineLabels = [],
        coordinates = [],
        player = PlayerApiModel.dummy();


  @override
  factory Chart.fromJson(Map<String, dynamic> json) {
    return Chart(
      fineMaximum: json["fineMaximum"] ?? 0,
      beerMaximum: json["beerMaximum"] ?? 0,
      beerLabels: (json['beerLabels'] as List).cast<int>(),
      fineLabels: (json['fineLabels'] as List).cast<int>(),
      coordinates: List<Coordinate>.from((json['coordinates'] as List<dynamic>).map((coordinate) => Coordinate.fromJson(coordinate))),
      player: PlayerApiModel.fromJson(json["player"]),
      mainPlayer: json["mainPlayer"] ?? false,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Chart &&
          runtimeType == other.runtimeType &&
          player == other.player;

  @override
  int get hashCode => player.hashCode;
}
