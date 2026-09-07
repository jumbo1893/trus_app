import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config.dart';
import 'stat_args.dart';

enum StatisticsCategory { beer, fine, goal, attendance, league }

class StatisticsSelection {
  final StatisticsCategory category;
  final int view;
  const StatisticsSelection(this.category, [this.view = 0]);
  StatsArgs? get args => category == StatisticsCategory.league || view == 2
      ? null
      : StatsArgs(
          [beerApi, receivedFineApi, goalApi, attendanceApi][category.index],
          view == 1,
        );
  String get key => '${category.name}-$view';
}

final statisticsSelectionProvider = StateProvider<StatisticsSelection>(
  (ref) => const StatisticsSelection(StatisticsCategory.beer),
);
StatisticsSelection? statisticsSelectionForRoute(String route) {
  for (final category in StatisticsCategory.values.take(4)) {
    for (var view = 0; view < 2; view++) {
      if (route ==
          '${category.name}-${view == 0 ? 'player' : 'match'}-statistics-screen') {
        return StatisticsSelection(category, view);
      }
    }
  }
  return switch (route) {
    'beer-detail-stats-screen' => const StatisticsSelection(
      StatisticsCategory.beer,
      2,
    ),
    'football-stats-screen' => const StatisticsSelection(
      StatisticsCategory.league,
    ),
    'football-player-stats-screen' => const StatisticsSelection(
      StatisticsCategory.league,
      1,
    ),
    _ => null,
  };
}
