import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trus_app/features/ai/widgets/trusbot_markdown_text.dart';

void main() {
  testWidgets('renders bold TrusBot markdown as selectable formatted text', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: TrusBotMarkdownText(
            data: 'Nejvíc gólů dal **Mazurka**.\n\n- 3 góly',
            color: Colors.black,
          ),
        ),
      ),
    );

    final markdown = tester.widget<MarkdownBody>(find.byType(MarkdownBody));
    expect(markdown.selectable, isTrue);

    final mazurkaSpan = tester
        .widgetList<SelectableText>(find.byType(SelectableText))
        .map((text) => text.textSpan)
        .whereType<TextSpan>()
        .map((span) => _findSpan(span, 'Mazurka'))
        .whereType<TextSpan>()
        .first;

    expect(mazurkaSpan.style?.fontWeight, FontWeight.w700);
    expect(
      find.textContaining('**Mazurka**', findRichText: true),
      findsNothing,
    );
    expect(find.textContaining('3 góly', findRichText: true), findsOneWidget);
  });

  testWidgets('does not load images embedded in an AI markdown answer', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: TrusBotMarkdownText(
            data: '![Týmové logo](https://example.test/logo.png)',
            color: Colors.black,
          ),
        ),
      ),
    );

    expect(find.byType(Image), findsNothing);
    expect(find.text('Týmové logo'), findsOneWidget);
  });
}

TextSpan? _findSpan(TextSpan span, String text) {
  if (span.text == text) return span;
  for (final child in span.children ?? const <InlineSpan>[]) {
    if (child case final TextSpan childSpan) {
      final result = _findSpan(childSpan, text);
      if (result != null) return result;
    }
  }
  return null;
}
