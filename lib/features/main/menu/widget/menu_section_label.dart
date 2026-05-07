import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';

class MenuSectionLabel extends StatelessWidget {
  final String text;

  const MenuSectionLabel({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.4,
          color: appColors.textSecondary,
        ),
      ),
    );
  }
}