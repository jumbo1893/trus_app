import 'package:flutter_test/flutter_test.dart';
import 'package:trus_app/features/steps/state/step_state.dart';
import 'package:trus_app/models/api/step/step_models.dart';

void main() {
  final entries = [
    const StepLeaderboardEntry(
      userId: 1,
      userName: 'Adam',
      stepCount: 20_000,
      dayCount: 4,
      averageStepsPerDay: 5_000,
    ),
    const StepLeaderboardEntry(
      userId: 2,
      userName: 'Cyril',
      stepCount: 15_000,
      dayCount: 2,
      averageStepsPerDay: 7_500,
    ),
    const StepLeaderboardEntry(
      userId: 3,
      userName: 'Boris',
      stepCount: 10_000,
      dayCount: 5,
      averageStepsPerDay: 2_000,
    ),
  ];

  test('periods have the requested default sorting', () {
    expect(
      StepSortConfig.defaults[StepPeriod.today]?.field,
      StepSortField.steps,
    );
    expect(
      StepSortConfig.defaults[StepPeriod.betweenMatches]?.field,
      StepSortField.steps,
    );
    expect(
      StepSortConfig.defaults[StepPeriod.sinceLastMatch]?.field,
      StepSortField.steps,
    );
    expect(
      StepSortConfig.defaults[StepPeriod.allTime]?.field,
      StepSortField.averageStepsPerDay,
    );
    expect(
      StepSortConfig.defaults.values.every((sort) => sort.descending),
      isTrue,
    );
  });

  test('sorts numeric values in both directions', () {
    const descending = StepSortConfig(
      field: StepSortField.steps,
      descending: true,
    );
    const ascending = StepSortConfig(
      field: StepSortField.days,
      descending: false,
    );

    expect(
      descending.sort(entries).map((entry) => entry.userName),
      ['Adam', 'Cyril', 'Boris'],
    );
    expect(
      ascending.sort(entries).map((entry) => entry.userName),
      ['Cyril', 'Adam', 'Boris'],
    );
  });

  test('sorts names in both directions', () {
    const ascending = StepSortConfig(
      field: StepSortField.name,
      descending: false,
    );
    const descending = StepSortConfig(
      field: StepSortField.name,
      descending: true,
    );

    expect(
      ascending.sort(entries).map((entry) => entry.userName),
      ['Adam', 'Boris', 'Cyril'],
    );
    expect(
      descending.sort(entries).map((entry) => entry.userName),
      ['Cyril', 'Boris', 'Adam'],
    );
  });

  test('all-time default sorts by average steps per day', () {
    final sorted = StepSortConfig.defaults[StepPeriod.allTime]!.sort(entries);

    expect(
      sorted.map((entry) => entry.userName),
      ['Cyril', 'Adam', 'Boris'],
    );
  });
}
