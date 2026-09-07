import 'package:flutter/material.dart';
import 'package:trus_app/features/statistics/widget/statistics_filter_bar.dart';
import 'package:trus_app/theme/app_theme.dart';
import 'package:trus_app/features/statistics/filter/shared_statistics_season.dart';
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trus_app/config.dart';
import 'package:trus_app/features/statistics/controller/stats_notifier.dart';
import 'package:trus_app/features/statistics/filter/statistics_filter.dart';
import 'package:trus_app/features/statistics/filter/statistics_filter_options.dart';
import 'package:trus_app/features/statistics/repository/stats_api_service.dart';
import 'package:trus_app/features/statistics/stat_args.dart';
import 'package:trus_app/models/api/attendance/attendance_detailed_response.dart';
import 'package:trus_app/models/api/interfaces/detailed_response_model.dart';
import 'package:trus_app/models/api/season_api_model.dart';
import 'package:trus_app/models/api/goal/goal_detailed_model.dart';
import 'package:trus_app/models/api/goal/goal_detailed_response.dart';
import 'package:trus_app/models/api/match/match_api_model.dart';
import 'package:trus_app/models/api/player/player_api_model.dart';

class _Api implements StatsApiService {
  final requests =
      <
        ({
          String? query,
          StatisticsFilter filters,
          Completer<DetailedResponseModel> result,
        })
      >[];
  @override
  Future<DetailedResponseModel> getDetailedStats(
    int? matchId,
    int? seasonId,
    int? playerId,
    bool? matchStatsOrPlayerStats,
    String? filter,
    bool? detailed,
    String api, {
    StatisticsFilter advancedFilter = const StatisticsFilter(),
  }) {
    final result = Completer<DetailedResponseModel>();
    requests.add((query: filter, filters: advancedFilter, result: result));
    return result.future;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

DetailedResponseModel _response(int players) => AttendanceDetailedResponse(
  playersCount: players,
  matchesCount: 1,
  attendanceList: [],
);

void main() {
  testWidgets(
    'default season is visible and deleting its chip clears the shared season',
    (tester) async {
      final api = _Api();
      final container = ProviderContainer(
        overrides: [
          statsApiServiceProvider.overrideWithValue(api),
          statisticsSeasonsProvider.overrideWith(
            (ref) async => [
              SeasonApiModel(
                id: 42,
                name: 'Sezona 2026',
                fromDate: DateTime(2020),
                toDate: DateTime(2030),
              ),
            ],
          ),
        ],
      );
      addTearDown(container.dispose);
      await tester.binding.setSurfaceSize(const Size(320, 700));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: AppTheme.light(),
            home: const Scaffold(
              body: StatisticsFilterBar(statsArgs: StatsArgs(beerApi, false)),
            ),
          ),
        ),
      );
      await tester.pump();
      expect(find.widgetWithText(InputChip, 'Sezona 2026'), findsOneWidget);
      expect(container.read(statisticsSeasonSelectionProvider), {42});
      await tester.tap(find.byTooltip('Zrušit: Sezona 2026'));
      await tester.pump();
      expect(find.byType(InputChip), findsNothing);
      expect(container.read(statisticsSeasonSelectionProvider), isEmpty);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'season is shared by existing and newly opened tabs while other filters stay local',
    (tester) async {
      final api = _Api();
      final container = ProviderContainer(
        overrides: [
          statsApiServiceProvider.overrideWithValue(api),
          statisticsSeasonsProvider.overrideWith(
            (ref) async => <SeasonApiModel>[],
          ),
        ],
      );
      addTearDown(container.dispose);
      final beers = statsNotifierProvider(const StatsArgs(beerApi, false));
      final goals = statsNotifierProvider(const StatsArgs(goalApi, true));
      container.listen(beers, (_, __) {});
      container.listen(goals, (_, __) {});
      await tester.pump();
      container
          .read(goals.notifier)
          .applyFilters(
            const StatisticsFilter(
              seasonIds: {42},
              playerIds: {7},
              descending: false,
            ),
          );
      await tester.pump();
      expect(container.read(beers).advancedFilter.seasonIds, {42});
      expect(container.read(beers).advancedFilter.playerIds, isEmpty);
      expect(container.read(beers).advancedFilter.descending, isTrue);
      final fines = statsNotifierProvider(
        const StatsArgs(receivedFineApi, false),
      );
      container.listen(fines, (_, __) {});
      await tester.pump();
      expect(container.read(fines).advancedFilter.seasonIds, {42});
      container
          .read(beers.notifier)
          .applyFilters(const StatisticsFilter(seasonIds: {9, 10}));
      await tester.pump();
      expect(container.read(goals).advancedFilter.seasonIds, {9, 10});
      expect(container.read(goals).advancedFilter.playerIds, {7});
      expect(container.read(goals).advancedFilter.descending, isFalse);
      container.read(beers.notifier).clearFilter();
      await tester.pump();
      expect(container.read(statisticsSeasonSelectionProvider), isEmpty);
      expect(container.read(goals).advancedFilter.seasonIds, isEmpty);
      container.refresh(fines);
      await tester.pump(const Duration(milliseconds: 1));
      expect(container.read(fines).advancedFilter.seasonIds, isEmpty);
      expect(tester.takeException(), isNull);
    },
  );

