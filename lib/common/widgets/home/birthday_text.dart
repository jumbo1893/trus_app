import 'package:flutter/material.dart';

import '../../../colors.dart';
import '../../../features/home/widget/home_section_card.dart';
import '../../../theme/app_colors.dart';

class BirthdayText extends StatelessWidget {
  const BirthdayText({
    super.key,
    required this.nextBirthdayText,
  });

  final String? nextBirthdayText;

  @override
  Widget build(BuildContext context) {
    if (nextBirthdayText == null || nextBirthdayText!.trim().isEmpty) {
      return const SizedBox.shrink();
    }
    final appColors = context.appColors;
    return HomeSectionCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: orangeColor.withAlpha(25),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              Icons.cake_rounded,
              color: appColors.accent,
              size: 26,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              nextBirthdayText!,
              key: const ValueKey('birthday_text'),
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: appColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}