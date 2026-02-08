import 'package:flutter/material.dart';
import 'package:trus_app/colors.dart';

class CustomTextField2 extends StatelessWidget {
  final TextEditingController textController;
  final String label;
  final bool password;
  final String? error;
  final bool number;
  final bool enabled;
  final ValueChanged<String> onChanged;

  const CustomTextField2({
    Key? key,
    required this.textController,
    required this.onChanged,
    required this.label,
    this.password = false,
    this.number = false,
    this.error,
    this.enabled = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      enabled: enabled,
      controller: textController,
      obscureText: password,
      keyboardType: number ? TextInputType.number : TextInputType.text,
      onChanged: onChanged,
      decoration: InputDecoration(
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: orangeColor),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: orangeColor),
        ),
        labelText: label,
        labelStyle: const TextStyle(fontSize: 12),
        floatingLabelStyle: const TextStyle(color: blackColor),
        errorText: (error != null && error!.isNotEmpty)
            ? error
            : null,
        errorMaxLines: 2,
        contentPadding: const EdgeInsets.only(left: 10, top: 10),
        suffixIcon: textController.text.isNotEmpty
            ? IconButton(
          icon: const Icon(Icons.cancel, color: Colors.grey),
          onPressed: () {
            textController.clear();
            onChanged("");
          },
        )
            : null,
      ),
    );
  }
}
