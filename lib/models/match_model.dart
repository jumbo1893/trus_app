import 'dart:convert';

import 'package:age_calculator/age_calculator.dart';
import 'package:trus_app/common/utils/calendar.dart';

class MatchModel {
  String id;
  final String name;
  final DateTime date;
  final bool home;
  final List<String> playerIdList;
  final String seasonId;

  MatchModel({
    required this.name,
    required this.id,
    required this.date,
    required this.home,
    required this.playerIdList,
    required this.seasonId,
  });

  MatchModel.dummyMainMatch()
      : id = "dummy_main",
        name = "name",
        date = DateTime.fromMicrosecondsSinceEpoch(0),
        home = false,
        playerIdList = [],
        seasonId = "";

  @override
  String toString() {
    return 'MatchModel{id: $id, name: $name, date: $date, home: $home, playerIdList: $playerIdList, seasonId: $seasonId}';
  }

  String toStringForMatchList() {
    return "Datum zápasu: ${dateTimeToString(date)}";
  }

  String toStringWithOpponentName() {
    return home ? "Liščí Trus -  $name" : "$name - Liščí Trus";
  }

  String toStringWithOpponentNameAndDate() {
    return "${home ? "Liščí Trus -  $name" : "$name - Liščí Trus"}, ${dateTimeToString(date)}";
  }

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "id": id,
      "date": date.millisecondsSinceEpoch,
      "home": home,
      "playerIdList": playerIdList,
      "seasonId": seasonId,
    };
  }

  factory MatchModel.fromJson(Map<String, dynamic> json) {
    return MatchModel(
      date: DateTime.fromMillisecondsSinceEpoch(json['date']),
      name: json["name"] ?? "",
      id: json["id"] ?? "",
      home: json["home"] ?? true,
      playerIdList: List<String>.from((json['playerIdList'])) ?? [],
      seasonId: json["seasonId"] ?? "",
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MatchModel && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

//

}
