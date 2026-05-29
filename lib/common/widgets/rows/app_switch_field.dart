import 'package:flutter/material.dart';
import 'package:trus_app/theme/app_colors.dart';

class AppSwitchField extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final String text;

  const AppSwitchField({
    super.key,
    required this.value,
    required this.onChanged,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: context.appColors.shadow.withAlpha(6),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 15,
                color: context.appColors.textPrimary,
              ),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}