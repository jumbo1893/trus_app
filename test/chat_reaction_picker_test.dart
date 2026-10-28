import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trus_app/features/chat/chat_reaction_picker.dart';

void main() {
  testWidgets('long press menu offers reply, copy and TrusBot actions', (
    tester,
  ) async {
    var replies = 0;
    var copies = 0;
    var botQuestions = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ChatReactionPicker(
            anchor: const Rect.fromLTWH(100, 200, 150, 50),
            onSelected: (_) {},
            onDismiss: () {},
            onReply: () => replies++,
            onCopy: () => copies++,
            onAskBot: () => botQuestions++,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Odpovědět'), findsOneWidget);
    expect(find.text('Kopírovat'), findsOneWidget);
    expect(find.text('TrusBot'), findsOneWidget);
    final reply = tester.getTopLeft(find.text('Odpovědět'));
    final copy = tester.getTopLeft(find.text('Kopírovat'));
    final bot = tester.getTopLeft(find.text('TrusBot'));
    expect(reply.dx, lessThan(copy.dx));
    expect(copy.dx, lessThan(bot.dx));
    await tester.tap(find.text('Odpovědět'));
    await tester.pumpAndSettle();
    expect(replies, 1);
    expect(copies, 0);
    expect(botQuestions, 0);
  });

  testWidgets('reactions stay above actions for a message at the bottom', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ChatReactionPicker(
            anchor: const Rect.fromLTWH(90, 490, 160, 45),
            onSelected: (_) {},
            onDismiss: () {},
            onReply: () {},
            onCopy: () {},
            onAskBot: () {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final quick = tester.getBottomLeft(
      find.byKey(const ValueKey('chat_reaction_menu')),
    );
    final actions = tester.getTopLeft(
      find.byKey(const ValueKey('chat_message_actions')),
    );
    expect(quick.dy, lessThan(actions.dy));
    await tester.tap(find.byKey(const ValueKey('reaction_picker_more')));
    await tester.pumpAndSettle();
    final expanded = tester.getBottomLeft(
      find.byKey(const ValueKey('chat_reaction_menu')),
    );
    expect(expanded.dy, lessThan(actions.dy));
  });

  testWidgets('anchored picker expands and animates the chosen reaction', (
    tester,
  ) async {
    String? selected;
    var dismissals = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ChatReactionPicker(
            anchor: const Rect.fromLTWH(140, 400, 180, 50),
            onSelected: (emoji) => selected = emoji,
            onDismiss: () => dismissals++,
          ),
        ),
      ),
    );

    expect(find.byKey(const ValueKey('reaction_picker_quick')), findsOneWidget);
    expect(
      find.byKey(const ValueKey('reaction_picker_expanded')),
      findsNothing,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('reaction_picker_more')));
    await tester.pumpAndSettle();
    expect(
      find.byKey(const ValueKey('reaction_picker_expanded')),
      findsOneWidget,
    );
    await tester.tap(find.byKey(const ValueKey('reaction_choice_👍')));
    await tester.pumpAndSettle();
    expect(selected, '👍');
    expect(dismissals, 1);
  });
}
