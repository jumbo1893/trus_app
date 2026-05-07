import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';

class MenuTile extends StatelessWidget {
  final IconData icon;
  final Color? iconColor;
  final Widget title;
  final VoidCallback onTap;

  const MenuTile({super.key,
    required this.icon,
    this.iconColor,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;
    final color = iconColor != null ? iconColor! : appColors.accent;
    return Padding(
      padding:
      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Material(
        color: Colors.black.withAlpha(8),
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: color.withAlpha(25),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(child: title),
                const Icon(Icons.chevron_right,
                    color: Colors.black38),
              ],
            ),
          ),
        ),
      ),
    );
  }
}