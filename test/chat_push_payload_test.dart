import 'package:flutter_test/flutter_test.dart';
import 'package:trus_app/models/api/notification/push/push_payload.dart';

void main() {
  test('chat push is recognized for silent foreground handling', () {
    final chat = PushPayload.fromData({
      'screenId': 'chat-screen',
      'room': 'players',
      'type': 'chat',
    });
    final other = PushPayload.fromData({'screenId': 'home-screen'});
    expect(chat.isChatMessage, isTrue);
    expect(other.isChatMessage, isFalse);
  });
}
