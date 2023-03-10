import 'package:flutter/material.dart';

import '../../../colors.dart';
import '../custom_text.dart';

class RowSwitch extends StatelessWidget {
  final Size size;
  final double padding;
  final String textFieldText;
  final bool initChecked;
  final Function(bool) onChecked;
  const RowSwitch(
      {Key? key,
      required this.size,
      required this.padding,
      required this.textFieldText,
      required this.initChecked,
      required this.onChecked})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SizedBox(
            width: (size.width / 3) - padding,
            child: CustomText(text: textFieldText)),
        Container(
          decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: orangeColor))),
          width: (size.width / 1.5) - padding,
          alignment: Alignment.centerRight,
          child: Switch(
            activeColor: orangeColor,
            value: initChecked,
            onChanged: (bool value) {
              onChecked(value);
            },
          ),
        ),
      ],
    );
  }
}
