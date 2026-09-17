import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trus_app/features/season_recap/season_recap_data.dart';
import 'package:trus_app/features/season_recap/season_recap_cards.dart';
import 'package:trus_app/features/season_recap/season_recap_sheet.dart';
import 'package:trus_app/features/main/controller/screen_notifier.dart';
import 'package:trus_app/models/api/notification/push/push_payload.dart';
import 'package:trus_app/services/push/push_navigation_handler.dart';

class FakeRecapApi implements SeasonRecapApi {
  int openedCalls = 0;
  bool fail = false;
  @override
  Future<List<RecapSummary>> list() async => [
    RecapSummary(9, 'Podzim 2026', '2026-06-02', '2026-12-01', openedCalls > 0),
    const RecapSummary(8, 'Jaro 2026', '2026-01-01', '2026-06-01', false),
  ];
  @override
  Future<SeasonRecap> detail(int id) async {
    if (fail) throw Exception('offline');
    return const SeasonRecap('Podzim 2026', '2026-06-02', '2026-12-01', [
      RecapPage('intro', 'Tvoje sezona', 'Příběh týmu', [], []),
      RecapPage(
        'steps',
        'Každý krok se počítá',
        'Období mezi sezonami',
        [RecapMetric('Kroky týmu', '12 345')],
        [
          RecapBoard('Žebříček', 'kroků', [
            RecapStanding('Jan', 1, 12345, true),
          ]),
        ],
      ),
    ]);
  }

