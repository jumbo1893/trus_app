import 'package:flutter/material.dart';

import '../../utils/calendar.dart';
import 'form/fake_input.dart';

class AppDateField extends StatelessWidget {
  final String label;
  final DateTime value;
  final String? error;
  final ValueChanged<DateTime> onChanged;

  const AppDateField({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.error,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        final date = await showCalendar(context, value);
        onChanged(date);
      },
      child: FakeInput(
        text: dateTimeToString(value),
        icon: Icons.calendar_today,
      ),
    );
  }
}