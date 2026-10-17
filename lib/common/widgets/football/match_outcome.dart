import 'package:flutter/material.dart';
import 'package:trus_app/theme/app_colors.dart';

enum MatchOutcome {
  win,
  draw,
  loss;

  static MatchOutcome? fromScore({
    required int? homeGoals,
    required int? awayGoals,
    required bool? isHome,
  }) {
    if (homeGoals == null || awayGoals == null || isHome == null) return null;
    final goalsFor = isHome ? homeGoals : awayGoals;
    final goalsAgainst = isHome ? awayGoals : homeGoals;
    if (goalsFor > goalsAgainst) return MatchOutcome.win;
    if (goalsFor < goalsAgainst) return MatchOutcome.loss;
    return MatchOutcome.draw;
  }

  String get label => switch (this) {
    MatchOutcome.win => 'VÝHRA',
    MatchOutcome.draw => 'REMÍZA',
    MatchOutcome.loss => 'PROHRA',
  };

  Color foreground(AppColors colors) => switch (this) {
    MatchOutcome.win => colors.successForeground,
    MatchOutcome.draw => colors.warningForeground,
    MatchOutcome.loss => colors.errorForeground,
  };

  Color background(AppColors colors) => switch (this) {
    MatchOutcome.win => colors.successBackground,
    MatchOutcome.draw => colors.warningBackground,
    MatchOutcome.loss => colors.errorBackground,
  };
}
