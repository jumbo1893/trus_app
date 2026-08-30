import 'package:flutter_test/flutter_test.dart';
import 'package:trus_app/models/api/participation/match_participation_detail.dart';
import 'package:trus_app/models/api/participation/match_participation_prompt.dart';
import 'package:trus_app/models/api/participation/match_participation_status.dart';

void main() {
  test('participation prompt parses maybe reconsideration', () {
    final prompt = MatchParticipationPrompt.fromJson({
      'footballMatch': footballMatchJson(),
      'currentPlayer': playerJson(1, 'Matěj'),
      'currentStatus': 'MAYBE',
      'reconsideration': true,
      'eligiblePlayers': [],
    });

    expect(prompt.footballMatch.id, 42);
    expect(prompt.currentPlayer?.name, 'Matěj');
    expect(prompt.currentStatus, MatchParticipationStatus.maybe);
    expect(prompt.reconsideration, isTrue);
  });

  test(
    'participation detail separates players, fans and parses discussion',
    () {
      final detail = MatchParticipationDetail.fromJson({
        'footballMatch': footballMatchJson(),
        'currentPlayer': playerJson(1, 'Matěj'),
        'currentStatus': 'ATTENDING',
        'attendingPlayers': [
          {
            'player': playerJson(1, 'Matěj'),
            'comments': [
              {
                'id': 7,
                'author': playerJson(1, 'Matěj'),
                'text': 'Dorazím později.',
                'createdAt': '2026-08-28T12:00:00Z',
                'upVotes': 2,
                'downVotes': 0,
                'currentUserReaction': 'UP',
                'replies': [],
              },
            ],
          },
        ],
        'attendingFans': [
          {'player': playerJson(2, 'Petr', fan: true), 'comments': []},
        ],
        'maybePlayers': [
          {'player': playerJson(3, 'Karel'), 'comments': []},
        ],
        'maybeFans': [],
        'notAttendingPlayers': [
          {'player': playerJson(4, 'Tomáš'), 'comments': []},
        ],
        'notAttendingFans': [],
        'eligiblePlayers': [],
      });

      expect(detail.currentStatus, MatchParticipationStatus.attending);
      expect(detail.attendingPlayers.single.player.name, 'Matěj');
      expect(detail.attendingFans.single.player.fan, isTrue);
      expect(detail.maybePlayers.single.player.name, 'Karel');
      expect(detail.notAttendingPlayers.single.player.name, 'Tomáš');
      expect(detail.attendingPlayers.single.comments.single.upVotes, 2);
      expect(
        detail
            .attendingPlayers
            .single
            .comments
            .single
            .currentUserReaction
            ?.name,
        'up',
      );
    },
  );
}

Map<String, dynamic> playerJson(int id, String name, {bool fan = false}) => {
  'id': id,
  'name': name,
  'birthday': '2000-01-01T00:00:00.000Z',
  'fan': fan,
  'active': true,
};

Map<String, dynamic> footballMatchJson() => {
  'id': 42,
  'date': '2026-09-01T18:00:00.000Z',
  'homeTeam': {'id': 10, 'name': 'Liščí Trus'},
  'awayTeam': {'id': 11, 'name': 'Soupeř'},
  'round': 3,
  'league': {
    'id': 5,
    'name': 'Liga',
    'rank': 1,
    'organization': 'PKFL',
    'organizationUnit': 'Praha',
    'uri': 'liga',
    'year': '2026',
    'tableTeamIdList': <int>[],
    'currentLeague': true,
  },
  'stadium': 'Hřiště',
  'referee': 'Rozhodčí',
  'homeGoalNumber': null,
  'awayGoalNumber': null,
  'urlResult': null,
  'refereeComment': null,
  'alreadyPlayed': false,
  'matchIdAndAppTeamIdList': [],
  'homePlayerList': [],
  'awayPlayerList': [],
};
