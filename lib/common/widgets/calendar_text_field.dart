import 'package:flutter/material.dart';
import 'package:trus_app/theme/app_colors.dart';

class CalendarTextField extends StatelessWidget {
  final TextEditingController textController;
  final VoidCallback onCalendarIconPressed;
  final String errorText;



  const CalendarTextField({
    Key? key,
    required this.textController,
    required this.onCalendarIconPressed,
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
          errorMaxLines: 2,
          suffixIcon: IconButton(
              onPressed: onCalendarIconPressed,
              icon: Icon(Icons.calendar_month, color: context.appColors.legacyAccent,
              )
          )
      ),
      textAlign: TextAlign.right,
    );
  }
}
