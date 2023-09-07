import 'package:trus_app/config.dart';
import 'package:trus_app/models/api/player_api_model.dart';

import '../interfaces/add_to_string.dart';
import '../interfaces/model_to_string.dart';
import '../match/match_api_model.dart';

class GoalDetailedModel implements ModelToString {
  int? id;
  final int goalNumber;
  final int assistNumber;
  final PlayerApiModel? player;
  final MatchApiModel? match;

  GoalDetailedModel({
    this.id,
    required this.goalNumber,
    required this.assistNumber,
    this.player,
    this.match
  });

  factory GoalDetailedModel.fromJson(Map<String, dynamic> json) {
    return GoalDetailedModel(
      id: json["id"] ?? 0,
      goalNumber: json["goalNumber"] ?? 0,
      assistNumber: json["assistNumber"] ?? 0,
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
      return match!.listViewTitle();
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
    return "Počet gólů: $goalNumber, počet asistencí: $assistNumber";
  }
}
