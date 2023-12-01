import '../../models/api/pkfl/pkfl_match_api_model.dart';
import '../../models/pkfl/pkfl_team.dart';

List<PkflMatchApiModel> sortMatchesByDate(List<PkflMatchApiModel> matches, bool desc) {
  if (desc) {
    matches.sort((b, a) => a.date.compareTo(b.date));
    return matches;
  } else {
    matches.sort((a, b) => a.date.compareTo(b.date));
  }
  return matches;
}

List<PkflTeam> sortMatchesByPoints(List<PkflTeam> teams) {
  teams.sort((b, a) => a.points.compareTo(b.points));
  return teams;
}

