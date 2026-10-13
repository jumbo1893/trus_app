import 'package:flutter_test/flutter_test.dart';
import 'package:trus_app/features/chat/chat_repository.dart';
import 'package:trus_app/features/chat/chat_screen.dart';

void main() {
  test('last seen cursor appears after the latest read own message', () {
    ChatMessage message(int id, int authorId) => ChatMessage.fromJson({
      'id': id,
      'authorId': authorId,
      'author': 'User',
      'createdAt': '2026-10-13T10:00:00Z',
    });
    final detail = ChatDetail(
      [message(5, 1), message(4, 2), message(3, 2), message(2, 1)],
      [
        ChatReceipt.fromJson({
          'userId': 2,
          'name': 'Jan Novak',
          'lastMessageId': 4,
        }),
      ],
    );

    expect(seenOnOwnMessage(detail, 0, 1), isEmpty);
    expect(seenOnOwnMessage(detail, 3, 1).single.name, 'Jan Novak');
  });
}
