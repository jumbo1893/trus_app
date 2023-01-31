import 'package:flutter/material.dart';


Future<DateTime> showCalendar(BuildContext context, DateTime? initialDate) async {
  DateTime? chosenDateTime;
  chosenDateTime = await showDatePicker(
    context: context,
    initialDate: initialDate ?? DateTime.now(),
    firstDate: DateTime(1900),
    lastDate: DateTime(2050),
  );
  print(chosenDateTime ?? DateTime.now());
  return chosenDateTime ?? DateTime.now();
}

String dateTimeToString(DateTime dateTime) {
  return "${dateTime.day}.${dateTime.month}. ${dateTime.year}";
}
