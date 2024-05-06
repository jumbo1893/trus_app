import 'package:trus_app/common/utils/calendar.dart';
import 'package:trus_app/config.dart';
import 'package:trus_app/models/api/interfaces/json_and_http_converter.dart';
import 'package:trus_app/models/api/interfaces/model_to_string.dart';
import 'package:trus_app/models/api/player_api_model.dart';

import '../pkfl/pkfl_match_api_model.dart';

class MatchApiModel implements ModelToString, JsonAndHttpConverter {
  int? id;
  final String name;
  final DateTime date;
  final int seasonId;
  final bool home;
  final List<int> playerIdList;
  PkflMatchApiModel? pkflMatch;

  MatchApiModel({
    required this.name,
    required this.date,
    required this.seasonId,
    required this.home,
    required this.playerIdList,
    this.id,
    this.pkflMatch
  });

  MatchApiModel.withPlayers({
    required this.name,
    required this.date,
    required this.seasonId,
    required this.home,
    List<PlayerApiModel>? players,
    this.id,
    this.pkflMatch
  }) : playerIdList = _getIdsFromPlayers(players ?? []);

  static List<int> _getIdsFromPlayers(List<PlayerApiModel> players) {
    List<int> ids = [];
    for (PlayerApiModel player in players) {
      ids.add(player.id!);
    }
    return ids;
  }

  MatchApiModel.dummy()
      : id = -100,
        name = "neznámý hráč",
        date = DateTime.fromMicrosecondsSinceEpoch(0),
        home = false,
        seasonId = 0,
        playerIdList = [];


  @override
  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "id": id,
      "date": formatDateForJson(date),
      "home": home,
      "seasonId": seasonId,
      "playerIdList": playerIdList,
      "pkflMatch": pkflMatch,
    };
  }

  @override
  factory MatchApiModel.fromJson(Map<String, dynamic> json) {
    return MatchApiModel(
      date: DateTime.parse(json['date']),
      name: json["name"] ?? "",
      id: json["id"] ?? 0,
      home: json["home"] ?? false,
      seasonId: json['seasonId'] ?? 0,
      playerIdList: List<int>.from((json['playerIdList'])),
      pkflMatch: json["pkflMatch"] != null ? PkflMatchApiModel.fromJson(json["pkflMatch"]) : null,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MatchApiModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toStringForListView() {
    return "Datum zápasu: ${dateTimeToString(date)}";
  }

  @override
  String listViewTitle() {
    return (home ? "Liščí Trus - $name" : "$name - Liščí Trus") + (pkflMatch!=null ? " ${pkflMatch!.simpleResultToString()}" : "");
  }

  @override
  String toStringForAdd() {
    return "Přidán zápas ${home ? "Liščí Trus - $name" : "$name - Liščí Trus"} $name s datumem: ${dateTimeToString(date)}";
  }

  @override
  String toStringForConfirmationDelete() {
    return "Opravdu chcete smazat tento zápas?";
  }

  @override
  String toStringForEdit(String originName) {
    return "Zápas se soupeřem $originName upraven na ${home ? "Liščí Trus - $name" : "$name - Liščí Trus"} $name s datumem: ${dateTimeToString(date)}";
  }

  @override
  String httpRequestClass() {
    return matchApi;
  }

  @override
  int getId() {
    return id ?? -1;
  }
}
