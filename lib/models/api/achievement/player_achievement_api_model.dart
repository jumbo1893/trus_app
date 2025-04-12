import 'package:trus_app/config.dart';
import 'package:trus_app/models/api/achievement/achievement_api_model.dart';
import 'package:trus_app/models/api/football/football_match_api_model.dart';
import 'package:trus_app/models/api/interfaces/json_and_http_converter.dart';
import 'package:trus_app/models/api/interfaces/model_to_string.dart';
import 'package:trus_app/models/api/match/match_api_model.dart';
import 'package:trus_app/models/api/player/player_api_model.dart';


class PlayerAchievementApiModel implements ModelToString, JsonAndHttpConverter {
  final int id;
  final AchievementApiModel achievement;
  final PlayerApiModel player;
  MatchApiModel? match;
  FootballMatchApiModel? footballMatch;
  String? detail;
  bool? accomplished;

  PlayerAchievementApiModel({
    required this.id,
    required this.achievement,
    required this.player,
    this.match,
    this.footballMatch,
    this.detail,
    this.accomplished
  });

  PlayerAchievementApiModel.dummy()
      : id = 0,
        achievement = AchievementApiModel.dummy(),
        player = PlayerApiModel.dummy();

  String get getMatchDetail {
    if(match != null) {
      return match!.listViewTitle();
    }
    if(footballMatch != null) {
      return footballMatch!.toStringWithTeamsDateAndResult();
    }
    return "-";
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "achievement": achievement,
      "player": player,
      "match": match,
      "footballMatch": footballMatch,
      "detail": detail,
      "accomplished": accomplished,
    };
  }

  @override
  factory PlayerAchievementApiModel.fromJson(Map<String, dynamic> json) {
    return PlayerAchievementApiModel(
      player: PlayerApiModel.fromJson(json["player"]),
      achievement: AchievementApiModel.fromJson(json["achievement"]),
      id: json["id"] ?? 0,
      match: json["match"] != null ? MatchApiModel.fromJson(json["match"]) : null,
      footballMatch: json["footballMatch"] != null ? FootballMatchApiModel.fromJson(json["footballMatch"]) : null,
      detail: json['detail'] ?? "",
      accomplished: json["accomplished"] ?? false,
    );
  }

  get isAccomplished {
    if(accomplished==null || !accomplished!) {
      return false;
    }
    return true;
  }

  void changeAccomplished() {
    if(!isAccomplished) {
      accomplished = true;
    }
    else {
      accomplished = false;
    }
  }

  String getAccomplishedToString(bool reverse) {
    if(!isAccomplished) {
      return reverse? "splněno" : "nesplněno";
    }
    else {
      return reverse? "nesplněno" : "splněno";
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlayerAchievementApiModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toStringForListView() {
    return achievement.name;
  }

  @override
  String listViewTitle() {
    return detail ?? "";
  }

  @override
  String toStringForAdd() {
    return "";
  }

  @override
  String toStringForConfirmationDelete() {
    return "Opravdu chcete ${achievement.name} změnit na ${getAccomplishedToString(true)}?";
  }

  @override
  String toStringForEdit(String originName) {
    return "achievement ${achievement.name} změněn na ${getAccomplishedToString(false)}";
  }

  @override
  String httpRequestClass() {
    return playerAchievementApi;
  }

  @override
  int getId() {
    return id;
  }
}
