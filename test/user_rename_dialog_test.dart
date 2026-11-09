import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trus_app/features/user/screens/view_user_screen.dart';
import 'package:trus_app/common/widgets/text_input_scroll_boundary.dart';

void main() {
  testWidgets('cancelling an edited name closes the dialog cleanly', (
    tester,
  ) async {
    String? result;
    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) =>
            TextInputScrollBoundary(child: child ?? const SizedBox.shrink()),
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () async {
                result = await showDialog<String>(
                  context: context,
                  builder: (_) =>
                      const RenameUserDialog(initialName: 'Původní'),
                );
              },
              child: const Text('Otevřít'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Otevřít'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Nové jméno');
    await tester.tap(find.text('Zrušit'));
    await tester.pumpAndSettle();

    expect(result, isNull);
    expect(find.byType(RenameUserDialog), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
