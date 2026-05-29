import 'package:flutter/material.dart';
import 'package:trus_app/theme/app_colors.dart';

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
      style: TextStyle(color: context.appColors.textPrimary),
      cursorColor: context.appColors.accent,
      controller: textController,
      obscureText: password,
      keyboardType: number ? TextInputType.number : TextInputType.text,
      onChanged: onChanged,
      decoration: InputDecoration(
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: context.appColors.legacyAccent),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: context.appColors.legacyAccent),
        ),
        labelText: label,
        labelStyle: TextStyle(
          fontSize: 12,
          color: context.appColors.textSecondary,
        ),
        floatingLabelStyle: TextStyle(color: context.appColors.textPrimary),
        errorText: (error != null && error!.isNotEmpty)
            ? error
            : null,
        errorMaxLines: 2,
        contentPadding: const EdgeInsets.only(left: 10, top: 10),
        suffixIcon: textController.text.isNotEmpty
            ? IconButton(
          icon: Icon(Icons.cancel, color: context.appColors.textMuted),
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
