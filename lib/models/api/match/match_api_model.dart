import 'package:trus_app/common/utils/calendar.dart';
import 'package:trus_app/config.dart';
import 'package:trus_app/models/api/interfaces/json_and_http_converter.dart';
import 'package:trus_app/models/api/interfaces/model_to_string.dart';
import 'package:trus_app/models/api/player_api_model.dart';

class MatchApiModel implements ModelToString, JsonAndHttpConverter {
  int? id;
  final String name;
  final DateTime date;
  final int seasonId;
  final bool home;
  final List<int> playerIdList;

  MatchApiModel({
    required this.name,
    required this.date,
    required this.seasonId,
    required this.home,
    required this.playerIdList,
    this.id,
  });

  MatchApiModel.withPlayers({
    required this.name,
    required this.date,
    required this.seasonId,
    required this.home,
    List<PlayerApiModel>? players,
    this.id,
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
      "date": date.toIso8601String(),
      "home": home,
      "seasonId": seasonId,
      "playerIdList": playerIdList,
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
    return home ? "Liščí Trus -  $name" : "$name - Liščí Trus";
  }

  @override
  String toStringForAdd() {
    return "Přidán zápas ${home ? "Liščí Trus -  $name" : "$name - Liščí Trus"} $name s datumem: ${dateTimeToString(date)}";
  }

  @override
  String toStringForConfirmationDelete() {
    return "Opravdu chcete smazat tohoto hráče?";
  }

  @override
  String toStringForEdit(String originName) {
    return "Zápas se soupeřem $originName upraven na ${home ? "Liščí Trus -  $name" : "$name - Liščí Trus"} $name s datumem: ${dateTimeToString(date)}";
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
