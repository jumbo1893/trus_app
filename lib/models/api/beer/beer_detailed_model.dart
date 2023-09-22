import 'package:trus_app/models/api/player_api_model.dart';

import '../../../common/utils/calendar.dart';
import '../interfaces/model_to_string.dart';
import '../match/match_api_model.dart';

class BeerDetailedModel implements ModelToString {
  int? id;
  final int beerNumber;
  final int liquorNumber;
  final PlayerApiModel? player;
  final MatchApiModel? match;

  BeerDetailedModel({
    this.id,
    required this.beerNumber,
    required this.liquorNumber,
    this.player,
    this.match
  });

  factory BeerDetailedModel.fromJson(Map<String, dynamic> json) {
    return BeerDetailedModel(
      id: json["id"] ?? 0,
      beerNumber: json["beerNumber"] ?? 0,
      liquorNumber: json["liquorNumber"] ?? 0,
      player: json["player"] != null ? PlayerApiModel.fromJson(json["player"]) : null,
      match: json["match"] != null ? MatchApiModel.fromJson(json["match"]) : null,
    );
  }

  @override
  int getId() {
    return id?? -1;
  }

  @override
  String listViewTitle() {
    if(match != null) {
      return "${match!.listViewTitle()}, ${dateTimeToString(match!.date)}";
    }
    else if (player != null) {
      return player!.listViewTitle();
    }
    else {
      return "neznámý hráč či zápas";
    }
  }

  @override
  String toStringForAdd() {
    return "";
  }

  @override
  String toStringForConfirmationDelete() {
    return "";
  }

  @override
  String toStringForEdit(String originName) {
    return "";
  }

  @override
  String toStringForListView() {
    return "Počet piv: $beerNumber, počet panáků: $liquorNumber, celkem: ${beerNumber+liquorNumber} ";
  }
}
