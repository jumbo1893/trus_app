import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The match currently moving from result entry through goals to its summary.
final postMatchFlowProvider = StateProvider<int?>((ref) => null);

bool missingMatchResult(int? homeGoals, int? awayGoals) =>
    homeGoals == null || awayGoals == null;
