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
  const ListviewAddModelDouble(
      {Key? key,
      required this.padding,
      required this.onFirstNumberAdded,
      required this.onFirstNumberRemoved,
      required this.onSecondNumberAdded,
      required this.onSecondNumberRemoved,
      required this.addToString})
      : super(key: key);

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

  @override
  Widget build(BuildContext context) {
    firstTextEditingController.text = widget.addToString.numberToString(true);
    secondTextEditingController.text = widget.addToString.numberToString(false);
    final size = MediaQueryData.fromWindow(WidgetsBinding.instance.window).size;
    final sizeFragment = size / 30;
    return Row(
      children: [
        SizedBox(
            width: (sizeFragment.width * 9) - widget.padding,
            child: Text(widget.addToString.toStringForListView(),
                style: const TextStyle(fontSize: 16))),
        SizedBox(
          width: sizeFragment.width * 1.5,
        ),
        SizedBox(
            width: (sizeFragment.width * 2),
            child: IconButton(
              icon: const Icon(
                Icons.sports_bar,
                color: blackColor,
              ),
              onPressed: () {
                sendFirstCallback(false);
                refreshText();
              },
            )),

        SizedBox(
            width: (sizeFragment.width * 2),
            child: IconButton(
                onPressed: () {
                  sendFirstCallback(false);
                  refreshText();
                },
                icon: const Icon(
                  Icons.remove,
                  color: Colors.red,
                ))),
        SizedBox(
          width: (sizeFragment.width * 2.5),
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
        SizedBox(
            width: (sizeFragment.width * 2),
            child: IconButton(
                onPressed: () {
                  sendFirstCallback(true);
                  refreshText();
                },
                icon: const Icon(
                  Icons.add,
                  color: Colors.green,
                ))),
        SizedBox(width: sizeFragment.width),
        //druhá část
        SizedBox(
            width: (sizeFragment.width * 2),
            child: IconButton(
              icon: const Icon(
                Icons.liquor,
                color: blackColor,
              ),
              onPressed: () {
                sendSecondCallback(false);
                refreshText();
              },
            )),

        SizedBox(
            width: (sizeFragment.width * 2),
            child: IconButton(
                onPressed: () {
                  sendSecondCallback(false);
                  refreshText();
                },
                icon: const Icon(
                  Icons.remove,
                  color: Colors.red,
                ))),
        SizedBox(
          width: sizeFragment.width,
        ),
        SizedBox(
          width: (sizeFragment.width * 1.5),
          child: TextField(
            textAlign: TextAlign.center,
            controller: secondTextEditingController,
            decoration: const InputDecoration(
              enabled: false,
              border: InputBorder.none,
              floatingLabelStyle: TextStyle(color: blackColor),
              //contentPadding: EdgeInsets.only(left: 10),
            ),
          ),
        ),
        SizedBox(
            width: (sizeFragment.width * 2),
            child: IconButton(
                onPressed: () {
                  sendSecondCallback(true);
                  refreshText();
                },
                icon: const Icon(
                  Icons.add,
                  color: Colors.green,
                ))),
      ],
    );
  }
}