  test(
    'options use season-scoped results and all seasons remove the restriction',
    () async {
      final api = _Api();
      final container = ProviderContainer(
        overrides: [
          statsApiServiceProvider.overrideWithValue(api),
          statisticsSeasonsProvider.overrideWith(
            (ref) async => <SeasonApiModel>[],
          ),
        ],
      );
      addTearDown(container.dispose);
      for (final matchStats in [false, true]) {
        for (final seasonIds in [
          <int>{2020},
          <int>{},
        ]) {
          final provider = statisticsFilterOptionsProvider(
            StatsArgs(goalApi, matchStats, seasonIds: seasonIds),
          );
          final subscription = container.listen(provider, (_, __) {});
          final result = container.read(provider.future);
          expect(api.requests.last.filters.seasonIds, seasonIds);
          final names = seasonIds.isEmpty
              ? ['Horní Dolní', 'Soupeř 2020']
              : ['Soupeř 2020'];
          api.requests.last.result.complete(
            GoalDetailedResponse(
              playersCount: names.length,
              matchesCount: names.length,
              totalGoals: 2,
              totalAssists: 0,
              goalList: [
                for (var i = 0; i < names.length; i++)
                  GoalDetailedModel(
                    goalNumber: 1,
                    assistNumber: 0,
                    player: matchStats
                        ? PlayerApiModel(
                            id: i + 1,
                            name: names[i],
                            birthday: DateTime(1990),
                            fan: true,
                            active: false,
                          )
                        : null,
                    match: matchStats
                        ? null
                        : MatchApiModel(
                            id: i + 1,
                            name: names[i],
                            date: DateTime(2020),
                            seasonId: 2020,
                            home: true,
                            playerIdList: [],
                          ),
                  ),
              ],
            ),
          );
          final options = await result;
          expect(
            matchStats
                ? options.players.map((p) => p.name).toList()
                : options.opponents,
            names,
          );
          subscription.close();
        }
      }
    },
  );

  testWidgets(
    'search debounces and an old response cannot overwrite newer filters',
    (tester) async {
      final api = _Api();
      final container = ProviderContainer(
        overrides: [
          statsApiServiceProvider.overrideWithValue(api),
          statisticsSeasonsProvider.overrideWith(
            (ref) async => <SeasonApiModel>[],
          ),
        ],
      );
      addTearDown(container.dispose);
      const args = StatsArgs(attendanceApi, false);
      final provider = statsNotifierProvider(args);
      final subscription = container.listen(provider, (_, __) {});
      addTearDown(subscription.close);
      await tester.pump();
      final notifier = container.read(provider.notifier);
      expect(api.requests, hasLength(1));
      notifier.search('K');
      await tester.pump(const Duration(milliseconds: 100));
      notifier.search('Ka');
      await tester.pump(const Duration(milliseconds: 299));
      expect(api.requests, hasLength(1));
      await tester.pump(const Duration(milliseconds: 1));
      expect(api.requests.last.query, 'Ka');
      notifier.applyFilters(
        const StatisticsFilter(seasonIds: {1, 2}, opponentNames: {'TJ A'}),
      );
      expect(api.requests.last.filters.seasonIds, {1, 2});
      api.requests.last.result.complete(_response(3));
      await tester.pump();
      api.requests[0].result.complete(_response(99));
      api.requests[1].result.complete(_response(98));
      await tester.pump();
      expect(container.read(provider).overall.value?.text, startsWith('3 '));
      expect(container.read(provider).filter, 'Ka');
    },
  );

  testWidgets('leaving the screen cancels pending search', (tester) async {
    final api = _Api();
    final container = ProviderContainer(
      overrides: [
        statsApiServiceProvider.overrideWithValue(api),
        statisticsSeasonsProvider.overrideWith(
          (ref) async => <SeasonApiModel>[],
        ),
      ],
    );
    final provider = statsNotifierProvider(
      const StatsArgs(attendanceApi, true),
    );
    container.listen(provider, (_, __) {});
    await tester.pump();
    container.read(provider.notifier).search('TJ');
    container.dispose();
    await tester.pump(const Duration(seconds: 1));
    expect(api.requests, hasLength(1));
    api.requests.single.result.complete(_response(1));
    await tester.pump();
    expect(tester.takeException(), isNull);
  });
}
