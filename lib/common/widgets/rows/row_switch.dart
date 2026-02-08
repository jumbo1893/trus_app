import 'package:flutter/material.dart';

import '../../../../colors.dart';
import '../custom_text.dart';

class RowSwitch extends StatefulWidget {
  final String? textFieldText;
  final bool value;
  final ValueChanged<bool> onChanged;

  const RowSwitch(
      {Key? key,
      this.textFieldText,
      required this.value,
        required this.onChanged
      })
      : super(key: key);

  @override
  State<RowSwitch> createState() => _RowSwitch();
}

class _RowSwitch extends State<RowSwitch> {


  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    const double padding = 8.0;
    if (widget.textFieldText != null) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
              width: (size.width / 3) - padding,
              child: CustomText(text: widget.textFieldText!)),
          SizedBox(
              width: (size.width / 1.5) - padding,
              child: Container(
                decoration: const BoxDecoration(
                    border: Border(bottom: BorderSide(color: orangeColor))),
                width: (size.width / 1.5) - padding,
                alignment: Alignment.centerRight,
                child: Switch(
                  activeColor: orangeColor,
                  value: widget.value,
                  onChanged: widget.onChanged,
                ),
              ),),
        ],
      );
    } else {
      return Container(
        decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: orangeColor))),
        width: (size.width / 1.5) - padding,
        alignment: Alignment.centerRight,
        child: Switch(
          activeColor: orangeColor,
          value: widget.value,
          onChanged: widget.onChanged,
        ),
      );
    }
  }
}
