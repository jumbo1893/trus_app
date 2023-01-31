import 'package:flutter/material.dart';

import '../custom_text.dart';
import '../custom_text_field.dart';

class RowTextField extends StatelessWidget {
  final Size size;
  final double padding;
  final TextEditingController textController;
  final String errorText;
  final String labelText;
  final String textFieldText;
  final bool number;
  const RowTextField(
      {Key? key,
      required this.size,
      required this.padding,
      required this.textController,
      required this.errorText,
      required this.labelText,
      required this.textFieldText,
      this.number = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SizedBox(
            width: (size.width / 3) - padding,
            child: CustomText(text: textFieldText)),
        SizedBox(
          width: (size.width / 1.5) - padding,
          child: CustomTextField(

            textController: textController,
            labelText: labelText,
            errorText: errorText,
            number: number,
          ),
        ),
      ],
    );
  }
}
