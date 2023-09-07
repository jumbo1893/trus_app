import 'package:flutter/material.dart';
import 'package:trus_app/models/helper/helper_model.dart';

import '../../../colors.dart';
import '../../../features/general/add_controller.dart';
import '../../../models/api/interfaces/add_to_string.dart';

class ListviewAddModel2 extends StatefulWidget {
  final AddToString addToString;
  final bool goal;
  final double padding;
  final VoidCallback onNumberAdded;
  final VoidCallback onNumberRemoved;
  const ListviewAddModel2(
      {Key? key,
        required this.padding,
        required this.onNumberAdded,
        required this.onNumberRemoved,
      this.goal = false,
      required this.addToString})
      : super(key: key);

  @override
  State<ListviewAddModel2> createState() => _ListviewAddModel2();
}

class _ListviewAddModel2 extends State<ListviewAddModel2> {

  TextEditingController textEditingController = TextEditingController();

  @override
  void dispose() {
    textEditingController.dispose();
    super.dispose();
  }

  void refreshText() {
    textEditingController.text = widget.addToString.numberToString(widget.goal);
  }

  void sendCallback(bool added) {
    if(added) {
      widget.onNumberAdded();
    }
    else {
      widget.onNumberRemoved();
    }
  }

  @override
  Widget build(BuildContext context) {
    textEditingController.text = widget.addToString.numberToString(widget.goal);
    final size = MediaQueryData.fromWindow(WidgetsBinding.instance.window).size;
    return Row(
      children: [
        SizedBox(
            width: (size.width / 1.5) - widget.padding,
            child: Text(widget.addToString.toStringForListView(), style: const TextStyle(fontSize: 16))),
        const SizedBox(width: 21,),

        SizedBox(
            width: (size.width / 9) -7,
            child: IconButton(onPressed: () {
              sendCallback(true);
              refreshText();
              },
                icon: const Icon(Icons.add, color: Colors.green,))),
        SizedBox(
            width: (size.width / 9) -7,
            child: IconButton(onPressed: () {
              sendCallback(false);
              refreshText();
              },
                icon: const Icon(Icons.remove, color: Colors.red,))),
        SizedBox(
          width: (size.width / 9) -7,
          child: TextField(controller: textEditingController,
            decoration: const InputDecoration(
              enabled: false,
              border: InputBorder.none,
              floatingLabelStyle: TextStyle(
                  color: blackColor
              ),
              contentPadding: EdgeInsets.only(left: 10),

            ),),
        ),
      ],

    );
  }
}
