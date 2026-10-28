import 'package:flutter_test/flutter_test.dart';
import 'package:trus_app/features/chat/chat_repository.dart';
import 'package:trus_app/features/chat/chat_screen.dart';

void main() {
  test('read cursor appears after the latest read message regardless of author', () {
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
        ChatReceipt.fromJson({
          'userId': 3,
          'name': 'Eva',
          'lastMessageId': 2,
        }),
        ChatReceipt.fromJson({
          'userId': 1,
          'name': 'Me',
          'lastMessageId': 5,
        }),
      ],
    );

    expect(seenAtMessage(detail, 0, 1), isEmpty);
    expect(seenAtMessage(detail, 1, 1).single.name, 'Jan Novak');
    expect(seenAtMessage(detail, 2, 1), isEmpty);
    expect(seenAtMessage(detail, 3, 1).single.name, 'Eva');
  });
}
