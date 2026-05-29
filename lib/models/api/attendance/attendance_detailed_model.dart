import 'package:trus_app/models/api/interfaces/model_to_string.dart';
import 'package:trus_app/models/api/match/match_api_model.dart';
import 'package:trus_app/models/api/player/player_api_model.dart';

class AttendanceDetailedModel implements ModelToString {
  final int id;
  final int attendanceCount;
  final int playerCount;
  final int fanCount;
  final int totalCount;
  final PlayerApiModel? player;
  final MatchApiModel? match;

  AttendanceDetailedModel({
    required this.id,
    required this.attendanceCount,
    required this.playerCount,
    required this.fanCount,
    required this.totalCount,
    this.player,
    this.match,
  });

  factory AttendanceDetailedModel.fromJson(Map<String, dynamic> json) {
    return AttendanceDetailedModel(
      id: json["id"] ?? 0,
      attendanceCount: json["attendanceCount"] ?? 0,
      playerCount: json["playerCount"] ?? 0,
      fanCount: json["fanCount"] ?? 0,
      totalCount: json["totalCount"] ?? 0,
      player: json["player"] != null
          ? PlayerApiModel.fromJson(json["player"])
          : null,
      match: json["match"] != null
          ? MatchApiModel.fromJson(json["match"])
          : null,
    );
  }

  @override
  int getId() => id;

  @override
  String listViewTitle() {
    if (player != null) {
      return player!.listViewTitle();
    }

    if (match != null) {
      return match!.listViewTitle();
    }

    return "Neznámá účast";
  }

  @override
  String toStringForListView() {
    if (match != null && player == null && totalCount > 0) {
      return "Hráči: $playerCount, fanoušci: $fanCount, celkem: $totalCount";
    }

    if (player != null && match == null) {
      return "Počet zápasů: $attendanceCount";
    }

    if (player != null) {
      return player!.fan ? "Fanoušek" : "Hráč";
    }

    if (match != null) {
      return "Účast v zápase";
    }

    return "";
  }

  @override
  String toStringForAdd() => "";

  @override
  String toStringForConfirmationDelete() => "";

  @override
  String toStringForEdit(String originName) => "";
}