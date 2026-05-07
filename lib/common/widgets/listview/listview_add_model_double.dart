import 'package:flutter/material.dart';

import '../../../colors.dart';
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            blurRadius: 12,
            offset: Offset(0, 6),
            color: Colors.black12,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            addToString.toStringForListView(),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              height: 1.35,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 14),
          _DoubleCounterRow(
            label: 'Piva',
            icon: Icons.sports_bar,
            iconColor: blackColor,
            value: firstValue,
            onMinus: onFirstNumberRemoved,
            onPlus: onFirstNumberAdded,
          ),
          const SizedBox(height: 10),
          _DoubleCounterRow(
            label: 'Tvrdej',
            icon: Icons.liquor,
            iconColor: blackColor,
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
        color: Colors.black.withAlpha(6),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: Colors.white,
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
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Color(0xFF111827),
              ),
            ),
          ),
          _MiniStepperButton(
            icon: Icons.remove,
            color: Colors.redAccent,
            onTap: onMinus,
          ),
          Container(
            width: 40,
            alignment: Alignment.center,
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF111827),
              ),
            ),
          ),
          _MiniStepperButton(
            icon: Icons.add,
            color: Colors.green,
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
      color: Colors.white,
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