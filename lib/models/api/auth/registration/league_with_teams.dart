import 'package:trus_app/models/api/auth/registration/team_with_app_teams.dart';
import 'package:trus_app/models/api/interfaces/dropdown_item.dart';

class LeagueWithTeams implements DropdownItem {
  final int id;
  final String name;
  final int rank;
  final String organization;
  final String organizationUnit;
  final String year;
  final List<TeamWithAppTeams> teamWithAppTeamsList;

  LeagueWithTeams({
    required this.id,
    required this.name,
    required this.rank,
    required this.organization,
    required this.organizationUnit,
    required this.year,
    required this.teamWithAppTeamsList,
  });

  factory LeagueWithTeams.fromJson(Map<String, dynamic> json) {
    return LeagueWithTeams(
      id: json["id"],
      name: json["name"],
      rank: json["rank"],
      organization: json["organization"],
      organizationUnit: json["organizationUnit"],
      year: json["year"],
      teamWithAppTeamsList: List<TeamWithAppTeams>.from((json['teamWithAppTeamsList'] as List<dynamic>).map((team) => TeamWithAppTeams.fromJson(team))),
    );
  }


  @override
  String toString() {
    return name;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LeagueWithTeams &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String dropdownItem() {
    return name;
  }

}
