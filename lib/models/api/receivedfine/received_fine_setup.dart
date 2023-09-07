import 'package:age_calculator/age_calculator.dart';
import 'package:trus_app/common/utils/calendar.dart';
import 'package:trus_app/config.dart';
import 'package:trus_app/models/api/interfaces/json_and_http_converter.dart';
import 'package:trus_app/models/api/interfaces/model_to_string.dart';
import 'package:trus_app/models/api/match/match_api_model.dart';
import 'package:trus_app/models/api/player_api_model.dart';

import '../interfaces/add_to_string.dart';
import '../season_api_model.dart';

class ReceivedFineSetup {
  final MatchApiModel? match;
  final SeasonApiModel season;
  final List<PlayerApiModel> playersInMatch;
  final List<PlayerApiModel> otherPlayers;
  final List<MatchApiModel> matchList;

  ReceivedFineSetup({
    required this.match,
    required this.season,
    required this.playersInMatch,
    required this.otherPlayers,
    required this.matchList,
  });

  @override
  factory ReceivedFineSetup.fromJson(Map<String, dynamic> json) {
    return ReceivedFineSetup(
      match: json["match"] != null ? MatchApiModel.fromJson(json["match"]) : null,
      season: SeasonApiModel.fromJson(json["season"]),
      playersInMatch: List<PlayerApiModel>.from((json['playersInMatch'] as List<dynamic>).map((player) => PlayerApiModel.fromJson(player))),
      otherPlayers: List<PlayerApiModel>.from((json['otherPlayers'] as List<dynamic>).map((player) => PlayerApiModel.fromJson(player))),
      matchList: List<MatchApiModel>.from((json['matchList'] as List<dynamic>).map((match) => MatchApiModel.fromJson(match))),
    );
  }

  @override
  String toString() {
    return 'ReceivedFineSetup{match: $match, playersInMatch: $playersInMatch, otherPlayers: $otherPlayers}';
  }
}