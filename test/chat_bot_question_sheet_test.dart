import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trus_app/features/chat/chat_bot_question_sheet.dart';
import 'package:trus_app/features/chat/chat_repository.dart';
import 'package:trus_app/models/api/match/match_api_model.dart';
import 'package:trus_app/models/api/season_api_model.dart';

void main() {
  final now = DateTime.now();
  final season = SeasonApiModel(
    id: 7,
    name: 'Aktuální sezona',
    fromDate: now.subtract(const Duration(days: 30)),
    toDate: now.add(const Duration(days: 30)),
  );
  final message = ChatMessage.fromJson({
    'id': 11,
    'authorId': 2,
    'author': 'Jan',
    'text': 'Vypil jsem pět piv',
    'createdAt': '2026-10-13T10:00:00Z',
  });

  Widget sheet({
    required Future<List<SeasonApiModel>> Function() seasons,
    required Future<List<MatchApiModel>> Function(int) matches,
    required Future<void> Function(String) send,
  }) => MaterialApp(
    home: Scaffold(
      body: Builder(
        builder: (context) => Center(
          child: FilledButton(
            onPressed: () => showModalBottomSheet<bool>(
              context: context,
              isScrollControlled: true,
              builder: (_) => ChatBotQuestionSheet(
                message: message,
                loadSeasons: seasons,
                loadMatches: matches,
                send: send,
              ),
            ),
            child: const Text('Otevřít'),
          ),
        ),
      ),
    ),
  );

  testWidgets('options are collapsed and empty question uses default', (
    tester,
  ) async {
    var seasonLoads = 0;
    var matchLoads = 0;
    String? sent;
    await tester.pumpWidget(
      sheet(
        seasons: () async {
          seasonLoads++;
          return [season];
        },
        matches: (_) async {
          matchLoads++;
          return [];
        },
        send: (text) async {
          sent = text;
        },
      ),
    );
    await tester.tap(find.text('Otevřít'));
    await tester.pumpAndSettle();
    expect(seasonLoads, 0);
    expect(matchLoads, 0);
    expect(find.text('Zápasy'), findsNothing);
    expect(find.textContaining('Ověř si odpověď u TrusBota'), findsOneWidget);
    final quote = tester.widget<Text>(
      find.byKey(const ValueKey('chat_bot_quote')),
    );
    expect(quote.maxLines, 2);
    await tester.tap(find.text('Zeptat se'));
    await tester.pumpAndSettle();
    expect(sent, 'TrusBote, Je to pravda?');
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'matches load only for current season and support multiple selection',
    (tester) async {
      final loadedSeasons = <int>[];
      String? sent;
      MatchApiModel match(int id, DateTime date) => MatchApiModel(
        id: id,
        name: 'Zápas $id',
        date: date,
        seasonId: 7,
        home: true,
        playerIdList: const [],
      );
      await tester.pumpWidget(
        sheet(
          seasons: () async => [season],
          matches: (id) async {
            loadedSeasons.add(id);
            return [
              match(21, now),
              match(22, now.subtract(const Duration(days: 1))),
            ];
          },
          send: (text) async {
            sent = text;
          },
        ),
      );
      await tester.tap(find.text('Otevřít'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Možnosti'));
      await tester.pumpAndSettle();
      expect(loadedSeasons, isEmpty);
      expect(find.byKey(const ValueKey('chat_bot_season_none')), findsNothing);
      await tester.tap(find.text('Zápasy'));
      await tester.pumpAndSettle();
      expect(loadedSeasons, [7]);
      await tester.ensureVisible(
        find.byKey(const ValueKey('chat_bot_match_21')),
      );
      await tester.tap(find.byKey(const ValueKey('chat_bot_match_21')));
      await tester.ensureVisible(
        find.byKey(const ValueKey('chat_bot_match_22')),
      );
      await tester.tap(find.byKey(const ValueKey('chat_bot_match_22')));
      await tester.ensureVisible(find.text('Zeptat se'));
      await tester.tap(find.text('Zeptat se'));
      await tester.pumpAndSettle();
      expect(sent, contains('Zápasy: Zápas 21 (id 21); Zápas 22 (id 22)'));
      expect(sent, isNot(contains('Sezona:')));
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('single season selection filters matches and question', (
    tester,
  ) async {
    final previous = SeasonApiModel(
      id: 6,
      name: 'Minulá sezona',
      fromDate: now.subtract(const Duration(days: 400)),
      toDate: now.subtract(const Duration(days: 300)),
    );
    final loadedSeasons = <int>[];
    String? sent;
    await tester.pumpWidget(
      sheet(
        seasons: () async => [previous, season],
        matches: (id) async {
          loadedSeasons.add(id);
          return [];
        },
        send: (text) async {
          sent = text;
        },
      ),
    );
    await tester.tap(find.text('Otevřít'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Možnosti'));
    await tester.pumpAndSettle();
    expect(loadedSeasons, isEmpty);
    await tester.tap(find.text('Sezona'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const ValueKey('chat_bot_season_6')));
    await tester.tap(find.byKey(const ValueKey('chat_bot_season_6')));
    await tester.pumpAndSettle();
    expect(loadedSeasons, isEmpty);
    await tester.tap(find.text('Zápasy'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Zeptat se'));
    await tester.tap(find.text('Zeptat se'));
    await tester.pumpAndSettle();
    expect(loadedSeasons, [6]);
    expect(sent, contains('Sezona: Minulá sezona (id 6)'));
    expect(sent, isNot(contains('Aktuální sezona')));
    expect(sent, startsWith('TrusBote, Je to pravda?'));
    expect(tester.takeException(), isNull);
  });

  testWidgets('scrolling a season of matches keeps one navigator', (
    tester,
  ) async {
    await tester.pumpWidget(
      sheet(
        seasons: () async => [season],
        matches: (_) async => [
          for (var id = 1; id <= 30; id++)
            MatchApiModel(
              id: id,
              name: 'Zápas $id',
              date: now.subtract(Duration(days: id)),
              seasonId: 7,
              home: true,
              playerIdList: const [],
            ),
        ],
        send: (_) async {},
      ),
    );
    await tester.tap(find.text('Otevřít'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Možnosti'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Zápasy'));
    await tester.pumpAndSettle();
    await tester.drag(
      find.byKey(const ValueKey('chat_bot_match_list')),
      const Offset(0, -500),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('switching season replaces selected matches', (tester) async {
    final previous = SeasonApiModel(
      id: 6,
      name: 'Minulá sezona',
      fromDate: now.subtract(const Duration(days: 400)),
      toDate: now.subtract(const Duration(days: 300)),
    );
    final loaded = <int>[];
    String? sent;
    await tester.pumpWidget(
      sheet(
        seasons: () async => [previous, season],
        matches: (seasonId) async {
          loaded.add(seasonId);
          return [
            MatchApiModel(
              id: seasonId == 7 ? 21 : 22,
              name: seasonId == 7 ? 'Nový zápas' : 'Starý zápas',
              date: now,
              seasonId: seasonId,
              home: true,
              playerIdList: const [],
            ),
          ];
        },
        send: (text) async {
          sent = text;
        },
      ),
    );
    await tester.tap(find.text('Otevřít'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Možnosti'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Zápasy'));
    await tester.pumpAndSettle();
    expect(loaded, [7]);
    await tester.ensureVisible(find.byKey(const ValueKey('chat_bot_match_21')));
    await tester.tap(find.byKey(const ValueKey('chat_bot_match_21')));
    await tester.tap(find.text('Sezona'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const ValueKey('chat_bot_season_6')));
    await tester.tap(find.byKey(const ValueKey('chat_bot_season_6')));
    await tester.pumpAndSettle();
    expect(loaded, [7, 6]);
    await tester.ensureVisible(find.byKey(const ValueKey('chat_bot_match_22')));
    await tester.tap(find.byKey(const ValueKey('chat_bot_match_22')));
    await tester.ensureVisible(find.text('Zeptat se'));
    await tester.tap(find.text('Zeptat se'));
    await tester.pumpAndSettle();
    expect(sent, isNot(contains('Nový zápas (id 21)')));
    expect(sent, contains('Starý zápas (id 22)'));
    expect(sent, contains('Sezona: Minulá sezona (id 6)'));
    expect(tester.takeException(), isNull);
  });

  testWidgets('clearing season restores current matches without season prompt', (
    tester,
  ) async {
    final previous = SeasonApiModel(
      id: 6,
      name: 'Minulá sezona',
      fromDate: now.subtract(const Duration(days: 400)),
      toDate: now.subtract(const Duration(days: 300)),
    );
    final loaded = <int>[];
    String? sent;
    await tester.pumpWidget(
      sheet(
        seasons: () async => [previous, season],
        matches: (id) async {
          loaded.add(id);
          return [];
        },
        send: (text) async => sent = text,
      ),
    );
    await tester.tap(find.text('Otevřít'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Možnosti'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Zápasy'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sezona'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const ValueKey('chat_bot_season_6')));
    await tester.tap(find.byKey(const ValueKey('chat_bot_season_6')));
    await tester.pumpAndSettle();
    await tester.ensureVisible(
      find.byKey(const ValueKey('chat_bot_season_none')),
    );
    await tester.tap(find.byKey(const ValueKey('chat_bot_season_none')));
    await tester.pumpAndSettle();
    expect(loaded, [7, 6]);
    await tester.ensureVisible(find.text('Zeptat se'));
    await tester.tap(find.text('Zeptat se'));
    await tester.pumpAndSettle();
    expect(sent, 'TrusBote, Je to pravda?');
    expect(tester.takeException(), isNull);
  });
}
