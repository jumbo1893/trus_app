import 'package:flutter/material.dart';
import 'package:trus_app/colors.dart';

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
        border: const UnderlineInputBorder(
          borderSide: BorderSide(
              color: orangeColor
          ),
        ),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(
              color: orangeColor
          ),
        ),
          focusedBorder: const UnderlineInputBorder(
            borderSide: BorderSide(
                color: orangeColor
            ),
          ),
          labelStyle: const TextStyle(
            fontSize: 12,
          ),
          floatingLabelStyle: const TextStyle(
              color: textColor
          ),
          contentPadding: const EdgeInsets.only(left: 10, top: 10),
          errorText: errorText.isNotEmpty ? errorText : null,
          suffixIcon: IconButton(
              onPressed: onCalendarIconPressed,
              icon: const Icon(Icons.calendar_month, color: orangeColor,
              )
          )
      ),
      textAlign: TextAlign.right,
    );
  }
}
