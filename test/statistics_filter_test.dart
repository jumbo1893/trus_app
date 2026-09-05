import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trus_app/config.dart';
import 'package:trus_app/features/statistics/filter/statistics_filter.dart';
import 'package:trus_app/features/statistics/filter/statistics_filter_options.dart';
import 'package:trus_app/features/statistics/stat_args.dart';
import 'package:trus_app/features/statistics/widget/statistics_filter_sheet.dart';
import 'package:trus_app/models/api/season_api_model.dart';
import 'package:trus_app/theme/app_theme.dart';

void main() {
  test('empty selection sends no restrictions', () {
    expect(const StatisticsFilter().toQueryParameters(), isEmpty);
    expect(const StatisticsFilter().activeCount, 0);
  });

  test(
    'all multiselections serialize independently and preserve opponent commas',
    () {
      const filter = StatisticsFilter(
        seasonIds: {1, 2},
        playerIds: {3, 4},
        fineIds: {5, 6},
        opponentNames: {'TJ A, z.s.', 'TJ B'},
      );
      expect(filter.activeCount, 4);
      expect(filter.toQueryParameters(), {
        'seasonIds[0]': '1',
        'seasonIds[1]': '2',
        'playerIds[0]': '3',
        'playerIds[1]': '4',
        'fineIds[0]': '5',
        'fineIds[1]': '6',
        'opponentNames[0]': 'TJ A, z.s.',
        'opponentNames[1]': 'TJ B',
      });
    },
  );

  test('changing one selection preserves others and can clear a selection', () {
    const original = StatisticsFilter(seasonIds: {1}, playerIds: {2});
    final changed = original.copyWith(seasonIds: {}, descending: false);
    expect(changed.seasonIds, isEmpty);
    expect(changed.playerIds, {2});
    expect(changed.descending, false);
    expect(original.seasonIds, {1});
  });

  final options = StatisticsFilterOptions(
    seasons: [
      SeasonApiModel(
        id: 1,
        name: 'Jaro',
        fromDate: DateTime(2026),
        toDate: DateTime(2026, 6),
      ),
      SeasonApiModel(
        id: 2,
        name: 'Podzim',
        fromDate: DateTime(2026, 7),
        toDate: DateTime(2026, 12),
      ),
    ],
    players: [],
    opponents: ['Soupeř A', 'Soupeř B'],
    fines: [],
  );

  testWidgets(
    'season is inside filters and supports multiselect without keyboard',
    (tester) async {
      StatisticsFilter? result;
      const args = StatsArgs(beerApi, false);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            statisticsFilterOptionsProvider(
              args,
            ).overrideWith((ref) async => options),
          ],
          child: MaterialApp(
            theme: AppTheme.light(),
            home: Scaffold(
              body: Builder(
                builder: (context) => TextButton(
                  onPressed: () async =>
                      result = await showStatisticsFilterSheet(
                        context,
                        args: args,
                        filter: const StatisticsFilter(),
                      ),
                  child: const Text('Otevřít'),
                ),
              ),
            ),
          ),
        ),
      );
      expect(find.text('Sezona'), findsNothing);
      await tester.tap(find.text('Otevřít'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Všechny sezony'));
      await tester.pumpAndSettle();
      expect(tester.testTextInput.isVisible, false);
      await tester.tap(find.text('Jaro'));
      await tester.tap(find.text('Podzim'));
      await tester.tap(find.text('Použít výběr'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Použít filtry'));
      await tester.pumpAndSettle();
      expect(result?.seasonIds, {1, 2});
    },
  );

  testWidgets(
    'player statistics offer opponents, match fine statistics players and fines',
    (tester) async {
      Future<void> show(StatsArgs args) => tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light(),
          home: Scaffold(
            body: SingleChildScrollView(
              child: StatisticsFilterFields(
                args: args,
                filter: const StatisticsFilter(),
                options: options,
                onChanged: (_) {},
              ),
            ),
          ),
        ),
      );
      await show(const StatsArgs(goalApi, false));
      expect(find.text('Soupeři'), findsOneWidget);
      expect(find.text('Pokuty'), findsNothing);
      await show(const StatsArgs(receivedFineApi, true));
      expect(find.text('Hráči a fanoušci'), findsOneWidget);
      expect(find.text('Pokuty'), findsOneWidget);
      expect(find.text('Soupeři'), findsNothing);
    },
  );
}
