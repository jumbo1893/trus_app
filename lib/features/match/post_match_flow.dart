import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/models/api/match/planned_match.dart';

/// The match currently moving from lineup confirmation through score and goals to its summary.
final postMatchFlowProvider = StateProvider<int?>((ref) => null);

/// The in-progress planned match whose live screen (clock + score + goals) is open.
final liveMatchProvider = StateProvider<PlannedMatch?>((ref) => null);

/// Score last loaded or saved on the score bar, keyed by match id;
/// null until the score bar has loaded the match.
final matchScoreProvider = StateProvider.family<(int?, int?)?, int>(
  (ref, matchId) => null,
);

bool missingMatchResult(int? homeGoals, int? awayGoals) =>
    homeGoals == null || awayGoals == null;

/// Training and teambuilding have no score.
bool scorelessMatchType(String? type) =>
    type == 'TRAINING' || type == 'TEAMBUILDING';

/// Live clock label for an in-progress match, e.g. "2. poločas · 41:07".
String livePhaseLabel(PlannedMatch match, DateTime now) {
  final elapsed = now.difference(match.date);
  final half = Duration(minutes: match.halfMinutes);
  final pause = Duration(minutes: match.breakMinutes);
  String clock(Duration d) =>
      '${d.inMinutes.toString().padLeft(2, '0')}:'
      '${(d.inSeconds % 60).toString().padLeft(2, '0')}';
  if (elapsed.isNegative) return 'Začíná za ${clock(-elapsed)}';
  if (elapsed < half) return '1. poločas · ${clock(elapsed)}';
  if (elapsed < half + pause) {
    return 'Přestávka · zbývá ${clock(half + pause - elapsed)}';
  }
  if (elapsed < half * 2 + pause) {
    return '2. poločas · ${clock(elapsed - pause)}';
  }
  return 'Konec zápasu';
}