  @override
  Future<void> opened(int id) async {
    openedCalls++;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class LongRecapApi extends FakeRecapApi {
  @override
  Future<SeasonRecap> detail(int id) async =>
      SeasonRecap('Podzim', '2026-06-02', '2026-12-01', [
        for (final kind in ['intro', 'steps', 'footbar'])
          RecapPage(
            kind,
            kind,
            '',
            List.generate(20, (i) => RecapMetric('Metrika $i', '$i')),
            [],
          ),
      ]);
}

void main() {
  testWidgets(
    'every page visit resets vertical scroll for buttons and swipes',
    (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [seasonRecapApiProvider.overrideWithValue(LongRecapApi())],
          child: const MaterialApp(
            home: Scaffold(body: SeasonRecapSheet(id: 9)),
          ),
        ),
      );
      await tester.pumpAndSettle();
      Finder page(String kind) => find.byKey(ValueKey('recap-$kind'));
      double offset(String kind) =>
          tester.widget<SingleChildScrollView>(page(kind)).controller!.offset;
      await tester.drag(page('intro'), const Offset(0, -450));
      await tester.pumpAndSettle();
      expect(offset('intro'), greaterThan(0));
      await tester.tap(find.text('Další'));
      await tester.pumpAndSettle();
      expect(offset('steps'), 0);
      await tester.drag(page('steps'), const Offset(0, -450));
      await tester.pumpAndSettle();
      expect(offset('steps'), greaterThan(0));
      await tester.tap(find.byTooltip('Předchozí strana'));
      await tester.pumpAndSettle();
      expect(offset('intro'), 0);
      await tester.tap(find.text('Další'));
      await tester.pumpAndSettle();
      expect(offset('steps'), 0);
      await tester.drag(page('steps'), const Offset(0, -450));
      await tester.pumpAndSettle();
      await tester.drag(find.byType(PageView), const Offset(-700, 0));
      await tester.pumpAndSettle();
      expect(offset('footbar'), 0);
      await tester.drag(find.byType(PageView), const Offset(700, 0));
      await tester.pumpAndSettle();
      expect(offset('steps'), 0);
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets('history retains both seasons and renders Czech numeric dates', (
    tester,
  ) async {
    final api = FakeRecapApi()..openedCalls = 1;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [seasonRecapsProvider.overrideWith((ref) => api.list())],
        child: const MaterialApp(
          home: Scaffold(body: SeasonRecapHistoryCard()),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sezonní souhrny'));
    await tester.pumpAndSettle();
    expect(find.text('Podzim 2026'), findsOneWidget);
    expect(find.text('Jaro 2026'), findsOneWidget);
    expect(find.text('2. 6. 2026 – 1. 12. 2026'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('small portrait screen with large text has no overflow', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [seasonRecapApiProvider.overrideWithValue(FakeRecapApi())],
        child: MaterialApp(
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: const TextScaler.linear(2)),
            child: child!,
          ),
          home: const Scaffold(body: SeasonRecapSheet(id: 9)),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Další'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  test('parses backend pages and decimal rankings', () {
    final recap = SeasonRecap.fromJson({
      'seasonName': 'Podzim',
      'from': '2026-06-02',
      'to': '2026-12-01',
      'pages': [
        {
          'kind': 'footbar',
          'title': 'Kilometry',
          'text': '',
          'metrics': [
            {'label': 'Ty', 'value': '5,5 km'},
          ],
          'boards': [
            {
              'title': 'Pořadí',
              'unit': 'km',
              'rows': [
                {'name': 'Jan', 'rank': 2, 'value': 5.5, 'mine': true},
              ],
            },
          ],
        },
      ],
    });
    expect(recap.pages.single.boards.single.rows.single.value, 5.5);
    expect(recap.pages.single.metrics.single.value, '5,5 km');
  });

  testWidgets('sheet marks successful open, supports swipe and buttons', (
    tester,
  ) async {
    final api = FakeRecapApi();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [seasonRecapApiProvider.overrideWithValue(api)],
        child: const MaterialApp(home: Scaffold(body: SeasonRecapSheet(id: 9))),
      ),
    );
    await tester.pumpAndSettle();
    expect(api.openedCalls, 1);
    expect(find.text('Tvoje sezona'), findsOneWidget);
    await tester.drag(find.byType(PageView), const Offset(-600, 0));
    await tester.pumpAndSettle();
    expect(find.text('2 / 2'), findsOneWidget);
    expect(find.text('Hotovo'), findsOneWidget);
    await tester.tap(find.byTooltip('Předchozí strana'));
    await tester.pumpAndSettle();
    expect(find.text('1 / 2'), findsOneWidget);
    await tester.tap(find.text('Další'));
    await tester.pumpAndSettle();
    expect(find.text('2 / 2'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('failed fetch stays unread and can be retried', (tester) async {
    final api = FakeRecapApi()..fail = true;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [seasonRecapApiProvider.overrideWithValue(api)],
        child: const MaterialApp(home: Scaffold(body: SeasonRecapSheet(id: 9))),
      ),
    );
    await tester.pumpAndSettle();
    expect(api.openedCalls, 0);
    expect(find.text('Souhrn se nepodařilo načíst.'), findsOneWidget);
    api.fail = false;
    await tester.tap(find.text('Zkusit znovu'));
    await tester.pumpAndSettle();
    expect(api.openedCalls, 1);
  });

  testWidgets(
    'read latest disappears from dashboard, older unread stays in history',
    (tester) async {
      final api = FakeRecapApi();
      final container = ProviderContainer(
        overrides: [seasonRecapsProvider.overrideWith((ref) => api.list())],
      );
      addTearDown(container.dispose);
      int? opened;
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: Scaffold(
              body: SeasonRecapDashboardCard(onOpen: (id) => opened = id),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byType(ListTile));
      expect(opened, 9);
      await api.opened(9);
      container.invalidate(seasonRecapsProvider);
      await tester.pumpAndSettle();
      expect(find.byType(ListTile), findsNothing);
    },
  );

  testWidgets(
    'push routes to dashboard and preserves recap ID even for another team',
    (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final payload = PushPayload.fromData({
        'screenId': 'season-recap',
        'recapId': '123',
        'appTeamId': '5',
      });
      PushNavigationHandler.navigate(
        PushNavigationRef(
          read: container.read,
          invalidate: container.invalidate,
        ),
        payload,
      );
      await tester.pump();
      expect(container.read(pendingSeasonRecapProvider), 123);
      expect(
        container.read(screenNotifierProvider).currentScreenId,
        'home-screen',
      );
    },
  );
}
