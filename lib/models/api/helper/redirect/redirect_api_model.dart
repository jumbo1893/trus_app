import 'package:trus_app/models/api/football/football_match_api_model.dart';
import 'package:trus_app/models/api/helper/redirect/redirect.dart';
import 'package:trus_app/models/api/match/match_api_model.dart';
import 'package:trus_app/models/api/player/player_api_model.dart';
import 'package:trus_app/models/api/season_api_model.dart';

class RedirectApiModel {
  final Redirect? redirect;
  final SeasonApiModel? season;
  final PlayerApiModel? player;
  final FootballMatchApiModel? footballMatch;
  final MatchApiModel? match;

  RedirectApiModel({
    this.redirect,
    this.season,
    this.player,
    this.footballMatch,
    this.match,
  });

  factory RedirectApiModel.fromJson(Map<String, dynamic> json) {
    return RedirectApiModel(
      redirect: RedirectExtension.fromJson(json["redirect"]),
      season: json["season"] != null ? SeasonApiModel.fromJson(json["season"]) : null,
      player: json["player"] != null ? PlayerApiModel.fromJson(json["player"]) : null,
      footballMatch: json["footballMatch"] != null
          ? FootballMatchApiModel.fromJson(json["footballMatch"])
          : null,
      match: json["match"] != null ? MatchApiModel.fromJson(json["match"]) : null,
    );
  }
}