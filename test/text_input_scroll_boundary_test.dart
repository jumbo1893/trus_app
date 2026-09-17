import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trus_app/common/widgets/text_input_scroll_boundary.dart';

Widget app(Widget child, {TargetPlatform platform = TargetPlatform.iOS}) =>
    MaterialApp(
      theme: ThemeData(platform: platform),
      builder: (_, child) => TextInputScrollBoundary(child: child!),
      home: Scaffold(body: child),
    );

void main() {
  for (final platform in [TargetPlatform.iOS, TargetPlatform.android]) {
    testWidgets('page drag ends editing only on iOS ($platform)', (
      tester,
    ) async {
      final focus = FocusNode();
      final text = TextEditingController();
      addTearDown(focus.dispose);
      addTearDown(text.dispose);
      await tester.pumpWidget(
        app(
          SingleChildScrollView(
            child: Column(
              children: [
                TextField(focusNode: focus, controller: text),
                const SizedBox(height: 1500),
              ],
            ),
          ),
          platform: platform,
        ),
      );
      await tester.tap(find.byType(TextField));
      await tester.enterText(find.byType(TextField), 'Hledaný hráč');
      await tester.pump();
      expect(focus.hasFocus, isTrue);
      await tester.dragFrom(const Offset(250, 400), const Offset(0, -200));
      await tester.pumpAndSettle();
      expect(focus.hasFocus, platform != TargetPlatform.iOS);
      expect(text.text, 'Hledaný hráč');
      expect(tester.takeException(), isNull);
    });
  }
  testWidgets('automatic page scrolling does not interrupt typing', (
    tester,
  ) async {
    final focus = FocusNode();
    final scroll = ScrollController();
    addTearDown(focus.dispose);
    addTearDown(scroll.dispose);
    await tester.pumpWidget(
      app(
        SingleChildScrollView(
          controller: scroll,
          child: Column(
            children: [
              TextField(focusNode: focus),
              const SizedBox(height: 1500),
            ],
          ),
        ),
      ),
    );
    await tester.tap(find.byType(TextField));
    await tester.pump();
    scroll.jumpTo(60);
    await tester.pumpAndSettle();
    expect(focus.hasFocus, isTrue);
  });
  testWidgets('scrolling inside a multiline field preserves focus', (
    tester,
  ) async {
    final focus = FocusNode();
    final text = TextEditingController(
      text: List.generate(40, (i) => 'Řádek $i').join('\n'),
    );
    addTearDown(focus.dispose);
    addTearDown(text.dispose);
    await tester.pumpWidget(
      app(TextField(focusNode: focus, controller: text, maxLines: 3)),
    );
    await tester.tap(find.byType(TextField));
    await tester.pump();
    await tester.drag(find.byType(TextField), const Offset(0, -60));
    await tester.pumpAndSettle();
    expect(focus.hasFocus, isTrue);
    expect(tester.takeException(), isNull);
  });
  testWidgets('boundary also covers modal sheets outside Scaffold', (
    tester,
  ) async {
    final focus = FocusNode();
    addTearDown(focus.dispose);
    await tester.pumpWidget(
      app(
        Builder(
          builder: (context) => TextButton(
            onPressed: () => showModalBottomSheet<void>(
              context: context,
              isScrollControlled: true,
              builder: (_) => SizedBox(
                height: 500,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      TextField(focusNode: focus),
                      const SizedBox(height: 1500),
                    ],
                  ),
                ),
              ),
            ),
            child: const Text('Otevřít'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Otevřít'));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(TextField));
    await tester.pump();
    expect(focus.hasFocus, isTrue);
    await tester.dragFrom(const Offset(250, 450), const Offset(0, -150));
    await tester.pumpAndSettle();
    expect(focus.hasFocus, isFalse);
  });
}
