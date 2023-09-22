import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

Future<DateTime> showCalendar(BuildContext context, DateTime? initialDate) async {
  DateTime? chosenDateTime;
  chosenDateTime = await showDatePicker(
    context: context,
    initialDate: initialDate ?? DateTime.now(),
    firstDate: DateTime(1900),
    lastDate: DateTime(2050),
  );
  if (chosenDateTime != null) {
    return DateTime.utc(chosenDateTime.year, chosenDateTime.month, chosenDateTime.day, 12);
  }
  return chosenDateTime ?? DateTime.now();
}

String dateTimeToString(DateTime dateTime) {
  return "${dateTime.day}.${dateTime.month}. ${dateTime.year}";
}

bool isSameDay(DateTime dateTime1, DateTime dateTime2) {

  if (dateTime2.compareTo(dateTime1) == 0) {
    return true;
  }
  return false;
}

String formatDateForJson(DateTime dateTime) {
  final formatter = DateFormat('yyyy-MM-ddTHH:mm:ss');
  final returnDate = formatter.format(dateTime.toLocal());
  return returnDate;
}


