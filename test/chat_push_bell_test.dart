import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trus_app/features/chat/chat_repository.dart';
import 'package:trus_app/features/chat/chat_screen.dart';

void main() {
  testWidgets('bell shows saved room push state and toggles independently', (
    tester,
  ) async {
    final all = ChatRoom.fromJson({
      'kind': 'all',
      'title': 'Hromadný chat',
      'unread': 0,
      'pushEnabled': true,
    });
    final players = ChatRoom.fromJson({
      'kind': 'players',
      'title': 'Hráčský chat',
      'unread': 0,
      'pushEnabled': false,
    });
    var toggled = '';
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Row(
            children: [
              ChatPushBell(
                room: all,
                updating: false,
                onPressed: () => toggled = 'all',
              ),
              ChatPushBell(
                room: players,
                updating: false,
                onPressed: () => toggled = 'players',
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.byIcon(Icons.notifications_outlined), findsOneWidget);
    expect(find.byIcon(Icons.notifications_off_outlined), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('chat-push-players')));
    expect(toggled, 'players');
  });
}
