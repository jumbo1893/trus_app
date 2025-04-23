import 'package:trus_app/models/api/auth/app_team_api_model.dart';
import 'package:trus_app/models/api/auth/registration/league_with_teams.dart';
import 'package:trus_app/models/api/auth/registration/team_with_app_teams.dart';
import 'package:trus_app/models/api/football/league_api_model.dart';
import 'package:trus_app/models/api/football/team_api_model.dart';

import '../../../../config.dart';
import '../../interfaces/json_and_http_converter.dart';

class RegistrationSetup {
  final List<LeagueWithTeams> leagueWithTeamsList;
  final LeagueWithTeams primaryLeague;
  final TeamWithAppTeams primaryTeam;
  final AppTeamApiModel primaryAppTeam;

  RegistrationSetup({
    required this.leagueWithTeamsList,
    required this.primaryLeague,
    required this.primaryTeam,
    required this.primaryAppTeam,
  });

  @override
  factory RegistrationSetup.fromJson(Map<String, dynamic> json) {
    return RegistrationSetup(
      leagueWithTeamsList: List<LeagueWithTeams>.from((json['leagueWithTeamsList'] as List<dynamic>).map((league) => LeagueWithTeams.fromJson(league))),
      primaryLeague: LeagueWithTeams.fromJson(json["primaryLeague"]),
      primaryTeam: TeamWithAppTeams.fromJson(json["primaryTeam"]),
      primaryAppTeam: AppTeamApiModel.fromJson(json["primaryAppTeam"]),
    );
  }
}
