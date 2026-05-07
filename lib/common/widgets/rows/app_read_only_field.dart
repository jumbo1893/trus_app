import 'package:flutter/material.dart';
import 'package:trus_app/theme/app_colors.dart';

class AppReadOnlyField extends StatelessWidget {
  final String value;
  final String? hint;
  final bool allowWrap;

  const AppReadOnlyField({
    super.key,
    required this.value,
    this.hint,
    this.allowWrap = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final textTheme = Theme.of(context).textTheme;

    final displayValue = value.trim().isEmpty ? (hint ?? "—") : value;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: colors.backgroundSecondary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        displayValue,
        maxLines: allowWrap ? null : 1,
        overflow: allowWrap ? null : TextOverflow.ellipsis,
        style: textTheme.bodyLarge?.copyWith(
          color: value.trim().isEmpty ? colors.textMuted : colors.textPrimary,
          height: 1.4,
        ),
      ),
    );
  }
}