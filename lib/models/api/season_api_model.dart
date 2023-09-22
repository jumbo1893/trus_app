import 'package:trus_app/common/utils/calendar.dart';
import 'package:trus_app/models/api/interfaces/json_and_http_converter.dart';

import '../../config.dart';
import 'interfaces/model_to_string.dart';

class SeasonApiModel implements ModelToString, JsonAndHttpConverter {
  int? id;
  final String name;
  final DateTime fromDate;
  final DateTime toDate;

  SeasonApiModel({
    this.id,
    required this.name,
    required this.fromDate,
    required this.toDate,
  });

  SeasonApiModel.dummy()
      : id = -10,
        name = "",
        fromDate = DateTime.fromMicrosecondsSinceEpoch(0),
        toDate = DateTime.fromMicrosecondsSinceEpoch(0);

  String toStringForSeasonList() {
    return 'Začátek sezony: ${dateTimeToString(fromDate)}, konec sezony: ${dateTimeToString(toDate)}';
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "id": id,
      "fromDate": formatDateForJson(fromDate),
      "toDate": formatDateForJson(toDate),
    };
  }

  @override
  factory SeasonApiModel.fromJson(Map<String, dynamic> json) {
    return SeasonApiModel(
      fromDate: DateTime.parse(json['fromDate']),
      toDate: DateTime.parse(json['toDate']),
      name: json["name"] ?? "",
      id: json["id"] ?? 0,
    );
  }

  @override
  String toString() {
    return 'SeasonApiModel{id: $id, name: $name, fromDate: $fromDate, toDate: $toDate}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SeasonApiModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toStringForListView() {
    return 'Začátek sezony: ${dateTimeToString(fromDate)}\nKonec sezony: ${dateTimeToString(toDate)}';
  }

  @override
  String listViewTitle() {
    return name;
  }

  @override
  String toStringForAdd() {
    return 'Přidána sezona $name se začátkem ${dateTimeToString(fromDate)} a koncem ${dateTimeToString(toDate)}';
  }

  @override
  String toStringForConfirmationDelete() {
    return "Opravdu chcete smazat tuto sezonu?";
  }

  @override
  String toStringForEdit(String originName) {
    return "Sezona $originName upravena na $name, se začátkem ${dateTimeToString(fromDate)} a koncem ${dateTimeToString(toDate)}";
  }

  @override
  String httpRequestClass() {
    return seasonApi;
  }

  @override
  int getId() {
    return id ?? -1;
  }
}
