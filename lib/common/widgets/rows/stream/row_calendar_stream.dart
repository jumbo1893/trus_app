import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:trus_app/models/season_model.dart';

import '../../../../colors.dart';
import '../../../utils/calendar.dart';
import '../../calendar_text_field.dart';
import '../../custom_text.dart';
import '../../loader.dart';

class RowCalendarStream extends StatefulWidget {
  final Size size;
  final double padding;
  final String textFieldText;
  final Function(DateTime) onDateChanged;
  final Stream<DateTime> dateStream;
  final Stream<String>? errorTextStream;

  const RowCalendarStream(
      {Key? key,
        required this.size,
        required this.padding,
        required this.textFieldText,
        required this.onDateChanged,
        required this.dateStream,
        this.errorTextStream,})
      : super(key: key);

  @override
  State<RowCalendarStream> createState() => _RowCalendarStream();
}

class _RowCalendarStream extends State<RowCalendarStream> {

  final _calendarController = TextEditingController();
  String errorText = "";

  @override
  void dispose() {
    _calendarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return StreamBuilder<DateTime>(
      stream: widget.dateStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Loader();
        }
        DateTime date = snapshot.data!;
        _calendarController.text = dateTimeToString(date);
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
                width: (size.width / 3) - widget.padding,
                child: CustomText(text: widget.textFieldText)),
            SizedBox(
              width: (size.width / 1.5) - widget.padding,
              child: StreamBuilder<String>(
                stream: widget.errorTextStream,
                builder: (context, errorTextSnapshot) {
                  if (errorTextSnapshot.connectionState != ConnectionState.waiting && errorTextSnapshot.hasData) {
                    errorText = errorTextSnapshot.data!;
                  }
                  return CalendarTextField(
                    textController: _calendarController,
                    errorText: errorText,
                    onCalendarIconPressed: () {
                      showCalendar(context, date).then((value) {
                        widget.onDateChanged(value);
                        _calendarController.text = dateTimeToString(value);
                      }, onError: (e) {
                        print(e);
                      });
                    },
                  );
                }
              ),
            ),
          ],
        );
      }
    );
  }
}
