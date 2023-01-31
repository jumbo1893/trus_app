import 'package:trus_app/common/utils/calendar.dart';

class SeasonModel {
  final String id;
  final String name;
  final DateTime fromDate;
  final DateTime toDate;

  SeasonModel({
    required this.id,
    required this.name,
    required this.fromDate,
    required this.toDate,
  });

  SeasonModel.allSeason()
      : id = "all",
        name = "Všechny sezony",
        fromDate = DateTime.fromMicrosecondsSinceEpoch(0),
        toDate = DateTime.fromMicrosecondsSinceEpoch(0);
  SeasonModel.otherSeason()
      : id = "other",
        name = "Ostatní",
        fromDate = DateTime.fromMicrosecondsSinceEpoch(0),
        toDate = DateTime.fromMicrosecondsSinceEpoch(0);
  SeasonModel.automaticSeason()
      : id = "automatic",
        name = "Automatická sezona",
        fromDate = DateTime.fromMicrosecondsSinceEpoch(0),
        toDate = DateTime.fromMicrosecondsSinceEpoch(0);

  SeasonModel.dummy()
      : id = "dummy",
        name = "",
        fromDate = DateTime.fromMicrosecondsSinceEpoch(0),
        toDate = DateTime.fromMicrosecondsSinceEpoch(0);

  String toStringForSeasonList() {
    return 'Začátek sezony: ${dateTimeToString(fromDate)}, konec sezony: ${dateTimeToString(toDate)}';
  }

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "id": id,
      "fromDate": fromDate.millisecondsSinceEpoch,
      "toDate": toDate.millisecondsSinceEpoch,
    };
  }

  factory SeasonModel.fromJson(Map<String, dynamic> json) {
    return SeasonModel(
      fromDate: DateTime.fromMillisecondsSinceEpoch(json['fromDate']),
      toDate: DateTime.fromMillisecondsSinceEpoch(json['toDate']),
      name: json["name"] ?? "",
      id: json["id"] ?? "",
    );
  }

  @override
  String toString() {
    return 'SeasonModel{id: $id, name: $name, fromDate: $fromDate, toDate: $toDate}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SeasonModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

//

}
