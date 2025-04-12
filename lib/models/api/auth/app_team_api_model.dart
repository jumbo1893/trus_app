import '../football/team_api_model.dart';

class AppTeamApiModel {
  final int id;
  final String name;
  final int? ownerId;
  final TeamApiModel team;

  AppTeamApiModel({
    required this.id,
    required this.name,
    this.ownerId,
    required this.team,
  });


  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
      "ownerId": ownerId,
      "team": team.toJson(),
    };
  }

  factory AppTeamApiModel.fromJson(Map<String, dynamic> json) {
    return AppTeamApiModel(
      id: json["id"],
      name: json["name"],
      ownerId: json["ownerId"],
      team: TeamApiModel.fromJson(json["team"]),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppTeamApiModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'AppTeamApiModel{id: $id, name: $name, ownerId: $ownerId, team: $team}';
  }
}
