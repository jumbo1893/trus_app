import 'package:flutter/material.dart';

import '../../../colors.dart';

class RowBackOrForward extends StatelessWidget {
  final double padding;
  final String backText;
  final String forwardText;
  final Function onBackChecked;
  final Function onForwardChecked;
  bool secondArrowForward;
  RowBackOrForward(
      {Key? key,
      required this.padding,
      required this.backText,
      required this.forwardText,
      required this.onForwardChecked,
      required this.onBackChecked,
      this.secondArrowForward = true})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Row(
      children: [
        SizedBox(
            width: size.width / 6 - padding,
            child: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                onBackChecked();
              },
              color: orangeColor,
            )),
        SizedBox(
            width: size.width / 3,
            child: TextButton(
              child: Text(
                backText,
                style: const TextStyle(
                    color: blackColor,
                    fontSize: 18,
                    fontWeight: FontWeight.normal),
              ),
              onPressed: () {
                onBackChecked();
              },
            )),
        SizedBox(
            width: size.width / 3,
            child: TextButton(
              child: Text(
                forwardText,
                style: const TextStyle(
                    color: blackColor,
                    fontSize: 18,
                    fontWeight: FontWeight.normal),
              ),
              onPressed: () {
                onForwardChecked();
              },
            )),
        SizedBox(
            width: size.width / 6 - padding,
            child: IconButton(
              icon: secondArrowForward ? const Icon(Icons.arrow_forward) : const Icon(Icons.arrow_back),
              onPressed: () {
                onForwardChecked();
              },
              color: orangeColor,
            )),
      ],
    );
  }
}
