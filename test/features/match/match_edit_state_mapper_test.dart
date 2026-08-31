import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trus_app/features/match/controller/edit/match_edit_state_mapper.dart';
import 'package:trus_app/features/match/state/footbal_match_detail_state.dart';
import 'package:trus_app/features/match/state/match_edit_state.dart';
import 'package:trus_app/features/match/state/match_stats_state.dart';
import 'package:trus_app/models/api/football/football_match_api_model.dart';
import 'package:trus_app/models/api/match/match_setup.dart';
import 'package:trus_app/models/api/player/player_api_model.dart';
import 'package:trus_app/models/api/season_api_model.dart';
import 'package:trus_app/models/enum/match_detail_options.dart';

void main() {
  test('match setup parses attending players and fans', () {
    final setup = MatchSetup.fromJson({
      'match': null,
      'footballMatch': null,
      'seasonList': [seasonJson()],
      'playerList': [playerJson(1, fan: false)],
      'fanList': [playerJson(2, fan: true)],
      'attendingPlayers': [playerJson(1, fan: false)],
      'attendingFans': [playerJson(2, fan: true)],
      'primarySeason': seasonJson(),
    });

    expect(setup.attendingPlayers.single.id, 1);
    expect(setup.attendingFans.single.id, 2);
    expect(setup.attendingFans.single.fan, isTrue);
  });

  test('new match preselects attending players and fans from setup', () {
    final player = playerModel(1, fan: false);
    final fan = playerModel(2, fan: true);
    final otherPlayer = playerModel(3, fan: false);
    final season = SeasonApiModel(
      id: 1,
      name: '2026/2027',
      fromDate: DateTime(2026, 7, 1),
      toDate: DateTime(2027, 6, 30),
    );
    final setup = MatchSetup(
      seasonList: [season],
      playerList: [player, otherPlayer],
      fanList: [fan],
      attendingPlayers: [playerModel(1, fan: false)],
      attendingFans: [playerModel(2, fan: true)],
      primarySeason: season,
    );

    final mapped = const MatchEditStateMapper().applyStateByFootballMatch(
      initialState(),
      footballMatch: FootballMatchApiModel.noMatch(),
      userTeamId: 10,
      setup: setup,
    );

    expect(mapped.selectedPlayers, equals([player]));
    expect(mapped.selectedFans, equals([fan]));
    expect(mapped.selectedPlayers, isNot(contains(otherPlayer)));
    expect(identical(mapped.selectedPlayers.single, player), isTrue);
    expect(identical(mapped.selectedFans.single, fan), isTrue);
  });
}

PlayerApiModel playerModel(int id, {required bool fan}) => PlayerApiModel(
  id: id,
  name: 'Osoba $id',
  birthday: DateTime(2000, 1, 1),
  fan: fan,
  active: true,
);

MatchEditState initialState() => MatchEditState(
  name: '',
  date: DateTime(2026, 9, 1),
  home: true,
  homeGoalNumber: null,
  awayGoalNumber: null,
  seasons: const AsyncValue.data([]),
  selectedSeason: null,
  allPlayers: const [],
  selectedPlayers: const [],
  allFans: const [],
  selectedFans: const [],
  footballMatch: null,
  matchOptions: const [MatchDetailOptions.editMatch],
  initialTab: MatchDetailOptions.editMatch,
  footballMatchDetailState: FootballMatchDetailState.init(),
  matchStatsState: MatchStatsState.init(),
  weather: '',
);

Map<String, dynamic> playerJson(int id, {required bool fan}) => {
  'id': id,
  'name': 'Osoba $id',
  'birthday': '2000-01-01T00:00:00.000Z',
  'fan': fan,
  'active': true,
};

Map<String, dynamic> seasonJson() => {
  'id': 1,
  'name': '2026/2027',
  'fromDate': '2026-07-01T00:00:00.000Z',
  'toDate': '2027-06-30T00:00:00.000Z',
};
