import 'package:flutter/material.dart';
import 'package:trus_app/theme/app_colors.dart';

class ToggleMode extends StatelessWidget {
  final bool secondChoice;
  final ValueChanged<bool> onChanged;

  final String firstLabel;
  final String secondLabel;

  final Widget? firstIconWidget;
  final Widget? secondIconWidget;

  final IconData? firstIcon;
  final IconData? secondIcon;

  const ToggleMode({
    super.key,
    required this.secondChoice,
    required this.onChanged,
    required this.firstLabel,
    required this.secondLabel,
    this.firstIconWidget,
    this.secondIconWidget,
    this.firstIcon,
    this.secondIcon,
  }) : assert(
  firstIconWidget != null || firstIcon != null,
  'Musíš zadat firstIconWidget nebo firstIcon',
  ),
        assert(
        secondIconWidget != null || secondIcon != null,
        'Musíš zadat secondIconWidget nebo secondIcon',
        );

  Widget _buildIcon(BuildContext context, {
    required bool selected,
    Widget? iconWidget,
    IconData? iconData,
  }) {
    final color = selected ? context.appColors.textPrimary : context.appColors.textSecondary;

    if (iconWidget != null) {
      return iconWidget;
    }

    return Icon(
      iconData,
      size: 18,
      color: color,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: context.appColors.shadow.withAlpha(8),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Expanded(
            child: _ModeButton(
              label: firstLabel,
              icon: _buildIcon(context,
                selected: !secondChoice,
                iconWidget: firstIconWidget,
                iconData: firstIcon,
              ),
              selected: !secondChoice,
              onTap: () => onChanged(false),
            ),
          ),
          Expanded(
            child: _ModeButton(
              label: secondLabel,
              icon: _buildIcon(context,
                selected: secondChoice,
                iconWidget: secondIconWidget,
                iconData: secondIcon,
              ),
              selected: secondChoice,
              onTap: () => onChanged(true),
            ),
          ),
        ],
      ),
    );
  }
}

class _ModeButton extends StatelessWidget {
  final String label;
  final Widget icon;
  final bool selected;
  final VoidCallback onTap;

  const _ModeButton({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = selected ? context.appColors.textPrimary : context.appColors.textSecondary;

    return Material(
      color: selected ? context.appColors.cardBackground : Colors.transparent,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              icon,
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}