import 'package:trus_app/models/api/interfaces/dropdown_item.dart';

import '../app_team_api_model.dart';

class TeamWithAppTeams implements DropdownItem {
  final int id;
  final String name;
  final List<AppTeamApiModel> appTeamList;

  TeamWithAppTeams({
    required this.name,
    required this.id,
    required this.appTeamList,
  });



  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "id": id,
      "appTeamList": appTeamList,
    };
  }

  factory TeamWithAppTeams.fromJson(Map<String, dynamic> json) {
    return TeamWithAppTeams(
      name: json["name"] ?? "",
      id: json["id"],
      appTeamList: List<AppTeamApiModel>.from(
          (json['appTeamList'] as List<dynamic>)
              .map((appTeam) => AppTeamApiModel.fromJson(appTeam))),
    );
  }


  @override
  String toString() {
    return name;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TeamWithAppTeams &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String dropdownItem() {
    return name;
  }

}
