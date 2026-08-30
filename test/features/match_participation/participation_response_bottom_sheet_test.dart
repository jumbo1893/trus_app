import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trus_app/features/match_participation/widgets/participation_response_bottom_sheet.dart';
import 'package:trus_app/models/api/football/football_match_api_model.dart';
import 'package:trus_app/models/api/football/league_api_model.dart';
import 'package:trus_app/models/api/football/team_api_model.dart';
import 'package:trus_app/models/api/participation/match_participation_status.dart';
import 'package:trus_app/models/api/player/player_api_model.dart';
import 'package:trus_app/theme/app_theme.dart';

void main() {
  testWidgets('unpaired response remembers status while player is selected', (
    tester,
  ) async {
    ParticipationChoice? choice;
    final player = PlayerApiModel(
      id: 7,
      name: 'Matěj',
      birthday: DateTime(2000),
      fan: false,
      active: true,
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () async {
                choice = await ParticipationResponseBottomSheet.show(
                  context,
                  footballMatch: footballMatch(),
                  currentPlayer: null,
                  eligiblePlayers: [player],
                );
              },
              child: const Text('Otevřít'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Otevřít'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Jsem mimo Prahu.');
    await tester.tap(find.text('Nezúčastním se'));
    await tester.pumpAndSettle();

    expect(find.text('Kdo jsi?'), findsOneWidget);
    expect(
      find.textContaining('odpověď „Nezúčastním se“ i komentář'),
      findsOneWidget,
    );

    await tester.tap(find.text('Matěj'));
    await tester.pumpAndSettle();

    expect(choice?.status, MatchParticipationStatus.notAttending);
    expect(choice?.player?.id, 7);
    expect(choice?.comment, 'Jsem mimo Prahu.');
  });
}

FootballMatchApiModel footballMatch() => FootballMatchApiModel(
  id: 42,
  date: DateTime(2026, 9, 1, 18),
  homeTeam: TeamApiModel(id: 10, name: 'Liščí Trus'),
  awayTeam: TeamApiModel(id: 11, name: 'Soupeř'),
  round: 3,
  league: LeagueApiModel(
    id: 5,
    name: 'Liga',
    rank: 1,
    organization: 'PKFL',
    organizationUnit: 'Praha',
    uri: 'liga',
    year: '2026',
    tableTeamIdList: const [],
    currentLeague: true,
  ),
  stadium: 'Hřiště',
  referee: 'Rozhodčí',
  urlResult: null,
  alreadyPlayed: false,
  matchIdAndAppTeamIdList: const [],
  homePlayerList: const [],
  awayPlayerList: const [],
);
