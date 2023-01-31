import 'package:trus_app/models/pkfl/pkfl_match.dart';

List<PkflMatch> sortMatchesByDate(List<PkflMatch> matches, bool desc) {
  if (desc) {
    matches.sort((b, a) => a.date.compareTo(b.date));
    return matches;
  } else {
    matches.sort((a, b) => a.date.compareTo(b.date));
  }
  return matches;
}