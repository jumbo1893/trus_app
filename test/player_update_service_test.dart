import 'package:flutter_test/flutter_test.dart';
import 'package:trus_app/services/ws/player_update_service.dart';

void main() {
  test('player stats websocket destination is scoped by team and player', () {
    expect(
      playerStatsDestination(playerId: 34, appTeamId: 12),
      '/topic/team/12/player/stats/34',
    );
  });
}
