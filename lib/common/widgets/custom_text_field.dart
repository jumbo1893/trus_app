import 'package:flutter/material.dart';
import 'package:trus_app/colors.dart';

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
      controller: textController,
      onChanged: (value) {
        if (onChanged != null && value.isNotEmpty) {
          onChanged!(value);
        }
      },
      decoration: InputDecoration(
          enabledBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: orangeColor),
          ),
          focusedBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: orangeColor),
          ),
          labelText: labelText,
          labelStyle: const TextStyle(
            fontSize: 12,
          ),
          floatingLabelStyle: const TextStyle(color: blackColor),
          errorText: errorText.isNotEmpty ? errorText : null,
          contentPadding: const EdgeInsets.only(left: 10, top: 10),
          suffixIcon: textController.text.isNotEmpty
              ? IconButton(
                  onPressed: () => {textController.clear(), onChanged!("")},
                  icon: Icon(Icons.cancel,
                      color: Colors.grey,
                      key: ValueKey("${getValueFromValueKey(key!)}_button")))
              : null),
      textAlign: TextAlign.left,
      obscureText: password,
      keyboardType: (number ? TextInputType.number : TextInputType.text),
    );
  }
}
