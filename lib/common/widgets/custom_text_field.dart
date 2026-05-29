import 'package:flutter/material.dart';
import 'package:trus_app/theme/app_colors.dart';

import '../utils/utils.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController textController;
  final String labelText;
  final bool password;
  final String errorText;
  final bool number;
  final bool enabled;
  final Function(String)? onChanged;

  const CustomTextField({
    Key? key,
    required this.textController,
    this.onChanged,
    required this.labelText,
    this.password = false,
    this.number = false,
    this.errorText = "",
    this.enabled = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      enabled: enabled,
      style: TextStyle(color: context.appColors.textPrimary),
      cursorColor: context.appColors.accent,
      controller: textController,
      onChanged: (value) {
        if (onChanged != null && value.isNotEmpty) {
          onChanged!(value);
        }
      },
      decoration: InputDecoration(
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: context.appColors.legacyAccent),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: context.appColors.legacyAccent),
          ),
          labelText: labelText,
          labelStyle: TextStyle(
            fontSize: 12,
            color: context.appColors.textSecondary,
          ),
          floatingLabelStyle: TextStyle(
            color: context.appColors.textPrimary,
          ),
          errorText: errorText.isNotEmpty ? errorText : null,
          contentPadding: const EdgeInsets.only(left: 10, top: 10),
          suffixIcon: textController.text.isNotEmpty
              ? IconButton(
              onPressed: () => {textController.clear(), onChanged!("")},
              icon: Icon(Icons.cancel,
                  color: context.appColors.textMuted,
                  key: ValueKey("${getValueFromValueKey(key!)}_button")))
              : null),
      textAlign: TextAlign.left,
      obscureText: password,
      keyboardType: (number ? TextInputType.number : TextInputType.text),
    );
  }
}
