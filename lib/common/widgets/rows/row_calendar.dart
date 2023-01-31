import 'package:flutter/material.dart';

import '../../utils/calendar.dart';
import '../calendar_text_field.dart';
import '../custom_text.dart';

class RowCalendar extends StatelessWidget {
  final Size size;
  final double padding;
  final TextEditingController calendarController;
  final String textFieldText;
  final DateTime pickedDate;
  final Function(DateTime) onDateChanged;
  final String errorText;
  const RowCalendar({
    Key? key,
    required this.pickedDate,
    required this.size,
    required this.padding,
    required this.calendarController,
    required this.textFieldText,
    required this.onDateChanged,
    this.errorText = "",
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SizedBox(
            width: (size.width / 3) - padding,
            child: CustomText(text: textFieldText)),
        SizedBox(
          width: (size.width / 1.5) - padding,
          child: CalendarTextField(
            textController: calendarController,
            errorText: errorText,
            onCalendarIconPressed: () {
              showCalendar(context, pickedDate).then((value) {
                onDateChanged(value);
                calendarController.text = dateTimeToString(value);
              }, onError: (e) {
                print(e);
              });
            },
          ),
        ),
      ],
    );
  }
}
