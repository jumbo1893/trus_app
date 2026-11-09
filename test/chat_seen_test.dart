import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/features/chat/chat_repository.dart';
import 'package:trus_app/features/chat/chat_screen.dart';

void main() {
  test(
    'read cursor appears after the latest read message regardless of author',
    () {
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
          ChatReceipt.fromJson({'userId': 1, 'name': 'Me', 'lastMessageId': 5}),
        ],
      );

      expect(seenAtMessage(detail, 0, 1), isEmpty);
      expect(seenAtMessage(detail, 1, 1).single.name, 'Jan Novak');
      expect(seenAtMessage(detail, 2, 1), isEmpty);
      expect(seenAtMessage(detail, 3, 1).single.name, 'Eva');
      expect(readersAtMessage(detail, 0, 1), isEmpty);
      expect(readersAtMessage(detail, 1, 1).map((r) => r.name), ['Jan Novak']);
      expect(readersAtMessage(detail, 2, 1).map((r) => r.name), ['Jan Novak']);
      expect(readersAtMessage(detail, 3, 1).map((r) => r.name), [
        'Jan Novak',
        'Eva',
      ]);
    },
  );

  testWidgets('read avatars toggle to names and back', (tester) async {
    final message = ChatMessage.fromJson({
      'id': 6,
      'authorId': 1,
      'author': 'Já',
      'text': 'Ahoj',
      'createdAt': '2026-10-13T10:00:00Z',
    });
    final seen = [
      ChatReceipt.fromJson({'userId': 2, 'name': 'Pavel', 'lastMessageId': 6}),
    ];
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: ChatMessageTile(
              message: message,
              room: 'all',
              own: true,
              selected: false,
              seen: seen,
              onTap: () {},
              onLongPress: (_) {},
              onReactionsTap: () {},
            ),
          ),
        ),
      ),
    );

    expect(find.byKey(const ValueKey('chat_seen_names')), findsNothing);
    await tester.tap(find.byKey(const ValueKey('chat_seen_avatars')));
    await tester.pump();
    expect(find.text('Zobrazeno: Pavel'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('chat_seen_avatars')));
    await tester.pump();
    expect(find.byKey(const ValueKey('chat_seen_names')), findsNothing);
  });

  testWidgets('read avatars align to the right for incoming messages', (
    tester,
  ) async {
    final message = ChatMessage.fromJson({
      'id': 7,
      'authorId': 2,
      'author': 'Pavel',
      'text': 'Ahoj',
      'createdAt': '2026-10-13T10:00:00Z',
    });
    final seen = [
      ChatReceipt.fromJson({'userId': 3, 'name': 'Eva', 'lastMessageId': 7}),
    ];
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: ChatMessageTile(
              message: message,
              room: 'all',
              own: false,
              selected: false,
              seen: seen,
              onTap: () {},
              onLongPress: (_) {},
              onReactionsTap: () {},
            ),
          ),
        ),
      ),
    );

    final avatars = tester.getRect(
      find.byKey(const ValueKey('chat_seen_avatars')),
    );
    final tile = tester.getRect(find.byType(ChatMessageTile));
    expect(avatars.right, closeTo(tile.right - 7, 1));
  });

  testWidgets('selected message shows readers even without cursor avatars', (
    tester,
  ) async {
    final message = ChatMessage.fromJson({
      'id': 5,
      'authorId': 1,
      'author': 'Já',
      'text': 'Starší zpráva',
      'createdAt': '2026-10-13T10:00:00Z',
    });
    final readers = [
      ChatReceipt.fromJson({'userId': 2, 'name': 'Pavel', 'lastMessageId': 8}),
    ];
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: ChatMessageTile(
              message: message,
              room: 'all',
              own: true,
              selected: true,
              seen: const [],
              readers: readers,
              onTap: () {},
              onLongPress: (_) {},
              onReactionsTap: () {},
            ),
          ),
        ),
      ),
    );

    expect(find.text('Zobrazeno: Pavel'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('chat_seen_avatars')));
    await tester.pump();
    expect(find.byKey(const ValueKey('chat_seen_names')), findsNothing);
  });
}
