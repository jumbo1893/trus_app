import 'package:flutter/material.dart';
import 'package:trus_app/theme/app_colors.dart';

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
          border: UnderlineInputBorder(
            borderSide: BorderSide(
                color: context.appColors.buttonForeground
            ),
          ),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(
                color: context.appColors.buttonForeground
            ),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(
                color: context.appColors.buttonForeground
            ),
          ),
          labelStyle: const TextStyle(
            fontSize: 12,
          ),
          floatingLabelStyle: TextStyle(
              color: context.appColors.fieldTextAccent
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
