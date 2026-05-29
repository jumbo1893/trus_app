import 'package:flutter/material.dart';
import 'package:trus_app/theme/app_colors.dart';

class FakeInput extends StatelessWidget {
  final String text;
  final IconData? icon;
  const FakeInput({super.key, required this.text, this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: context.appColors.backgroundSecondary,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(child: Text(text)),
          if (icon != null)
            Icon(icon, size: 18),
        ],
      ),
    );
  }
}