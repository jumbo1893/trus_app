import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';

class TrusBotMarkdownText extends StatelessWidget {
  final String data;
  final Color color;

  const TrusBotMarkdownText({
    super.key,
    required this.data,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final baseStyle = (textTheme.bodyMedium ?? const TextStyle()).copyWith(
      color: color,
      height: 1.4,
    );

    return MarkdownBody(
      data: data,
      selectable: true,
      softLineBreak: true,
      imageBuilder: (_, _, alt) => Text(
        alt == null || alt.isBlank ? '[obrázek]' : alt,
        style: baseStyle,
      ),
      styleSheet: MarkdownStyleSheet.fromTheme(theme).copyWith(
        p: baseStyle,
        strong: baseStyle.copyWith(fontWeight: FontWeight.w700),
        em: baseStyle.copyWith(fontStyle: FontStyle.italic),
        del: baseStyle.copyWith(decoration: TextDecoration.lineThrough),
        listBullet: baseStyle,
        blockquote: baseStyle,
        code: baseStyle.copyWith(
          fontFamily: 'monospace',
          backgroundColor: color.withValues(alpha: 0.08),
        ),
        h1: textTheme.titleLarge?.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
        ),
        h2: textTheme.titleMedium?.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
        ),
        h3: textTheme.titleSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
        ),
        blockSpacing: 8,
        listIndent: 22,
      ),
    );
  }
}

extension on String {
  bool get isBlank => trim().isEmpty;
}
