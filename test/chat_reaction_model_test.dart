import 'package:flutter_test/flutter_test.dart';
import 'package:trus_app/features/chat/chat_repository.dart';

void main() {
  test('reaction update changes only the target message data', () {
    final message = ChatMessage.fromJson({
      'id': 12,
      'authorId': 2,
      'author': 'Kuba',
      'text': 'Ahoj',
      'createdAt': '2026-10-13T10:00:00Z',
      'image': false,
      'reactions': const [],
    });
    final update = ChatReactionUpdate.fromJson({
      'messageId': 12,
      'reactions': [
        {'userId': 8, 'name': 'Petr Novák', 'emoji': '❤️'},
      ],
    });

    final reacted = ChatMessage.withReactions(message, update.reactions);
    expect(reacted.id, update.messageId);
    expect(reacted.text, message.text);
    expect(reacted.reactions.single.name, 'Petr Novák');
    expect(message.reactions, isEmpty);
  });
}
