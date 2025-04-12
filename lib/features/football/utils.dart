import 'package:trus_app/models/api/football/football_match_api_model.dart';
import 'package:trus_app/models/api/football/table_team_api_model.dart';

List<FootballMatchApiModel> sortMatchesByDate(List<FootballMatchApiModel> matches, bool desc) {
  if (desc) {
    matches.sort((b, a) => a.date.compareTo(b.date));
    return matches;
  } else {
    matches.sort((a, b) => a.date.compareTo(b.date));
  }
  return matches;
}

List<TableTeamApiModel> sortMatchesByPoints(List<TableTeamApiModel> teams) {
  teams.sort((b, a) => a.points.compareTo(b.points));
  return teams;
}

