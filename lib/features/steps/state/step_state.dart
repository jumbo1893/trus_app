import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/models/api/step/step_models.dart';

enum StepSortField { name, steps, days, averageStepsPerDay }

class StepSortConfig {
  final StepSortField field;
  final bool descending;

  const StepSortConfig({required this.field, required this.descending});

  static const Map<StepPeriod, StepSortConfig> defaults = {
    StepPeriod.today: StepSortConfig(
      field: StepSortField.steps,
      descending: true,
    ),
    StepPeriod.betweenMatches: StepSortConfig(
      field: StepSortField.steps,
      descending: true,
    ),
    StepPeriod.sinceLastMatch: StepSortConfig(
      field: StepSortField.steps,
      descending: true,
    ),
    StepPeriod.allTime: StepSortConfig(
      field: StepSortField.averageStepsPerDay,
      descending: true,
    ),
  };

  StepSortConfig copyWith({StepSortField? field, bool? descending}) =>
      StepSortConfig(
        field: field ?? this.field,
        descending: descending ?? this.descending,
      );

  List<StepLeaderboardEntry> sort(List<StepLeaderboardEntry> entries) {
    final result = List<StepLeaderboardEntry>.of(entries);
    result.sort((first, second) {
      var comparison = _comparePrimary(first, second);
      if (descending) comparison = -comparison;
      if (comparison != 0) return comparison;

      final nameComparison = first.userName.toLowerCase().compareTo(
        second.userName.toLowerCase(),
      );
      if (nameComparison != 0) return nameComparison;
      return first.userId.compareTo(second.userId);
    });
    return result;
  }

  int _comparePrimary(
    StepLeaderboardEntry first,
    StepLeaderboardEntry second,
  ) => switch (field) {
    StepSortField.name => first.userName.toLowerCase().compareTo(
      second.userName.toLowerCase(),
    ),
    StepSortField.steps => first.stepCount.compareTo(second.stepCount),
    StepSortField.days => first.dayCount.compareTo(second.dayCount),
    StepSortField.averageStepsPerDay => first.averageStepsPerDay.compareTo(
      second.averageStepsPerDay,
    ),
  };
}

class StepsState {
  final AsyncValue<bool> consent;
  final AsyncValue<StepLeaderboardData> leaderboard;
  final StepPeriod period;
  final bool syncing;
  final Map<StepPeriod, StepSortConfig> sorting;

  const StepsState({
    required this.consent,
    required this.leaderboard,
    required this.period,
    required this.syncing,
    required this.sorting,
  });

  factory StepsState.initial() => const StepsState(
    consent: AsyncValue.loading(),
    leaderboard: AsyncValue.loading(),
    period: StepPeriod.today,
    syncing: false,
    sorting: StepSortConfig.defaults,
  );

  StepSortConfig get currentSort =>
      sorting[period] ?? StepSortConfig.defaults[period]!;

  StepsState copyWith({
    AsyncValue<bool>? consent,
    AsyncValue<StepLeaderboardData>? leaderboard,
    StepPeriod? period,
    bool? syncing,
    Map<StepPeriod, StepSortConfig>? sorting,
  }) => StepsState(
    consent: consent ?? this.consent,
    leaderboard: leaderboard ?? this.leaderboard,
    period: period ?? this.period,
    syncing: syncing ?? this.syncing,
    sorting: sorting ?? this.sorting,
  );
}
