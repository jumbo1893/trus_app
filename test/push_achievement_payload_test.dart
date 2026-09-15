import 'package:flutter_test/flutter_test.dart';
import 'package:trus_app/models/api/notification/push/push_payload.dart';
import 'package:trus_app/models/api/achievement/player_achievement_api_model.dart';

void main() {
  test('single award payload retains awarded-record identity', () {
    final payload = PushPayload.fromData({
      'screenId': 'view-player-achievement-detail-screen',
      'playerAchievementId': '123', 'playerId': '7', 'appTeamId': '2',
    });
    expect(payload.playerAchievementId, 123);
    expect(payload.playerId, 7);
    expect(payload.appTeamId, 2);
    expect(PlayerAchievementApiModel.reference(payload.playerAchievementId!).id, 123);
  });
  test('old profile and participation notifications stay compatible', () {
    expect(PushPayload.fromData({'screenId': 'view-player-screen', 'playerId': 7}).playerAchievementId, isNull);
    final payload = PushPayload.fromData({'screenId': 'match-participation-screen', 'footballMatchId': '20'});
    expect(payload.footballMatchId, 20);
    expect(payload.hasNavigationTarget, isTrue);
  });
}
