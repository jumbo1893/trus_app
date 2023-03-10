import 'package:flutter/material.dart';
import 'package:trus_app/models/helper/helper_model.dart';

import '../../../colors.dart';

class ListviewAddModel extends StatefulWidget {
  final IHelperModel helperModel;
  final String? fieldName;
  final double padding;
  final Function(int number) onNumberChanged;
  const ListviewAddModel(
      {Key? key,
        required this.padding,
        required this.onNumberChanged,
      this.fieldName,
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
    super.dispose();
  }

  void refreshText() {
    textEditingController.text = widget.helperModel.getNumber(widget.fieldName).toString();
  }

  void sendCallback(int number) {
    widget.onNumberChanged(number);
  }

  @override
  Widget build(BuildContext context) {
    textEditingController.text = widget.helperModel.getNumber(widget.fieldName).toString();
    final size = MediaQuery.of(context).size;
    return Row(
      children: [
        SizedBox(
            width: (size.width / 1.5) - widget.padding,
            child: Text(widget.helperModel.toStringForListviewAddModel(), style: const TextStyle(fontSize: 16))),
        const SizedBox(width: 21,),

        SizedBox(
            width: (size.width / 9) -7,
            child: IconButton(onPressed: () {widget.helperModel.addNumber(widget.fieldName); refreshText(); sendCallback(widget.helperModel.getNumber(widget.fieldName));}, icon: const Icon(Icons.add, color: Colors.green,))),
        SizedBox(
            width: (size.width / 9) -7,
            child: IconButton(onPressed: () {widget.helperModel.removeNumber(widget.fieldName); refreshText(); sendCallback(widget.helperModel.getNumber(widget.fieldName));}, icon: const Icon(Icons.remove, color: Colors.red,))),
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
