import 'package:flutter/material.dart';

import '../../../colors.dart';
import '../../../models/api/interfaces/add_to_string.dart';

class ListviewAddModelDouble extends StatelessWidget {
  final AddToString addToString;
  final double padding;

  final VoidCallback onFirstNumberAdded;
  final VoidCallback onFirstNumberRemoved;
  final VoidCallback onSecondNumberAdded;
  final VoidCallback onSecondNumberRemoved;

  const ListviewAddModelDouble({
    Key? key,
    required this.padding,
    required this.onFirstNumberAdded,
    required this.onFirstNumberRemoved,
    required this.onSecondNumberAdded,
    required this.onSecondNumberRemoved,
    required this.addToString,
  }) : super(key: key);

  Widget _icon(IconData icon, Color color, VoidCallback onPressed) {
    return IconButton(
      icon: Icon(icon, color: color),
      onPressed: onPressed,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints.tightFor(width: 36, height: 36),
    );
  }

  Widget _numberBox(String value) {
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        value,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQueryData.fromView(WidgetsBinding.instance.window).size;
    final sizeFragment = size / 30;

    final firstValue = addToString.numberToString(true);
    final secondValue = addToString.numberToString(false);

    return Row(
      children: [
        SizedBox(
          width: (sizeFragment.width * 9) - padding,
          child: Text(
            addToString.toStringForListView(),
            style: const TextStyle(fontSize: 16),
          ),
        ),
        SizedBox(width: sizeFragment.width * 1.5),

        // FIRST group
        SizedBox(width: sizeFragment.width * 2, child: _icon(Icons.sports_bar, blackColor, () {
          onFirstNumberRemoved();
        })),
        SizedBox(width: sizeFragment.width * 2, child: _icon(Icons.remove, Colors.red, () {
          onFirstNumberRemoved();
        })),
        SizedBox(
          width: sizeFragment.width * 3.0,
          child: _numberBox(firstValue),
        ),
        SizedBox(width: sizeFragment.width * 2, child: _icon(Icons.add, Colors.green, () {
          onFirstNumberAdded();
        })),

        SizedBox(width: sizeFragment.width),

        // SECOND group
        SizedBox(width: sizeFragment.width * 2, child: _icon(Icons.liquor, blackColor, () {
          onSecondNumberRemoved();
        })),
        SizedBox(width: sizeFragment.width * 2, child: _icon(Icons.remove, Colors.red, () {
          onSecondNumberRemoved();
        })),
        SizedBox(
          width: sizeFragment.width * 3.0,
          child: _numberBox(secondValue),
        ),
        SizedBox(width: sizeFragment.width * 2, child: _icon(Icons.add, Colors.green, () {
          onSecondNumberAdded();
        })),
      ],
    );
  }
}
