import 'package:flutter/material.dart';
import 'package:trus_app/colors.dart';

class TextFieldWithUnderline extends StatelessWidget {
  final TextEditingController textController;
  final TextAlign align;
  final bool allowWrap;

  const TextFieldWithUnderline({
    Key? key,
    required this.textController,
    required this.align,
    this.allowWrap = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: textController,
      readOnly: true,
      maxLines: allowWrap ? null : 1,
      minLines: allowWrap ? 1 : null,
      decoration: const InputDecoration(
        border: UnderlineInputBorder(
          borderSide: BorderSide(
              color: orangeColor
          ),
        ),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(
              color: orangeColor
          ),
        ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(
                color: orangeColor
            ),
          ),
          labelStyle: TextStyle(
            fontSize: 12,
          ),
          floatingLabelStyle: TextStyle(
              color: textColor
          ),
          contentPadding: EdgeInsets.only(left: 10, top: 10),

      ),
      textAlign: align,
    );
  }
}
