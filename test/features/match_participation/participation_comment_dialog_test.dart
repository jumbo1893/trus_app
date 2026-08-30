import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trus_app/features/match_participation/widgets/participation_comment_dialog.dart';

void main() {
  testWidgets('dialog owns controller until its overlay is disposed', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: _DialogHarness()));

    await tester.tap(find.text('Přidat komentář'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Dorazím později.');
    await tester.tap(find.text('Odeslat'));

    await tester.pump();
    expect(tester.takeException(), isNull);
    await tester.pumpAndSettle();

    expect(find.text('Uloženo: Dorazím později.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

class _DialogHarness extends StatefulWidget {
  const _DialogHarness();

  @override
  State<_DialogHarness> createState() => _DialogHarnessState();
}

class _DialogHarnessState extends State<_DialogHarness> {
  String? _comment;

  Future<void> _openDialog() async {
    final result = await ParticipationCommentDialog.show(
      context,
      title: 'Přidat komentář',
    );
    if (!mounted || result == null) return;
    setState(() => _comment = result);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          FilledButton(
            onPressed: _openDialog,
            child: const Text('Přidat komentář'),
          ),
          if (_comment != null) Text('Uloženo: $_comment'),
        ],
      ),
    );
  }
}
