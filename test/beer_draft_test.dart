import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trus_app/features/beer/controller/beer_notifier.dart';
import 'package:trus_app/features/beer/repository/beer_api_service.dart';
import 'package:trus_app/features/main/controller/navigation_guard.dart';
import 'package:trus_app/features/main/controller/screen_notifier.dart';
import 'package:trus_app/features/season/repository/season_api_service.dart';
import 'package:trus_app/features/season/controller/season_dropdown_notifier.dart';
import 'package:trus_app/features/season/season_args.dart';
import 'package:trus_app/models/api/beer/beer_list.dart';
import 'package:trus_app/models/api/beer/beer_multi_add_response.dart';
import 'package:trus_app/models/api/beer/beer_no_match_with_player.dart';
import 'package:trus_app/models/api/beer/beer_setup_response.dart';
import 'package:trus_app/models/api/match/match_api_model.dart';
import 'package:trus_app/models/api/player/player_api_model.dart';
import 'package:trus_app/models/api/season_api_model.dart';
import 'package:trus_app/features/beer/screens/beer_simple_screen.dart';
import 'package:trus_app/features/main/widget/navigation_shell.dart';
import 'ux_preview_capture.dart';

final season = SeasonApiModel(
  id: 1,
  name: 'Podzim',
  fromDate: DateTime(2026),
  toDate: DateTime(2027),
);
final nextSeason = SeasonApiModel(
  id: 2,
  name: 'Jaro',
  fromDate: DateTime(2027),
  toDate: DateTime(2028),
);
MatchApiModel match(int id) => MatchApiModel(
  id: id,
  name: 'Soupeř $id',
  date: DateTime(2026, 9, 6),
  seasonId: 1,
  home: true,
  playerIdList: [1],
);

class _Seasons implements SeasonApiService {
  @override
  Future<List<SeasonApiModel>> getSeasons2(SeasonArgs args) async => [
    season,
    nextSeason,
  ];
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Beers implements BeerApiService {
  int loads = 0, saves = 0;
  bool failSave = false;
  @override
  Future<BeerSetupResponse> setupBeers(int? matchId, int? seasonId) async {
    loads++;
    return BeerSetupResponse(
      match: match(matchId ?? 1),
      season: season,
      matchList: [match(1), match(2)],
      beerList: [
        BeerNoMatchWithPlayer(
          player: PlayerApiModel.dummy(),
          beerNumber: 1,
          liquorNumber: 0,
        ),
      ],
    );
  }

  @override
  Future<BeerMultiAddResponse> addBeers(BeerList list) async {
    saves++;
    if (failSave) throw Exception('offline');
    return BeerMultiAddResponse.fromJson({});
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  setUpAll(loadPreviewFont);
  late ProviderContainer container;
  late _Beers api;
  setUp(() async {
    SharedPreferences.setMockInitialValues({'userEmail': 'test@example.test'});
    api = _Beers();
    container = ProviderContainer(
      overrides: [
        beerApiServiceProvider.overrideWithValue(api),
        seasonApiServiceProvider.overrideWithValue(_Seasons()),
      ],
    );
    container.listen(beerNotifierProvider, (_, __) {});
    await Future<void>.delayed(Duration.zero);
    await container.read(beerNotifierProvider.notifier).init(matchId: 1);
    await container
        .read(screenNotifierProvider.notifier)
        .changeByFragmentId('beer-simple-screen');
  });
  tearDown(() => container.dispose());

  testWidgets(
    'beer entry fits a narrow phone and retains match context in tally mode',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(360, 800));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: previewTheme(),
            home: NavigationShell(
              screenId: BeerSimpleScreen.id,
              title: 'Zápis piv',
              selectedIndex: 2,
              onBack: () {},
              onHome: () {},
              onAccount: () {},
              onNotifications: () {},
              onDestination: (_) {},
              child: const BeerSimpleScreen(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('Změnit'), findsOneWidget);
      expect(find.byType(BottomAppBar), findsNothing);
      final counterPosition = tester.getCenter(find.byIcon(Icons.add).first);
      container.read(beerNotifierProvider.notifier).addNumber(0, true, null);
      await tester.pumpAndSettle();
      expect(find.textContaining('Neuložené změny'), findsOneWidget);
      expect(tester.getCenter(find.byIcon(Icons.add).first), counterPosition);
      container.read(beerNotifierProvider.notifier).removeNumber(0, true);
      await tester.pumpAndSettle();
      expect(tester.getCenter(find.byIcon(Icons.add).first), counterPosition);
      expect(find.text('Vrátit'), findsNothing);
      await capturePreview(tester, 'beer-entry');
      container.read(beerNotifierProvider.notifier).toggleMode(true);
      await tester.pump();
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 200)),
      );
      await tester.pump();
      expect(find.text('Změnit'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  test(
    'resume refreshes saved values but preserves an unsaved draft',
    () async {
      final notifier = container.read(beerNotifierProvider.notifier);
      final before = api.loads;
      await notifier.refreshOnResume();
      expect(api.loads, before + 1);
      notifier.addNumber(0, true, null);
      await notifier.refreshOnResume();
      expect(api.loads, before + 1);
      expect(container.read(beerNotifierProvider).beers.single.beerNumber, 2);
      expect(container.read(beerNotifierProvider).hasChanges, isTrue);
    },
  );

  test(
    'saving clears the draft without navigating and allows another save',
    () async {
      final notifier = container.read(beerNotifierProvider.notifier);
      notifier.addNumber(0, true, null);
      expect(container.read(beerNotifierProvider).hasChanges, isTrue);
      await notifier.changeBeers();
      expect(container.read(beerNotifierProvider).hasChanges, isFalse);
      expect(
        container.read(screenNotifierProvider).currentScreenId,
        'beer-simple-screen',
      );
      notifier.addNumber(0, true, null);
      await notifier.changeBeers();
      expect(api.saves, 2);
      expect(container.read(beerNotifierProvider).beers.single.beerNumber, 3);
    },
  );

  test('cancel preserves the draft and restores season selection', () async {
    final notifier = container.read(beerNotifierProvider.notifier);
    notifier.addNumber(0, true, null);
    container.read(navigationGuardProvider).guard = () async => false;
    final loads = api.loads;
    await notifier.selectMatch(match(2));
    await notifier.selectSeason(nextSeason);
    expect(api.loads, loads);
    expect(container.read(beerNotifierProvider).selectedMatch?.id, 1);
    expect(container.read(beerNotifierProvider).hasChanges, isTrue);
    expect(
      container
          .read(
            seasonDropdownNotifierProvider(const SeasonArgs(false, true, true, playedOnly: true)),
          )
          .selected,
      season,
    );
    notifier.discardChanges();
    expect(container.read(beerNotifierProvider).hasChanges, isFalse);
    expect(container.read(beerNotifierProvider).beers.single.beerNumber, 1);
  });

  test('failed saving preserves the draft', () async {
    final notifier = container.read(beerNotifierProvider.notifier);
    notifier.addNumber(0, true, null);
    api.failSave = true;
    await expectLater(notifier.changeBeers(), throwsA(anything));
    expect(container.read(beerNotifierProvider).hasChanges, isTrue);
    expect(container.read(beerNotifierProvider).beers.single.beerNumber, 2);
  });
}

