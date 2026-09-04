import 'package:flutter/material.dart';
import 'package:trus_app/theme/app_colors.dart';

import '../../../models/api/interfaces/add_to_string.dart';
import '../../../theme/app_widget_values.dart';

class ListviewAddModel extends StatelessWidget {
  final AddToString addToString;
  final bool goal;
  final VoidCallback onNumberAdded;
  final VoidCallback onNumberRemoved;
  final bool enabled;

  const ListviewAddModel({
    super.key,
    required this.onNumberAdded,
    required this.onNumberRemoved,
    this.goal = false,
    required this.addToString,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final value = addToString.numberToString(goal);

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      decoration: BoxDecoration(
        color: context.appColors.cardBackground,
        borderRadius: AppWidgetValues.borderRadiusXl,
        boxShadow: AppWidgetValues.cardShadow,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Text(
              addToString.toStringForListView(),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                height: 1.3,
                color: context.appColors.textPrimary,
              ),
            ),
          ),
          SizedBox(width: 10),
          if (enabled)
            _SingleStepperControl(
              value: value,
              onMinus: onNumberRemoved,
              onPlus: onNumberAdded,
            )
          else
            const Tooltip(
              message: "Historickou verzi pokuty nelze upravit",
              child: Icon(Icons.lock_outline_rounded),
            ),
        ],
      ),
    );
  }
}

class _SingleStepperControl extends StatelessWidget {
  final String value;
  final VoidCallback onMinus;
  final VoidCallback onPlus;

  const _SingleStepperControl({
    required this.value,
    required this.onMinus,
    required this.onPlus,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      decoration: BoxDecoration(
        color: context.appColors.cardBackground,
        borderRadius: AppWidgetValues.borderRadiusXl,
        boxShadow: AppWidgetValues.cardShadow,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _StepperButton(
            icon: Icons.remove,
            color: context.appColors.errorSolid,
            onTap: onMinus,
          ),
          Container(
            width: 36,
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
          _StepperButton(
            icon: Icons.add,
            color: context.appColors.successSolid,
            onTap: onPlus,
          ),
        ],
      ),
    );
  }
}

class _StepperButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _StepperButton({
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
          width: 32,
          height: 32,
          child: Icon(icon, color: color, size: 20),
        ),
      ),
    );
  }
}
