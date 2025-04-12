
import 'package:trus_app/models/api/football/table_team_api_model.dart';

class TeamApiModel {
  final int id;
  final String name;
  final TableTeamApiModel? currentTableTeam;

  TeamApiModel({
    required this.name,
    required this.id,
    this.currentTableTeam,
  });



  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "id": id,
      "currentTableTeam": currentTableTeam,
    };
  }

  factory TeamApiModel.fromJson(Map<String, dynamic> json) {
    return TeamApiModel(
      name: json["name"] ?? "",
      id: json["id"],
      currentTableTeam: json["currentTableTeam"] != null ? TableTeamApiModel.fromJson(
          json["currentTableTeam"]) : null,
    );
  }


  @override
  String toString() {
    return name;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TeamApiModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

}
