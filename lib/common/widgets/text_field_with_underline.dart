import 'package:flutter/material.dart';
import 'package:trus_app/theme/app_colors.dart';

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
        contentPadding: EdgeInsets.only(left: 10, top: 10),

      ),
      textAlign: align,
    );
  }
}
