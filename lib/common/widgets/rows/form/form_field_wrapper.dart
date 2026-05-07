import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';

class FormFieldWrapper extends StatelessWidget {
  final String label;
  final Widget child;
  final String? error;

  const FormFieldWrapper({
    super.key,
    required this.label,
    required this.child,
    this.error,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: textTheme.labelMedium,
        ),
        const SizedBox(height: 6),
        child,
        if (error != null) ...[
          const SizedBox(height: 6),
          Text(
            error!,
            style: textTheme.bodySmall?.copyWith(
              color: colors.errorForeground,
            ),
          ),
        ],
      ],
    );
  }
}