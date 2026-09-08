import 'package:flutter/material.dart';

import 'package:trus_app/theme/app_colors.dart';
import '../../../models/api/interfaces/add_to_string.dart';

class ListviewAddModelDouble extends StatelessWidget {
  final AddToString addToString;
  final bool compact;
  final String? changeLabel;

  final VoidCallback onFirstNumberAdded;
  final VoidCallback onFirstNumberRemoved;
  final VoidCallback onSecondNumberAdded;
  final VoidCallback onSecondNumberRemoved;

  const ListviewAddModelDouble({
    super.key,
    this.compact = false,
    this.changeLabel,
    required this.onFirstNumberAdded,
    required this.onFirstNumberRemoved,
    required this.onSecondNumberAdded,
    required this.onSecondNumberRemoved,
    required this.addToString,
  });

  @override
  Widget build(BuildContext context) {
    if (compact) return _buildCompact(context);
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

  Widget _buildCompact(BuildContext context) {
    final player = addToString.toStringForListView();
    Widget counter(bool beer) => Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Tooltip(
          message: beer ? 'Piva' : 'Tvrdý alkohol',
          child: Icon(beer ? Icons.sports_bar : Icons.liquor, size: 18),
        ),
        IconButton(
          tooltip: '$player · ${beer ? 'ubrat pivo' : 'ubrat panáka'}',
          onPressed: beer ? onFirstNumberRemoved : onSecondNumberRemoved,
          constraints: const BoxConstraints.tightFor(width: 44, height: 44),
          style: IconButton.styleFrom(
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          padding: EdgeInsets.zero,
          icon: const Icon(Icons.remove, size: 20),
        ),
        ConstrainedBox(
          constraints: const BoxConstraints.tightFor(width: 24),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              addToString.numberToString(beer),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
        ),
        IconButton(
          tooltip: '$player · ${beer ? 'přidat pivo' : 'přidat panáka'}',
          onPressed: beer ? onFirstNumberAdded : onSecondNumberAdded,
          constraints: const BoxConstraints.tightFor(width: 44, height: 44),
          style: IconButton.styleFrom(
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          padding: EdgeInsets.zero,
          icon: const Icon(Icons.add, size: 20),
        ),
      ],
    );
    return Material(
      color: context.appColors.cardBackground,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    player,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                if (changeLabel != null) ...[
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      changeLabel!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                  ),
                ],
              ],
            ),
            Wrap(
              spacing: 4,
              runSpacing: 4,
              alignment: WrapAlignment.spaceBetween,
              children: [counter(true), counter(false)],
            ),
          ],
        ),
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
            child: Icon(icon, color: iconColor, size: 18),
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
          child: Icon(icon, color: color, size: 20),
        ),
      ),
    );
  }
}
