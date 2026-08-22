import 'package:flutter/material.dart';
import 'package:trus_app/theme/app_colors.dart';

class MenuTile extends StatelessWidget {
  final IconData icon;
  final Widget? iconWidget;
  final Color? iconColor;
  final Widget title;
  final VoidCallback onTap;

  const MenuTile({
    super.key,
    required this.icon,
    this.iconWidget,
    this.iconColor,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;
    final color = iconColor != null ? iconColor! : appColors.accent;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Material(
        color: context.appColors.shadow.withAlpha(8),
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: color.withAlpha(25),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: iconWidget ?? Icon(icon, color: color, size: 20),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(child: title),
                Icon(Icons.chevron_right, color: appColors.textSecondary),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
