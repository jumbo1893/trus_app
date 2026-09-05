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
