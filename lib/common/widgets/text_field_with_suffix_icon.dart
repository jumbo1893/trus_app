import 'package:flutter/material.dart';
import 'package:trus_app/theme/app_colors.dart';

class TextFieldWithSuffixIcon extends StatelessWidget {
  final TextEditingController textController;
  final VoidCallback onIconPressed;
  final String errorText;
  final IconData iconData;

  const TextFieldWithSuffixIcon({
    Key? key,
    required this.textController,
    required this.onIconPressed,
    required this.iconData,
    this.errorText = "",
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: textController,
      readOnly: true,
      decoration: InputDecoration(
          border: UnderlineInputBorder(
            borderSide: BorderSide(
                color: context.appColors.legacyAccent
            ),
          ),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(
                color: context.appColors.legacyAccent
            ),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(
                color: context.appColors.legacyAccent
            ),
          ),
          labelStyle: const TextStyle(
            fontSize: 12,
          ),
          floatingLabelStyle: TextStyle(
              color: context.appColors.fieldTextAccent
          ),
          contentPadding: const EdgeInsets.only(left: 10, top: 10),
          errorText: errorText.isNotEmpty ? errorText : null,
          suffixIcon: IconButton(
              onPressed: onIconPressed,
              icon: Icon(iconData, color: context.appColors.legacyAccent,
              )
          )
      ),
      textAlign: TextAlign.right,
    );
  }
}
