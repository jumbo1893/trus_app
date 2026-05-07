import 'package:flutter/material.dart';
import 'package:trus_app/theme/app_colors.dart';

class AppWarningBox extends StatelessWidget {
  final String text;
  final IconData icon;

  const AppWarningBox({
    super.key,
    required this.text,
    this.icon = Icons.warning_amber_rounded,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.warningBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: colors.warningForeground,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: textTheme.bodySmall?.copyWith(
                color: colors.warningForeground,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}