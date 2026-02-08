import 'package:flutter/material.dart';

import '../../utils/calendar.dart';
import '../calendar_text_field.dart';
import '../custom_text.dart';


class RowDatePicker extends StatefulWidget {
  final String? textFieldText;
  final DateTime value;
  final String? error;
  final ValueChanged<DateTime> onChanged;

  const RowDatePicker({
    super.key,
    this.textFieldText,
    this.error,
    required this.value,
    required this.onChanged,
  });

  @override
  State<RowDatePicker> createState() => _RowDatePickerState();
}

class _RowDatePickerState extends State<RowDatePicker> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: dateTimeToString(widget.value));
  }

  @override
  void didUpdateWidget(covariant RowDatePicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    String textValue = dateTimeToString(widget.value);
    if (oldWidget.value != widget.value && textValue != _controller.text) {
      _controller.value = _controller.value.copyWith(
        text: textValue,
        selection: TextSelection.collapsed(offset: textValue.length),
        composing: TextRange.empty,
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    const double padding = 8.0;
    if (widget.textFieldText != null) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
            SizedBox(
                width: (size.width / 3) - padding,
                child: CustomText(text: widget.textFieldText!)),
          SizedBox(
              width: (size.width / 1.5) - padding,
              child: CalendarTextField(
                textController: _controller,
                errorText: widget.error?? "",
                onCalendarIconPressed: () {
                  showCalendar(context, widget.value).then((value) {
                    widget.onChanged(value);
                    _controller.text = dateTimeToString(value);
                  }).catchError((e) {
                    print(e);
                  });
                },
              )),
        ],
      );
    }
    else {
      return CalendarTextField(
        textController: _controller,
        errorText: widget.error?? "",
        onCalendarIconPressed: () {
          showCalendar(context, widget.value).then((value) {
                (date) => widget.onChanged;
            _controller.text = dateTimeToString(value);
          }, onError: (e) {
            print(e);
          });
        },
      );
    }
  }
}

