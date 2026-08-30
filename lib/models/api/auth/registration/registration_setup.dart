import 'package:trus_app/models/api/auth/app_team_api_model.dart';
import 'package:trus_app/models/api/auth/registration/league_with_teams.dart';
import 'package:trus_app/models/api/auth/registration/team_with_app_teams.dart';

class RegistrationSetup {
  final List<LeagueWithTeams> leagueWithTeamsList;
  final List<AppTeamApiModel> appTeamList;
  final LeagueWithTeams? primaryLeague;
  final TeamWithAppTeams? primaryTeam;
  final AppTeamApiModel primaryAppTeam;

  RegistrationSetup({
    required this.leagueWithTeamsList,
    required this.appTeamList,
    required this.primaryLeague,
    required this.primaryTeam,
    required this.primaryAppTeam,
  });

  factory RegistrationSetup.fromJson(Map<String, dynamic> json) {
    return RegistrationSetup(
      leagueWithTeamsList: List<LeagueWithTeams>.from(
        (json['leagueWithTeamsList'] as List<dynamic>).map(
          (league) => LeagueWithTeams.fromJson(league),
        ),
      ),
      appTeamList: List<AppTeamApiModel>.from(
        (json['appTeamList'] as List<dynamic>).map(
          (team) => AppTeamApiModel.fromJson(team),
        ),
      ),
      primaryLeague: json["primaryLeague"] == null
          ? null
          : LeagueWithTeams.fromJson(json["primaryLeague"]),
      primaryTeam: json["primaryTeam"] == null
          ? null
          : TeamWithAppTeams.fromJson(json["primaryTeam"]),
      primaryAppTeam: AppTeamApiModel.fromJson(json["primaryAppTeam"]),
    );
  }
}
