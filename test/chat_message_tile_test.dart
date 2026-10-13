import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:trus_app/features/chat/chat_repository.dart';
import 'package:trus_app/features/chat/chat_screen.dart';

void main() {
  testWidgets('TrusBot message has a distinct sender icon', (tester) async {
    var taps = 0;
    var longPresses = 0;
    final message = ChatMessage.fromJson({
      'id': 15,
      'authorId': 0,
      'author': 'TrusBot',
      'text': 'TrusBot: Letos zatím **42 piv**.',
      'bot': true,
      'createdAt': '2026-10-13T10:00:00Z',
    });
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ChatMessageTile(
            message: message,
            room: 'all',
            own: false,
            selected: false,
            seen: const [],
            onTap: () => taps++,
            onLongPress: (_) => longPresses++,
            onReactionsTap: () {},
          ),
        ),
      ),
    );
    expect(find.text('TrusBot'), findsOneWidget);
    expect(find.byKey(const ValueKey('chat-bot-icon')), findsOneWidget);
    expect(message.displayText, 'Letos zatím **42 piv**.');
    expect(find.byType(MarkdownBody), findsOneWidget);
    expect(find.textContaining('Letos zatím 42 piv.'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('chat-bubble-15')));
    await tester.pump();
    expect(taps, 1);
    await tester.longPress(find.byKey(const ValueKey('chat-bubble-15')));
    await tester.pump();
    expect(longPresses, 1);
  });

  testWidgets('name stays above bubble and time toggles for one message', (
    tester,
  ) async {
    ChatMessage message(int id, String author) => ChatMessage.fromJson({
      'id': id,
      'authorId': id,
      'author': author,
      'text': 'Zpráva $id',
      'createdAt': '2026-10-13T10:00:00Z',
      'reactions': const [],
    });
    int? selected;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) => Column(
              children: [
                for (final id in [1, 2])
                  ChatMessageTile(
                    message: message(id, id == 1 ? 'Kuba' : 'Petr'),
                    room: 'players',
                    own: false,
                    selected: selected == id,
                    seen: const [],
                    onTap: () =>
                        setState(() => selected = selected == id ? null : id),
                    onLongPress: (_) {},
                    onReactionsTap: () {},
                  ),
              ],
            ),
          ),
        ),
      ),
    );

    expect(find.text('Kuba'), findsOneWidget);
    expect(find.text('Petr'), findsOneWidget);
    expect(find.byKey(const ValueKey('chat-time-1')), findsNothing);
    await tester.tap(find.byKey(const ValueKey('chat-bubble-1')));
    await tester.pump();
    expect(find.byKey(const ValueKey('chat-time-1')), findsOneWidget);
    expect(
      tester.getCenter(find.byKey(const ValueKey('chat-time-1'))).dx,
      closeTo(400, 1),
    );
    await tester.tap(find.byKey(const ValueKey('chat-bubble-2')));
    await tester.pump();
    expect(find.byKey(const ValueKey('chat-time-1')), findsNothing);
    expect(find.byKey(const ValueKey('chat-time-2')), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('chat-bubble-2')));
    await tester.pump();
    expect(find.byKey(const ValueKey('chat-time-2')), findsNothing);
  });

  testWidgets('image is displayed outside the text bubble', (tester) async {
    final message = ChatMessage.fromJson({
      'id': 4,
      'authorId': 2,
      'author': 'Kuba',
      'text': 'Popisek',
      'image': true,
      'createdAt': '2026-10-13T10:00:00Z',
    });
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ChatMessageTile(
            message: message,
            room: 'all',
            own: false,
            selected: false,
            seen: const [],
            onTap: () {},
            onLongPress: (_) {},
            onReactionsTap: () {},
            imageBuilder: (_, __) => const SizedBox(
              key: ValueKey('fake-image'),
              width: 80,
              height: 80,
            ),
          ),
        ),
      ),
    );

    expect(find.byType(Card), findsOneWidget);
    expect(
      find.descendant(of: find.byType(Card), matching: find.text('Popisek')),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byType(Card),
        matching: find.byKey(const ValueKey('fake-image')),
      ),
      findsNothing,
    );
    expect(find.byKey(const ValueKey('chat-image-4')), findsOneWidget);
  });

  testWidgets('long press and reaction badge have separate actions', (
    tester,
  ) async {
    final message = ChatMessage.fromJson({
      'id': 3,
      'authorId': 2,
      'author': 'Kuba',
      'text': 'Ahoj',
      'createdAt': '2026-10-13T10:00:00Z',
      'reactions': [
        {'userId': 7, 'name': 'Jan Novák', 'emoji': '❤️'},
      ],
    });
    var longPresses = 0;
    var reactionTaps = 0;
    Rect? anchor;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ChatMessageTile(
            message: message,
            room: 'all',
            own: false,
            selected: false,
            seen: const [],
            onTap: () {},
            onLongPress: (rect) {
              longPresses++;
              anchor = rect;
            },
            onReactionsTap: () => reactionTaps++,
          ),
        ),
      ),
    );

    await tester.longPress(find.byKey(const ValueKey('chat-bubble-3')));
    expect(longPresses, 1);
    expect(anchor!.width, greaterThan(0));
    expect(anchor!.height, greaterThan(0));
    await tester.tap(find.byKey(const ValueKey('chat-reactions-3')));
    expect(reactionTaps, 1);
  });
}
