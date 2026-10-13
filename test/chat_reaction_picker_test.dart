import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trus_app/features/chat/chat_reaction_picker.dart';

void main() {
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
