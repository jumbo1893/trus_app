import 'package:flutter/material.dart';
import 'package:trus_app/colors.dart';

class IconTextField extends StatelessWidget {
  final TextEditingController textController;
  final VoidCallback onIconPressed;
  final String labelText;
  final Icon icon;


  const IconTextField({
    Key? key,
    required this.textController,
    required this.onIconPressed,
    required this.labelText,
    required this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: textController,
      decoration: InputDecoration(
          labelText: labelText,
        border: const UnderlineInputBorder(
          borderSide: BorderSide(
              color: blackColor
          ),
        ),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(
              color: blackColor
          ),
        ),
          focusedBorder: const UnderlineInputBorder(
            borderSide: BorderSide(
                color: blackColor
            ),
          ),
          labelStyle: const TextStyle(
            fontSize: 12,
          ),
          floatingLabelStyle: const TextStyle(
              color: textColor
          ),
          contentPadding: const EdgeInsets.only(left: 10, top: 10),
          suffixIcon: IconButton(
              onPressed: onIconPressed,
              icon: icon
          )
      ),
      textAlign: TextAlign.right,
    );
  }
}
