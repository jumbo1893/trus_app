import 'package:trus_app/common/widgets/bottomsheet/stats_detail_bottom_sheet.dart';
import 'package:trus_app/theme/app_theme.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trus_app/config.dart';
import 'package:trus_app/features/statistics/filter/statistics_filter.dart';
import 'package:trus_app/features/statistics/filter/statistics_filter_options.dart';
import 'package:trus_app/features/statistics/repository/stats_api_service.dart';
import 'package:trus_app/features/statistics/stat_args.dart';
import 'package:trus_app/features/statistics/widget/statistics_filter_sheet.dart';
import 'package:trus_app/features/statistics/screens/stats_screen.dart';
import 'package:trus_app/models/api/interfaces/detailed_response_model.dart';
import 'package:trus_app/models/api/interfaces/model_to_string.dart';
import 'package:trus_app/models/api/goal/goal_detailed_model.dart';
import 'package:trus_app/models/api/player/player_api_model.dart';
import 'package:trus_app/models/api/season_api_model.dart';
import 'package:trus_app/models/api/fine_api_model.dart';

class _Response implements DetailedResponseModel {
  final int count;
  _Response([this.count = 1]);
  @override
  List<ModelToString> modelList() => List.generate(
    count,
    (i) => GoalDetailedModel(
      goalNumber: i + 1,
      assistNumber: 0,
      player: PlayerApiModel.dummy(),
    ),
  );
  @override
  String overallStats() => 'Celkem 50 gólů';
}

class _Api implements StatsApiService {
  int details = 0, fines = 0;
  Completer<DetailedResponseModel>? pending;
  bool fail = false;
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
  }) async {
    details++;
    if (fail) throw StateError('offline');
    return pending == null ? _Response(50) : pending!.future;
  }

  @override
  Future<List<FineApiModel>> getFineOptions() async {
    fines++;
    return [];
  }

  @override
  dynamic noSuchMethod(Invocation i) => super.noSuchMethod(i);
}

final _season = SeasonApiModel(
  id: 42,
  name: 'Podzim 2026',
  fromDate: DateTime(2020),
  toDate: DateTime(2030),
);
void main() {
  testWidgets(
    'detail back button and system back both reveal the unchanged overview',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light(),
          home: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                child: const Text('Přehled · Podzim 2026'),
                onPressed: () => StatsDetailBottomSheet.show(
                  context,
                  title: 'Detail hráče',
                  subtitle: 'Podzim 2026',
                  items: [],
                ),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Přehled · Podzim 2026'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Zpět na přehled'));
      await tester.pumpAndSettle();
      expect(find.text('Přehled · Podzim 2026'), findsOneWidget);
      expect(find.text('Detail hráče'), findsNothing);
      await tester.tap(find.text('Přehled · Podzim 2026'));
      await tester.pumpAndSettle();
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.text('Detail hráče'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets(
    'opening and applying season never loads players opponents or fines; selected field loads immediately on tap',
    (tester) async {
      final api = _Api()..pending = Completer<DetailedResponseModel>();
      final container = ProviderContainer(
        overrides: [
          statsApiServiceProvider.overrideWithValue(api),
          statisticsSeasonsProvider.overrideWith((ref) async => [_season]),
        ],
      );

      StatisticsFilter? result;
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: AppTheme.light(),
            home: Scaffold(
              body: Builder(
                builder: (context) => TextButton(
                  child: const Text('Otevřít'),
                  onPressed: () async {
                    result = await showStatisticsFilterSheet(
                      context,
                      args: const StatsArgs(receivedFineApi, true),
                      filter: const StatisticsFilter(),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Otevřít'));
      await tester.pumpAndSettle();
      expect(api.details, 0);
      expect(api.fines, 0);
      await tester.tap(find.text('Všechny sezony'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Podzim 2026'));
      await tester.tap(find.text('Použít výběr'));
      await tester.pumpAndSettle();
      expect(api.details, 0);
      expect(api.fines, 0);
      await tester.tap(find.text('Všichni hráči a fanoušci'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(api.details, 1);
      expect(api.fines, 0);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await tester.tap(find.byTooltip('Zavřít').last);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Použít filtry'));
      await tester.pumpAndSettle();
      expect(result?.seasonIds, {42});
      api.pending!.complete(_Response());
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
      container.dispose();
    },
  );
  testWidgets('option failure has retry and never blocks season selection', (
    tester,
  ) async {
    final api = _Api()..fail = true;
    final container = ProviderContainer(
      overrides: [
        statsApiServiceProvider.overrideWithValue(api),
        statisticsSeasonsProvider.overrideWith((ref) async => [_season]),
      ],
    );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: AppTheme.light(),
          home: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                child: const Text('Otevřít'),
                onPressed: () => showStatisticsFilterSheet(
                  context,
                  args: const StatsArgs(goalApi, true),
                  filter: const StatisticsFilter(),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Otevřít'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Všichni hráči a fanoušci'));
    await tester.pumpAndSettle();
    expect(find.text('Možnosti se nepodařilo načíst.'), findsOneWidget);
    api.fail = false;
    await tester.tap(find.text('Zkusit znovu'));
    await tester.pumpAndSettle();
    expect(api.details, 2);
    expect(find.text('Použít výběr'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
    container.dispose();
  });
  testWidgets(
    'season and filter remain visible after scrolling statistics on narrow phone',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(320, 640));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final api = _Api();
      final container = ProviderContainer(
        overrides: [
          statsApiServiceProvider.overrideWithValue(api),
          statisticsSeasonsProvider.overrideWith((ref) async => [_season]),
        ],
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: AppTheme.light(),
            home: StatsScreen(StatsArgs(goalApi, false)),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final summary = find.byKey(const ValueKey('statistics-overall'));
      final list = tester.widget<ListView>(find.byType(ListView).last);
      await tester.drag(summary, const Offset(0, -180));
      await tester.pumpAndSettle();
      expect(list.controller!.offset, greaterThan(40));
      final pinnedY = tester.getTopLeft(summary).dy;
      await tester.drag(summary, const Offset(0, -100));
      await tester.pumpAndSettle();
      expect(tester.getTopLeft(summary).dy, pinnedY);
      await tester.pumpAndSettle();
      expect(find.text('Podzim 2026'), findsOneWidget);
      expect(find.text('Filtry (1)'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
      container.dispose();
    },
  );
}
