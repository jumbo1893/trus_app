import 'package:flutter/material.dart';

import '../../../colors.dart';
import '../../../models/api/interfaces/add_to_string.dart';

class ListviewAddModelDouble extends StatefulWidget {
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

  @override
  State<ListviewAddModelDouble> createState() => _ListviewAddModelDoubleState();
}

class _ListviewAddModelDoubleState extends State<ListviewAddModelDouble> {
  TextEditingController firstTextEditingController = TextEditingController();
  TextEditingController secondTextEditingController = TextEditingController();

  @override
  void dispose() {
    firstTextEditingController.dispose();
    secondTextEditingController.dispose();
    super.dispose();
  }

  void refreshText() {
    firstTextEditingController.text = widget.addToString.numberToString(true);
    secondTextEditingController.text = widget.addToString.numberToString(false);
  }

  void sendFirstCallback(bool added) {
    if (added) {
      widget.onFirstNumberAdded();
    } else {
      widget.onFirstNumberRemoved();
    }
  }

  void sendSecondCallback(bool added) {
    if (added) {
      widget.onSecondNumberAdded();
    } else {
      widget.onSecondNumberRemoved();
    }
  }

  Widget buildIconButton(IconData icon, Color color, VoidCallback onPressed) {
    return IconButton(
      icon: Icon(icon, color: color),
      onPressed: onPressed,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints.tightFor(width: 36, height: 36),
    );
  }

  @override
  Widget build(BuildContext context) {
    firstTextEditingController.text = widget.addToString.numberToString(true);
    secondTextEditingController.text = widget.addToString.numberToString(false);

    final size = MediaQueryData.fromView(WidgetsBinding.instance.window).size;
    final sizeFragment = size / 30;

    return Row(
      children: [
        SizedBox(
          width: (sizeFragment.width * 9) - widget.padding,
          child: Text(
            widget.addToString.toStringForListView(),
            style: const TextStyle(fontSize: 16),
          ),
        ),
        SizedBox(width: sizeFragment.width * 1.5),

        // First group
        SizedBox(width: sizeFragment.width * 2, child: buildIconButton(Icons.sports_bar, blackColor, () {
          sendFirstCallback(false);
          refreshText();
        })),
        SizedBox(width: sizeFragment.width * 2, child: buildIconButton(Icons.remove, Colors.red, () {
          sendFirstCallback(false);
          refreshText();
        })),
        SizedBox(
          width: sizeFragment.width * 2.5,
          child: TextField(
            textAlign: TextAlign.center,
            controller: firstTextEditingController,
            decoration: const InputDecoration(
              enabled: false,
              border: InputBorder.none,
              floatingLabelStyle: TextStyle(color: blackColor),
              contentPadding: EdgeInsets.only(left: 10),
            ),
          ),
        ),
        SizedBox(width: sizeFragment.width * 2, child: buildIconButton(Icons.add, Colors.green, () {
          sendFirstCallback(true);
          refreshText();
        })),

        SizedBox(width: sizeFragment.width),

        // Second group
        SizedBox(width: sizeFragment.width * 2, child: buildIconButton(Icons.liquor, blackColor, () {
          sendSecondCallback(false);
          refreshText();
        })),
        SizedBox(width: sizeFragment.width * 2, child: buildIconButton(Icons.remove, Colors.red, () {
          sendSecondCallback(false);
          refreshText();
        })),
        SizedBox(width: sizeFragment.width),
        SizedBox(
          width: sizeFragment.width * 1.5,
          child: TextField(
            textAlign: TextAlign.center,
            controller: secondTextEditingController,
            decoration: const InputDecoration(
              enabled: false,
              border: InputBorder.none,
              floatingLabelStyle: TextStyle(color: blackColor),
            ),
          ),
        ),
        SizedBox(width: sizeFragment.width * 2, child: buildIconButton(Icons.add, Colors.green, () {
          sendSecondCallback(true);
          refreshText();
        })),
      ],
    );
  }
}
