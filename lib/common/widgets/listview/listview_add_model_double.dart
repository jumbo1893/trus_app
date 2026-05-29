import 'package:flutter/material.dart';

import 'package:trus_app/theme/app_colors.dart';
import '../../../models/api/interfaces/add_to_string.dart';

class ListviewAddModelDouble extends StatelessWidget {
  final AddToString addToString;

  final VoidCallback onFirstNumberAdded;
  final VoidCallback onFirstNumberRemoved;
  final VoidCallback onSecondNumberAdded;
  final VoidCallback onSecondNumberRemoved;

  const ListviewAddModelDouble({
    super.key,
    required this.onFirstNumberAdded,
    required this.onFirstNumberRemoved,
    required this.onSecondNumberAdded,
    required this.onSecondNumberRemoved,
    required this.addToString,
  });

  @override
  Widget build(BuildContext context) {
    final firstValue = addToString.numberToString(true);
    final secondValue = addToString.numberToString(false);

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      decoration: BoxDecoration(
        color: context.appColors.cardBackground,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            blurRadius: 12,
            offset: const Offset(0, 6),
            color: context.appColors.shadow.withAlpha(31),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            addToString.toStringForListView(),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              height: 1.35,
              color: context.appColors.textPrimary,
            ),
          ),
          const SizedBox(height: 14),
          _DoubleCounterRow(
            label: 'Piva',
            icon: Icons.sports_bar,
            iconColor: context.appColors.buttonForeground,
            value: firstValue,
            onMinus: onFirstNumberRemoved,
            onPlus: onFirstNumberAdded,
          ),
          const SizedBox(height: 10),
          _DoubleCounterRow(
            label: 'Tvrdej',
            icon: Icons.liquor,
            iconColor: context.appColors.buttonForeground,
            value: secondValue,
            onMinus: onSecondNumberRemoved,
            onPlus: onSecondNumberAdded,
          ),
        ],
      ),
    );
  }
}

class _DoubleCounterRow extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color iconColor;
  final String value;
  final VoidCallback onMinus;
  final VoidCallback onPlus;

  const _DoubleCounterRow({
    required this.label,
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.onMinus,
    required this.onPlus,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: context.appColors.shadow.withAlpha(6),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: context.appColors.cardBackground,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 18,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: context.appColors.textPrimary,
              ),
            ),
          ),
          _MiniStepperButton(
            icon: Icons.remove,
            color: context.appColors.errorSolid,
            onTap: onMinus,
          ),
          Container(
            width: 40,
            alignment: Alignment.center,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: context.appColors.textPrimary,
              ),
            ),
          ),
          _MiniStepperButton(
            icon: Icons.add,
            color: context.appColors.successSolid,
            onTap: onPlus,
          ),
        ],
      ),
    );
  }
}

class _MiniStepperButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _MiniStepperButton({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.appColors.cardBackground,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: SizedBox(
          width: 34,
          height: 34,
          child: Icon(
            icon,
            color: color,
            size: 20,
          ),
        ),
      ),
    );
  }
}