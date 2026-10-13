import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trus_app/features/main/widget/navigation_shell.dart';

void main() {
  testWidgets('chat badge uses 9+ at nine unread messages and opens chat', (
    tester,
  ) async {
    var opened = false;
    await tester.pumpWidget(
      MaterialApp(
        home: NavigationShell(
          screenId: 'home-screen',
          title: 'Přehled',
          selectedIndex: 0,
          onBack: () {},
          onHome: () {},
          onAccount: () {},
          onNotifications: () {},
          onDestination: (_) {},
          onChat: () => opened = true,
          chatUnread: 9,
          child: const SizedBox(),
        ),
      ),
    );
    expect(find.text('9+'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('chat_button')));
    expect(opened, isTrue);
  });
}
