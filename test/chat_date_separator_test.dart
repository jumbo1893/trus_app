import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trus_app/features/chat/chat_repository.dart';
import 'package:trus_app/features/chat/chat_screen.dart';

void main() {
  ChatMessage message(int id, String time) => ChatMessage.fromJson({
    'id': id,
    'authorId': 2,
    'author': 'Kuba',
    'text': 'Zpráva',
    'createdAt': time,
  });

  test('date starts a conversation after at least one hour of silence', () {
    final detail = ChatDetail([
      message(4, '2026-10-13T12:59:00Z'),
      message(3, '2026-10-13T12:00:00Z'),
      message(2, '2026-10-13T11:00:00Z'),
      message(1, '2026-10-13T10:59:00Z'),
    ], const []);

    expect(beginsConversationAfterPause(detail, 0), isFalse);
    expect(beginsConversationAfterPause(detail, 1), isTrue);
    expect(beginsConversationAfterPause(detail, 2), isFalse);
    expect(beginsConversationAfterPause(detail, 3), isTrue);
  });

  testWidgets('date separator is centered above its message', (tester) async {
    final item = message(2, '2026-10-13T11:00:00Z');
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              ChatDateSeparator(message: item),
              ChatMessageTile(
                message: item,
                room: 'all',
                own: false,
                selected: false,
                seen: const [],
                onTap: () {},
                onLongPress: (_) {},
                onReactionsTap: () {},
              ),
            ],
          ),
        ),
      ),
    );

    final separator = find.byKey(const ValueKey('chat-date-2'));
    expect(separator, findsOneWidget);
    expect(
      tester.getCenter(separator).dy,
      lessThan(
        tester.getCenter(find.byKey(const ValueKey('chat-bubble-2'))).dy,
      ),
    );
    expect(tester.getCenter(separator).dx, closeTo(400, 1));
  });
}
