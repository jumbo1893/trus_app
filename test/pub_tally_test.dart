import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trus_app/features/beer/widget/pub_drink_art.dart';
import 'package:trus_app/features/beer/widget/pub_tally.dart';
import 'package:trus_app/features/beer/widget/czech_name_compare.dart';
import 'package:trus_app/models/api/beer/beer_no_match_with_player.dart';
import 'package:trus_app/models/api/beer/pub_attendance.dart';
import 'package:trus_app/models/api/player/player_api_model.dart';

void main() {
  test('Czech names sort accents and ch in Czech order', () {
    final names = ['Chalupa', 'Žák', 'Havel', 'Černý', 'Císař', 'Áda'];
    names.sort(compareCzechNames);
    expect(names, ['Áda', 'Císař', 'Černý', 'Havel', 'Chalupa', 'Žák']);
  });

  final player = PlayerApiModel(
    id: 1,
    name: 'Hráč',
    birthday: DateTime(1990),
    fan: false,
    active: true,
  );

  testWidgets('later opens drinks only until the next pub visit', (
    tester,
  ) async {
    var saves = 0;
    Widget screen(bool active) => MaterialApp(
      home: Scaffold(
        body: PubTally(
          matchId: 10,
          players: [
            BeerNoMatchWithPlayer(
              player: player,
              beerNumber: 0,
              liquorNumber: 0,
            ),
          ],
          matchPlayerIds: const [1],
          myPlayerId: 1,
          active: active,
          attendance: null,
          onAdd: (_, __) {},
          onRemove: (_, __) {},
          onSaveAttendance: (_, __) async {
            saves++;
            throw UnimplementedError();
          },
        ),
      ),
    );

    await tester.pumpWidget(screen(true));
    expect(find.text('Kdo jde do hospody?'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('pub-choose-later')));
    await tester.pump();
    expect(find.byKey(const ValueKey('styled-1-beer')), findsOneWidget);
    expect(saves, 0);

    await tester.pumpWidget(screen(false));
    await tester.pumpWidget(screen(true));
    expect(find.text('Kdo jde do hospody?'), findsOneWidget);
  });

  testWidgets('delete mode disables and exits when drinks reach zero', (
    tester,
  ) async {
    Widget screen(int beers) => MaterialApp(
      home: Scaffold(
        body: PubTally(
          matchId: 10,
          players: [
            BeerNoMatchWithPlayer(
              player: player,
              beerNumber: beers,
              liquorNumber: 0,
            ),
          ],
          matchPlayerIds: const [1],
          myPlayerId: 1,
          attendance: const PubAttendance(
            matchId: 10,
            configured: true,
            guestIds: {1},
            leftIds: {},
          ),
          onAdd: (_, __) {},
          onRemove: (_, __) {},
          onSaveAttendance: (_, __) async => throw UnimplementedError(),
        ),
      ),
    );

    await tester.pumpWidget(screen(1));
    final toggle = find.byKey(const ValueKey('pub-mode-toggle'));
    await tester.tap(toggle);
    await tester.pump();
    expect(tester.widget<Switch>(toggle).value, isTrue);

    await tester.pumpWidget(screen(0));
    await tester.pump();
    expect(tester.widget<Switch>(toggle).value, isFalse);
    expect(tester.widget<Switch>(toggle).onChanged, isNull);

    await tester.pumpWidget(screen(1));
    expect(tester.widget<Switch>(toggle).value, isFalse);
    expect(tester.widget<Switch>(toggle).onChanged, isNotNull);
  });

  testWidgets('saved attendance opens the tally and tapping a drink adds it', (
    tester,
  ) async {
    var additions = 0;
    bool? choosing;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PubTally(
            matchId: 10,
            players: [
              BeerNoMatchWithPlayer(
                player: player,
                beerNumber: 1,
                liquorNumber: 0,
              ),
            ],
            matchPlayerIds: const [1],
            myPlayerId: 1,
            attendance: const PubAttendance(
              matchId: 10,
              configured: true,
              guestIds: {1},
              leftIds: {},
            ),
            onAdd: (_, beer) {
              if (beer) additions++;
            },
            onRemove: (_, __) {},
            onSaveAttendance: (_, __) async => throw UnimplementedError(),
            onChoosingChanged: (value) => choosing = value,
          ),
        ),
      ),
    );

    expect(find.text('Kdo jde do hospody?'), findsNothing);
    await tester.tap(find.byKey(const ValueKey('styled-1-beer')));
    expect(additions, 1);
    expect(find.byIcon(Icons.delete_outline_rounded), findsNothing);
    await tester.tap(find.byTooltip('Upravit účastníky'));
    await tester.pump();
    expect(choosing, isTrue);
    expect(find.text('Kdo jde do hospody?'), findsOneWidget);
  });

  testWidgets('tapping an added shot removes one shot', (tester) async {
    var removals = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PubTally(
            matchId: 10,
            players: [
              BeerNoMatchWithPlayer(
                player: player,
                beerNumber: 0,
                liquorNumber: 1,
              ),
            ],
            matchPlayerIds: const [1],
            myPlayerId: 1,
            attendance: const PubAttendance(
              matchId: 10,
              configured: true,
              guestIds: {1},
              leftIds: {},
            ),
            onAdd: (_, __) {},
            onRemove: (_, beer) {
              if (!beer) removals++;
            },
            onSaveAttendance: (_, __) async => throw UnimplementedError(),
          ),
        ),
      ),
    );

    await tester.tap(find.byKey(const ValueKey('pub-mode-toggle')));
    final shot = find.byKey(const ValueKey('styled-1-shot'));
    await tester.tap(shot);
    await tester.pump();
    expect(removals, 1);
  });

  testWidgets('account offers only backend supported beer and shots', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PubTally(
            matchId: 10,
            players: [
              BeerNoMatchWithPlayer(
                player: player,
                beerNumber: 0,
                liquorNumber: 0,
              ),
            ],
            matchPlayerIds: const [1],
            myPlayerId: 1,
            attendance: const PubAttendance(
              matchId: 10,
              configured: true,
              guestIds: {1},
              leftIds: {},
            ),
            onAdd: (_, __) {},
            onRemove: (_, __) {},
            onSaveAttendance: (_, __) async => throw UnimplementedError(),
          ),
        ),
      ),
    );

    expect(find.byType(PubDrinkArt), findsNWidgets(2));
    expect(find.byKey(const ValueKey('styled-1-beer')), findsOneWidget);
    expect(find.byKey(const ValueKey('styled-1-shot')), findsOneWidget);
    expect(find.byKey(const ValueKey('styled-1-smallBeer')), findsNothing);
    expect(find.byKey(const ValueKey('styled-1-wine')), findsNothing);
  });

  testWidgets('many drinks collapse to a count in a compact player row', (
    tester,
  ) async {
    var removedBeers = 0;
    tester.view.physicalSize = const Size(390, 780);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PubTally(
            matchId: 10,
            players: [
              BeerNoMatchWithPlayer(
                player: player,
                beerNumber: 10,
                liquorNumber: 1,
              ),
            ],
            matchPlayerIds: const [1],
            myPlayerId: 1,
            attendance: const PubAttendance(
              matchId: 10,
              configured: true,
              guestIds: {1},
              leftIds: {},
            ),
            onAdd: (_, __) {},
            onRemove: (_, beer) {
              if (beer) removedBeers++;
            },
            onSaveAttendance: (_, __) async => throw UnimplementedError(),
          ),
        ),
      ),
    );

    expect(find.text('×10'), findsOneWidget);
    expect(find.byKey(const ValueKey('styled-1-beer')), findsOneWidget);
    expect(
      tester.getSize(find.byKey(const ValueKey('styled-player-1'))).height,
      lessThan(76),
    );
    await tester.tap(find.byKey(const ValueKey('pub-mode-toggle')));
    await tester.tap(find.byKey(const ValueKey('styled-1-beer')));
    expect(removedBeers, 1);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'visual account adds and corrects drinks with one small mode switch',
    (tester) async {
      var addedShots = 0;
      var removedBeers = 0;
      tester.view.physicalSize = const Size(390, 780);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PubTally(
              matchId: 10,
              players: [
                BeerNoMatchWithPlayer(
                  player: player,
                  beerNumber: 1,
                  liquorNumber: 0,
                ),
              ],
              matchPlayerIds: const [1],
              myPlayerId: 1,
              attendance: const PubAttendance(
                matchId: 10,
                configured: true,
                guestIds: {1},
                leftIds: {},
              ),
              onAdd: (_, beer) {
                if (!beer) addedShots++;
              },
              onRemove: (_, beer) {
                if (beer) removedBeers++;
              },
              onSaveAttendance: (_, __) async => throw UnimplementedError(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Účet v hospodě'), findsOneWidget);
      expect(find.byType(PubDrinkArt), findsNWidgets(2));
      expect(find.byIcon(Icons.delete_outline_rounded), findsNothing);
      expect(find.text('Přímo ikony'), findsNothing);
      expect(find.text('Opravit'), findsOneWidget);

      final shot = find.byKey(const ValueKey('styled-1-shot'));
      final shotArt = find.descendant(
        of: shot,
        matching: find.byType(PubDrinkArt),
      );
      expect(tester.widget<PubDrinkArt>(shotArt).active, isFalse);
      await tester.tap(shot);
      expect(addedShots, 1);
      expect(find.text('×1'), findsOneWidget);
      final leaderY = tester.getCenter(find.text('Vede Hráč')).dy;
      expect(tester.getCenter(find.text('1 ks')).dy, leaderY);
      expect(tester.getCenter(find.text('0,5 l')).dy, leaderY);

      await tester.tap(find.byKey(const ValueKey('pub-mode-toggle')));
      await tester.pump();
      expect(find.text('Mazání'), findsOneWidget);
      expect(find.byKey(const ValueKey('remove-badge-1-beer')), findsOneWidget);
      expect(
        find.descendant(
          of: find.byKey(const ValueKey('remove-badge-1-beer')),
          matching: find.byIcon(Icons.close),
        ),
        findsOneWidget,
      );
      expect(find.byKey(const ValueKey('remove-badge-1-shot')), findsNothing);
      expect(
        find.descendant(
          of: find.byKey(const ValueKey('styled-1-beer')),
          matching: find.byType(AnimatedBuilder),
        ),
        findsOneWidget,
      );
      await tester.tap(shot);
      expect(removedBeers, 0);
      await tester.tap(find.byKey(const ValueKey('styled-1-beer')));
      expect(removedBeers, 1);

      await tester.tap(find.byKey(const ValueKey('pub-mode-toggle')));
      await tester.pump();
      expect(find.byKey(const ValueKey('remove-badge-1-beer')), findsNothing);

      expect(find.byIcon(Icons.delete_outline_rounded), findsNothing);
      expect(find.byKey(const ValueKey('styled-1-shot')), findsOneWidget);
    },
  );

  testWidgets('a guest who left cannot add or remove drinks', (tester) async {
    var additions = 0;
    var removals = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PubTally(
            matchId: 10,
            players: [
              BeerNoMatchWithPlayer(
                player: player,
                beerNumber: 1,
                liquorNumber: 1,
              ),
            ],
            matchPlayerIds: const [1],
            myPlayerId: 1,
            attendance: const PubAttendance(
              matchId: 10,
              configured: true,
              guestIds: {1},
              leftIds: {1},
            ),
            onAdd: (_, __) => additions++,
            onRemove: (_, __) => removals++,
            onSaveAttendance: (_, __) async => throw UnimplementedError(),
          ),
        ),
      ),
    );

    final beer = find.byKey(const ValueKey('styled-1-beer'));
    final shot = find.byKey(const ValueKey('styled-1-shot'));
    await tester.tap(beer);
    await tester.tap(shot);
    expect(additions, 0);
    await tester.tap(find.byKey(const ValueKey('pub-mode-toggle')));
    await tester.pump();
    expect(find.byKey(const ValueKey('remove-badge-1-beer')), findsNothing);
    expect(find.byKey(const ValueKey('remove-badge-1-shot')), findsNothing);
    await tester.tap(beer);
    await tester.tap(shot);
    expect(removals, 0);
  });

  testWidgets('first visit saves guests before showing the tally', (
    tester,
  ) async {
    Set<int>? savedGuests;
    bool? choosing;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PubTally(
            matchId: 10,
            players: [
              BeerNoMatchWithPlayer(
                player: player,
                beerNumber: 0,
                liquorNumber: 0,
              ),
            ],
            matchPlayerIds: const [1],
            myPlayerId: 1,
            attendance: null,
            onAdd: (_, __) {},
            onRemove: (_, __) {},
            onSaveAttendance: (guests, left) async {
              savedGuests = guests;
              return PubAttendance(
                matchId: 10,
                configured: true,
                guestIds: guests,
                leftIds: left,
              );
            },
            onChoosingChanged: (value) => choosing = value,
          ),
        ),
      ),
    );

    expect(find.text('Kdo jde do hospody?'), findsOneWidget);
    await tester.tap(find.text('DO HOSPODY · 1'));
    await tester.pump();
    expect(savedGuests, {1});
    expect(choosing, isFalse);
    expect(find.text('Účet v hospodě'), findsOneWidget);
  });

  testWidgets('current guest is first without a switch', (tester) async {
    final people = [
      for (final (id, name) in [(1, 'Žan'), (2, 'Havel'), (3, 'Áda')])
        BeerNoMatchWithPlayer(
          player: PlayerApiModel(
            id: id,
            name: name,
            birthday: DateTime(1990),
            fan: false,
            active: true,
          ),
          beerNumber: 0,
          liquorNumber: 0,
        ),
    ];
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PubTally(
            matchId: 10,
            players: people,
            matchPlayerIds: const [1, 2, 3],
            myPlayerId: 1,
            attendance: const PubAttendance(
              matchId: 10,
              configured: true,
              guestIds: {1, 2, 3},
              leftIds: {},
            ),
            onAdd: (_, __) {},
            onRemove: (_, __) {},
            onSaveAttendance: (_, __) async => throw UnimplementedError(),
          ),
        ),
      ),
    );

    expect(find.text('Moje jméno nahoře'), findsNothing);
    final ownY = tester.getTopLeft(find.text('Žan')).dy;
    final adaY = tester.getTopLeft(find.text('Áda')).dy;
    final havelY = tester.getTopLeft(find.text('Havel')).dy;
    expect(ownY, lessThan(adaY));
    expect(adaY, lessThan(havelY));
  });

  testWidgets('linked player stays first in the picker and after leaving', (
    tester,
  ) async {
    final people = [
      for (final (id, name) in [(1, 'Žan'), (2, 'Áda')])
        BeerNoMatchWithPlayer(
          player: PlayerApiModel(
            id: id,
            name: name,
            birthday: DateTime(1990),
            fan: false,
            active: true,
          ),
          beerNumber: 0,
          liquorNumber: 0,
        ),
    ];

    Widget build(PubAttendance? attendance) => MaterialApp(
      home: Scaffold(
        body: PubTally(
          matchId: 10,
          players: people,
          matchPlayerIds: const [1, 2],
          myPlayerId: 1,
          attendance: attendance,
          onAdd: (_, __) {},
          onRemove: (_, __) {},
          onSaveAttendance: (_, __) async => throw UnimplementedError(),
        ),
      ),
    );

    await tester.pumpWidget(build(null));
    expect(
      tester.getTopLeft(find.text('Žan')).dy,
      lessThan(tester.getTopLeft(find.text('Áda')).dy),
    );

    await tester.pumpWidget(
      build(
        const PubAttendance(
          matchId: 10,
          configured: true,
          guestIds: {1, 2},
          leftIds: {1},
        ),
      ),
    );
    await tester.pump();
    expect(
      tester.getTopLeft(find.text('Žan')).dy,
      lessThan(tester.getTopLeft(find.text('Áda')).dy),
    );
  });

  testWidgets('participant list stays below its header while scrolling', (
    tester,
  ) async {
    final people = [
      for (var i = 0; i < 25; i++)
        BeerNoMatchWithPlayer(
          player: PlayerApiModel(
            id: i + 1,
            name: 'Hráč $i',
            birthday: DateTime(1990),
            fan: false,
            active: true,
          ),
          beerNumber: 0,
          liquorNumber: 0,
        ),
    ];
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PubTally(
            matchId: 10,
            players: people,
            matchPlayerIds: [for (var i = 1; i <= 25; i++) i],
            myPlayerId: 1,
            attendance: null,
            onAdd: (_, __) {},
            onRemove: (_, __) {},
            onSaveAttendance: (_, __) async => throw UnimplementedError(),
          ),
        ),
      ),
    );

    final list = find.byType(ListView);
    await tester.drag(list, const Offset(0, -450));
    await tester.pumpAndSettle();
    expect(find.text('Kdo jde do hospody?'), findsOneWidget);
    expect(
      tester.getTopLeft(list).dy,
      greaterThanOrEqualTo(
        tester
            .getBottomLeft(
              find.text(
                'Účastníci zápasu jsou vybraní. Odškrtni ty, kteří nejdou.',
              ),
            )
            .dy,
      ),
    );
    expect(tester.takeException(), isNull);
  });
}
