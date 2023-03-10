import 'package:flutter/material.dart';
import 'package:trus_app/models/helper/beer_helper_model.dart';

import '../../../colors.dart';

class ListviewBeerAddModel extends StatefulWidget {
  final BeerHelperModel helperModel;
  final String name;
  final double padding;
  final Function(int number) onBeerNumberChanged;
  final Function(int number) onLiquorNumberChanged;
  const ListviewBeerAddModel(
      {Key? key,
        required this.padding,
        required this.onBeerNumberChanged,
        required this.onLiquorNumberChanged,
      required this.name,
      required this.helperModel})
      : super(key: key);

  @override
  State<ListviewBeerAddModel> createState() => _ListviewBeerAddModel();
}

class _ListviewBeerAddModel extends State<ListviewBeerAddModel> {

  TextEditingController beerEditingController = TextEditingController();
  TextEditingController liquorEditingController = TextEditingController();

  @override
  void dispose() {
    beerEditingController.dispose();
    liquorEditingController.dispose();
    super.dispose();
  }

  void refreshText() {
    beerEditingController.text = widget.helperModel.beerNumber.toString();
    liquorEditingController.text = widget.helperModel.liquorNumber.toString();
  }

  void sendBeerCallback(int number) {
    widget.onBeerNumberChanged(number);
  }

  void sendLiquorCallback(int number) {
    widget.onLiquorNumberChanged(number);
  }

  @override
  Widget build(BuildContext context) {
    beerEditingController.text = widget.helperModel.beerNumber.toString();
    liquorEditingController.text = widget.helperModel.liquorNumber.toString();
    final size = MediaQuery.of(context).size;
    final sizeFragment = size/30;
    return Row(
      children: [
        SizedBox(
            width: (sizeFragment.width*10) - widget.padding ,
            child: Text(widget.name, style: const TextStyle(fontSize: 16))),

        SizedBox(width: sizeFragment.width*2,),

        SizedBox(
            width: (sizeFragment.width*2.0),
            child: const Icon(Icons.sports_bar, color: blackColor,)),

        SizedBox(
            width: (sizeFragment.width*2),
            child: IconButton(onPressed: () {widget.helperModel.addBeerNumber(); refreshText(); sendBeerCallback(widget.helperModel.beerNumber);}, icon: const Icon(Icons.add, color: Colors.green,))),
        SizedBox(
            width: (sizeFragment.width*2),
            child: IconButton(onPressed: () {widget.helperModel.removeBeerNumber(); refreshText(); sendBeerCallback(widget.helperModel.beerNumber);}, icon: const Icon(Icons.remove, color: Colors.red,))),
        SizedBox(
          width: (sizeFragment.width*3),
          child: TextField(controller: beerEditingController,
            decoration: const InputDecoration(
              enabled: false,
              border: InputBorder.none,
              floatingLabelStyle: TextStyle(
                  color: blackColor
              ),
              contentPadding: EdgeInsets.only(left: 10),

            ),),
        ),
        SizedBox(
            width: (sizeFragment.width*2),
            child: const Icon(Icons.liquor, color: blackColor,)),
        SizedBox(
            width: (sizeFragment.width*2),
            child: IconButton(onPressed: () {widget.helperModel.addLiquorNumber(); refreshText(); sendLiquorCallback(widget.helperModel.liquorNumber);}, icon: const Icon(Icons.add, color: Colors.green,))),
        SizedBox(
            width: (sizeFragment.width*2),
            child: IconButton(onPressed: () {widget.helperModel.removeLiquorNumber(); refreshText(); sendLiquorCallback(widget.helperModel.liquorNumber);}, icon: const Icon(Icons.remove, color: Colors.red,))),
        SizedBox(width: sizeFragment.width,),
        SizedBox(
          width: (sizeFragment.width*2),
          child: TextField(controller: liquorEditingController,
            decoration: const InputDecoration(
              enabled: false,
              border: InputBorder.none,
              floatingLabelStyle: TextStyle(
                  color: blackColor
              ),
              //contentPadding: EdgeInsets.only(left: 10),

            ),),
        ),
      ],

    );
  }
}
