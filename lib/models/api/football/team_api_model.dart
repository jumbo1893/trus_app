import 'package:trus_app/models/api/football/table_team_api_model.dart';

class TeamApiModel {
  final int id;
  final String name;
  final String? logoUrl;
  final TableTeamApiModel? currentTableTeam;

  TeamApiModel({
    required this.name,
    this.logoUrl,
    required this.id,
    this.currentTableTeam,
  });

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "logoUrl": logoUrl,
      "id": id,
      "currentTableTeam": currentTableTeam,
    };
  }

  factory TeamApiModel.fromJson(Map<String, dynamic> json) {
    return TeamApiModel(
      name: json["name"] ?? "",
      logoUrl: json["logoUrl"] as String?,
      id: json["id"],
      currentTableTeam: json["currentTableTeam"] != null
          ? TableTeamApiModel.fromJson(json["currentTableTeam"])
          : null,
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
