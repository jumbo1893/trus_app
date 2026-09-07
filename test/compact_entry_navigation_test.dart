import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trus_app/common/widgets/listview/listview_add_model_double.dart';
import 'package:trus_app/models/api/interfaces/add_to_string.dart';
import 'package:trus_app/features/fine/match/controller/fine_player_notifier.dart';
import 'package:trus_app/features/fine/match/controller/fine_multiple_player_notifier.dart';
import 'package:trus_app/features/fine/match/fine_player_args.dart';
import 'package:trus_app/features/fine/match/fine_multiple_player_args.dart';
import 'package:trus_app/features/fine/match/repository/fine_match_api_service.dart';
import 'package:trus_app/features/fine/repository/fine_api_service.dart';
import 'package:trus_app/features/main/controller/screen_notifier.dart';
import 'package:trus_app/features/main/controller/screen_variables_notifier.dart';
import 'package:trus_app/features/statistics/statistics_navigation.dart';
import 'package:trus_app/models/api/fine_api_model.dart';
import 'package:trus_app/models/api/receivedfine/received_fine_api_model.dart';
import 'package:trus_app/models/api/receivedfine/received_fine_list.dart';
import 'package:trus_app/models/api/receivedfine/received_fine_response.dart';
import 'ux_preview_capture.dart';

class _Counter implements AddToString {
  @override
  String toStringForListView() => 'Jan Novák';
  @override
  String numberToString(bool first) => first ? '12' : '3';
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

FineApiModel fine() =>
    FineApiModel(id: 1, name: 'Pozdní příchod', amount: 50, inactive: false);

class _FineApi implements FineMatchApiService {
  bool fail = false;
  ReceivedFineList? saved;
  @override
  Future<List<ReceivedFineApiModel>> setupFinePlayer(
    int playerId,
    int matchId,
  ) async => [
    ReceivedFineApiModel(
      matchId: matchId,
      playerId: playerId,
      fine: fine(),
      fineNumber: 0,
    ),
  ];
  @override
  Future<ReceivedFineResponse> addFines(
    ReceivedFineList payload,
    bool multiple,
  ) async {
    if (fail) throw Exception('offline');
    saved = payload;
    return ReceivedFineResponse(
      editedPlayersCount: 1,
      player: '',
      totalFinesAdded: 1,
      match: 'Soupeř',
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _TariffApi implements FineApiService {
  @override
  Future<List<FineApiModel>> getFines() async => [fine()];
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  setUpAll(loadPreviewFont);
  for (final scale in [1.0, 1.5]) {
    testWidgets('compact beer counters at 320px and text scale $scale', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(320, 800));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      var beers = 0;
      var spirits = 0;
      await tester.pumpWidget(
        MaterialApp(
          theme: previewTheme(),
          home: Scaffold(
            body: MediaQuery(
              data: MediaQueryData(textScaler: TextScaler.linear(scale)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Align(
                  alignment: Alignment.topCenter,
                  child: ListviewAddModelDouble(
                    compact: true,
                    addToString: _Counter(),
                    onFirstNumberAdded: () => beers++,
                    onFirstNumberRemoved: () => beers--,
                    onSecondNumberAdded: () => spirits++,
                    onSecondNumberRemoved: () => spirits--,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      final beer = find.byTooltip('Jan Novák · přidat pivo');
      final liquor = find.byTooltip('Jan Novák · přidat panáka');
      await tester.tap(beer);
      await tester.tap(liquor);
      expect(beers, 1);
      expect(spirits, 1);
      if (scale == 1) {
        expect(tester.getCenter(beer).dy, tester.getCenter(liquor).dy);
        expect(
          tester.getSize(find.byType(ListviewAddModelDouble)).height,
          lessThan(90),
        );
      }
      expect(tester.takeException(), isNull);
      await capturePreview(tester, 'compact-beer-$scale');
    });
  }
  for (final multiple in [false, true]) {
    for (final fail in [false, true]) {
      test(
        'fine save multiple=$multiple fail=$fail preserves match and returns only on success',
        () async {
          final api = _FineApi()..fail = fail;
          final container = ProviderContainer(
            overrides: [
              fineMatchApiServiceProvider.overrideWithValue(api),
              fineApiServiceProvider.overrideWithValue(_TariffApi()),
            ],
          );
          addTearDown(container.dispose);
          final nav = container.read(screenNotifierProvider.notifier);
          await nav.changeByFragmentId('fine-player-screen');
          Future<void> Function() save;
          if (multiple) {
            final provider = fineMultiplePlayerNotifier(
              FineMultiplePlayerArgs(42, [7, 8]),
            );
            container.listen(provider, (_, __) {});
            await Future<void>.delayed(Duration.zero);
            final notifier = container.read(provider.notifier);
            notifier.addNumber(0);
            save = notifier.changeFines;
          } else {
            final provider = finePlayerNotifier(FinePlayerArgs(42, 7));
            container.listen(provider, (_, __) {});
            await Future<void>.delayed(Duration.zero);
            final notifier = container.read(provider.notifier);
            notifier.addNumber(0);
            save = notifier.changeFines;
          }
          if (fail) {
            await expectLater(save(), throwsException);
            expect(
              container.read(screenNotifierProvider).currentScreenId,
              'fine-player-screen',
            );
          } else {
            await save();
            expect(
              container.read(screenNotifierProvider).currentScreenId,
              'fine-match-screen',
            );
            expect(container.read(screenVariablesNotifierProvider).matchId, 42);
            expect(api.saved!.matchId, 42);
          }
        },
      );
    }
  }
  test(
    'all legacy statistics destinations open their category in the shared overview',
    () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final nav = container.read(screenNotifierProvider.notifier);
      for (final route in [
        for (final c in ['beer', 'fine', 'goal', 'attendance'])
          for (final view in ['player', 'match']) '$c-$view-statistics-screen',
        'beer-detail-stats-screen',
        'football-stats-screen',
        'football-player-stats-screen',
      ]) {
        await nav.changeByFragmentId(route);
        expect(
          container.read(screenNotifierProvider).currentScreenId,
          'statistics-hub',
        );
        expect(
          container.read(statisticsSelectionProvider).key,
          statisticsSelectionForRoute(route)!.key,
        );
      }
    },
  );
}
