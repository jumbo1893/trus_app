import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:trus_app/models/helper/fine_match_helper_model.dart';
import 'package:trus_app/models/season_model.dart';

import '../../../colors.dart';
import '../../../features/season/utils/season_calculator.dart';

class ListviewAddModel extends StatefulWidget {
  final FineMatchHelperModel helperModel;
  final String name;
  //final String subtitle;
  final double padding;
  final Function(int number) onNumberChanged;
  const ListviewAddModel(
      {Key? key,
        required this.padding,
        required this.onNumberChanged,
        //required this.subtitle,
      required this.name,
      required this.helperModel})
      : super(key: key);

  @override
  State<ListviewAddModel> createState() => _ListviewAddModel();
}

class _ListviewAddModel extends State<ListviewAddModel> {

  TextEditingController textEditingController = TextEditingController();

  @override
  void dispose() {
    textEditingController.dispose();
    // TODO: implement dispose
    super.dispose();
  }

  void refreshText() {
    textEditingController.text = widget.helperModel.number.toString();
  }

  void sendCallback(int number) {
    widget.onNumberChanged(number);
  }

  @override
  Widget build(BuildContext context) {
    textEditingController.text = widget.helperModel.number.toString();
    final size = MediaQuery.of(context).size;
    return Row(
      children: [
        SizedBox(
            width: (size.width / 1.5) - widget.padding,
            child: Text(widget.name, style: TextStyle(fontSize: 16))),
        const SizedBox(width: 21,),

        SizedBox(
            width: (size.width / 9) -7,
            child: IconButton(onPressed: () {widget.helperModel.addNumber(); refreshText(); sendCallback(widget.helperModel.number);}, icon: const Icon(Icons.add, color: Colors.green,))),
        SizedBox(
            width: (size.width / 9) -7,
            child: IconButton(onPressed: () {widget.helperModel.removeNumber(); refreshText(); sendCallback(widget.helperModel.number);}, icon: const Icon(Icons.remove, color: Colors.red,))),
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
