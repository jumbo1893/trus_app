import 'package:flutter/material.dart';
import 'package:trus_app/features/mixin/date_controller_mixin.dart';

import '../../../utils/calendar.dart';
import '../../../utils/utils.dart';
import '../../calendar_text_field.dart';
import '../../custom_text.dart';
import '../../loader.dart';

class RowCalendarStream extends StatefulWidget {
  final Size size;
  final double padding;
  final String textFieldText;
  final DateControllerMixin dateControllerMixin;
  final String hashKey;

  const RowCalendarStream({
     required Key key,
    required this.size,
    required this.padding,
    required this.textFieldText,
    required this.dateControllerMixin,
    required this.hashKey,
  }) : super(key: key);

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
        stream: widget.dateControllerMixin.date(widget.hashKey),
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
                    stream: widget.dateControllerMixin.dateErrorText(widget.hashKey),
                    builder: (context, errorTextSnapshot) {
                      if (errorTextSnapshot.connectionState !=
                              ConnectionState.waiting &&
                          errorTextSnapshot.hasData) {
                        errorText = errorTextSnapshot.data!;
                      }
                      return CalendarTextField(
                        key: ValueKey(
                            "${getValueFromValueKey(widget.key!)}_text"),
                        textController: _calendarController,
                        errorText: errorText,
                        onCalendarIconPressed: () {
                          showCalendar(context, date).then((value) {
                            (date) => widget.dateControllerMixin.setDate(date, widget.hashKey);
                            _calendarController.text = dateTimeToString(value);
                            widget.dateControllerMixin.setDate(value, widget.hashKey);
                          }, onError: (e) {
                            print(e);
                          });
                        },
                      );
                    }),
              ),
            ],
          );
        });
  }
}
