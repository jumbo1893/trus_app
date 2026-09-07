import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trus_app/config.dart';
import 'package:trus_app/features/football/controller/current_season_notifier.dart';
import 'package:trus_app/features/football/controller/footbal_stats_notifier.dart';
import 'package:trus_app/features/football/repository/football_api_service.dart';
import 'package:trus_app/features/main/widget/navigation_shell.dart';
import 'package:trus_app/features/statistics/screens/unified_statistics_screen.dart';
import 'package:trus_app/features/statistics/statistics_navigation.dart';
import 'package:trus_app/features/statistics/filter/shared_statistics_season.dart';
import 'package:trus_app/features/statistics/filter/statistics_filter_options.dart';
import 'package:trus_app/features/statistics/controller/beer_detail_stats_notifier.dart';
import 'package:trus_app/features/beer/repository/beer_api_service.dart';
import 'package:trus_app/models/api/football/football_player_api_model.dart';
import 'package:trus_app/models/api/football/stats/football_all_individual_stats_api_model.dart';
import 'package:trus_app/models/api/interfaces/dropdown_item.dart';
import 'package:trus_app/models/api/season_api_model.dart';
import 'package:trus_app/models/api/stats/stats.dart';
import 'package:trus_app/models/enum/spinner_options.dart';
import 'package:trus_app/models/helper/title_and_text.dart';
import 'package:trus_app/theme/app_theme.dart';
import 'ux_preview_capture.dart';

class _LeagueApi implements FootballApiService {
  final requestedSeasons = <bool>[];
  @override
  Future<List<FootballAllIndividualStatsApiModel>> getPlayerStats(
    bool currentSeason,
  ) async {
    requestedSeasons.add(currentSeason);
    return [];
  }

  @override
  Future<List<FootballPlayerApiModel>> getFootballPlayers() async => [
    FootballPlayerApiModel(id: 1, name: 'Jan Novák', birthYear: 1990, uri: ''),
    FootballPlayerApiModel(id: 2, name: 'Jan Novák', birthYear: 1990, uri: ''),
  ];
  @override
  Future<List<TitleAndText>> getPlayerFacts(int playerId) async => [];
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _BeerApi implements BeerApiService {
  final requests = <int>[];
  @override
  Future<List<Stats>> getBeerStats(int? seasonId) async {
    requests.add(seasonId!);
    return [Stats(dropdownText: 'Piva', playerStats: [])];
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  setUpAll(loadPreviewFont);
  for (final dark in [false, true]) {
    testWidgets(
      'round outline beer button follows navigation color, dark=$dark',
      (tester) async {
        final theme = dark ? AppTheme.dark() : AppTheme.light();
        await tester.pumpWidget(
          MaterialApp(
            theme: theme,
            home: NavigationShell(
              screenId: 'home-screen',
              title: 'Přehled',
              selectedIndex: 0,
              onBack: () {},
              onHome: () {},
              onAccount: () {},
              onNotifications: () {},
              onDestination: (_) {},
              child: const SizedBox(),
            ),
          ),
        );
        final button = tester.widget<FloatingActionButton>(
          find.byKey(const ValueKey('beer_button')),
        );
        expect(button.shape, isA<CircleBorder>());
        expect(button.foregroundColor, theme.colorScheme.onSurfaceVariant);
        expect(find.byIcon(Icons.sports_bar_outlined), findsOneWidget);
        expect(find.byIcon(Icons.notifications_outlined), findsNothing);
        expect(tester.takeException(), isNull);
        await capturePreview(tester, 'beer-button-${dark ? 'dark' : 'light'}');
      },
    );
  }
  testWidgets(
    'league filter applies on confirmation, keeps all options and preserves team season',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(360, 800));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final api = _LeagueApi();
      final container = ProviderContainer(
        overrides: [
          footballApiServiceProvider.overrideWithValue(api),
          statisticsSelectionProvider.overrideWith(
            (ref) => const StatisticsSelection(StatisticsCategory.league),
          ),
          statisticsSeasonSelectionProvider.overrideWith((ref) => {42}),
        ],
      );
      addTearDown(container.dispose);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: previewTheme(),
            home: const Scaffold(body: UnifiedStatisticsScreen()),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Hráči'), findsOneWidget);
      expect(find.text('Zajímavosti'), findsOneWidget);
      await capturePreview(tester, 'league-statistics');
      await tester.tap(find.textContaining(RegExp(r'^Filtry(?: \(\d+\))?$')));
      await tester.pumpAndSettle();
      expect(find.text('Sezona'), findsOneWidget);
      expect(find.text('Statistika'), findsOneWidget);
      final fields = find.byType(DropdownButtonFormField<DropdownItem>);
      await tester.tap(fields.first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Všechny zápasy').last);
      await tester.pumpAndSettle();
      expect(api.requestedSeasons, [true]);
      await tester.tap(find.byTooltip('Zavřít'));
      await tester.pumpAndSettle();
      expect(api.requestedSeasons, [true]);
      await tester.tap(find.textContaining(RegExp(r'^Filtry(?: \(\d+\))?$')));
      await tester.pumpAndSettle();
      await tester.tap(fields.first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Všechny zápasy').last);
      await tester.pumpAndSettle();
      await capturePreview(tester, 'league-filter');
      await tester.tap(find.text('Použít filtry'));
      await tester.pumpAndSettle();
      expect(api.requestedSeasons, [true, false]);
      expect(
        (container.read(currentSeasonNotifierProvider).selected
                as SeasonApiModel)
            .id,
        allSeasonId,
      );
      expect(
        container
            .read(footballStatsNotifierProvider)
            .dropdownTexts
            .requireValue,
        SpinnerOption.values,
      );
      expect(container.read(statisticsSeasonSelectionProvider), {42});
      await tester.tap(find.text('Zajímavosti'));
      await tester.pumpAndSettle();
      await tester.tap(find.textContaining(RegExp(r'^Filtry(?: \(\d+\))?$')));
      await tester.pumpAndSettle();
      expect(find.text('Hráč'), findsOneWidget);
      expect(find.text('Sezona'), findsNothing);
      // Identically named players must remain distinct options.
      await tester.tap(find.byType(DropdownButtonFormField<DropdownItem>));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets(
    'beer details share one or all seasons without silently changing a multi-season choice',
    (tester) async {
      final api = _BeerApi();
      final container = ProviderContainer(
        overrides: [
          beerApiServiceProvider.overrideWithValue(api),
          statisticsSeasonsProvider.overrideWith(
            (ref) async => <SeasonApiModel>[],
          ),
          statisticsSeasonSelectionProvider.overrideWith((ref) => {42}),
        ],
      );
      addTearDown(container.dispose);
      container.listen(beerDetailStatsNotifierProvider, (_, __) {});
      await tester.pump();
      expect(api.requests, [42]);
      container.read(statisticsSeasonSelectionProvider.notifier).state = {
        9,
        10,
      };
      await tester.pump();
      expect(api.requests, [42]);
      expect(container.read(statisticsSeasonSelectionProvider), {9, 10});
      container.read(statisticsSeasonSelectionProvider.notifier).state = {10};
      await tester.pump();
      expect(api.requests, [42, 10]);
      container.read(statisticsSeasonSelectionProvider.notifier).state = {};
      await tester.pump();
      expect(api.requests, [42, 10, allSeasonId]);
      expect(tester.takeException(), isNull);
    },
  );
}
