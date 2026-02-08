import 'package:flutter/material.dart';

import '../../../models/api/interfaces/add_to_string.dart';

class ListviewAddModel extends StatelessWidget {
  final AddToString addToString;
  final bool goal;
  final double padding;
  final VoidCallback onNumberAdded;
  final VoidCallback onNumberRemoved;

  const ListviewAddModel({
    Key? key,
    required this.padding,
    required this.onNumberAdded,
    required this.onNumberRemoved,
    this.goal = false,
    required this.addToString,
  }) : super(key: key);

  Widget _numberBox(String value) {
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        value,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQueryData.fromView(WidgetsBinding.instance.window).size;
    final value = addToString.numberToString(goal);

    return Row(
      children: [
        SizedBox(
          width: (size.width / 1.5) - padding,
          child: Text(
            addToString.toStringForListView(),
            style: const TextStyle(fontSize: 16),
          ),
        ),
        const SizedBox(width: 21),

        SizedBox(
          width: (size.width / 9) - 7,
          child: IconButton(
            onPressed: onNumberRemoved,
            icon: const Icon(Icons.remove, color: Colors.red),
          ),
        ),

        SizedBox(
          width: (size.width / 9) - 7,
          child: _numberBox(value),
        ),

        SizedBox(
          width: (size.width / 9) - 7,
          child: IconButton(
            onPressed: onNumberAdded,
            icon: const Icon(Icons.add, color: Colors.green),
          ),
        ),
      ],
    );
  }
}
