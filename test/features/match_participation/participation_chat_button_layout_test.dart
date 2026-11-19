import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trus_app/features/match_participation/screens/match_participation_screen.dart';
import 'package:trus_app/theme/app_theme.dart';

void main() {
  testWidgets('chat button fills participation width with app theme', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: Scaffold(
          body: SizedBox(
            width: 328,
            child: Column(
              children: [
                const TextButton(
                  onPressed: null,
                  child: Text('Zadat za někoho jiného'),
                ),
                SizedBox(
                  width: double.infinity,
                  child: ParticipationChatButton(unread: 3, onPressed: () {}),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.text('Chat (3)'), findsOneWidget);
    expect(tester.getSize(find.byType(OutlinedButton)).width, 328);
  });
}
