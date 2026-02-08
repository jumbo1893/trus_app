import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

Future<DateTime> showCalendar(
    BuildContext context, DateTime? initialDate) async {
  DateTime? chosenDateTime;
  chosenDateTime = await showDatePicker(
    context: context,
    initialDate: initialDate ?? DateTime.now(),
    firstDate: DateTime(1900),
    lastDate: DateTime(2050),
  );
  if (chosenDateTime != null) {
    return DateTime.utc(
        chosenDateTime.year, chosenDateTime.month, chosenDateTime.day, 12);
  }
  return chosenDateTime ?? DateTime.now();
}

String dateTimeToString(DateTime dateTime) {
  final formatter = DateFormat('dd.MM. yyyy');
  final returnDate = formatter.format(dateTime.toLocal());
  return returnDate;
}

String dateTimeToTimeString(DateTime dateTime) {
  final formatter = DateFormat('HH:mm:ss');
  final returnDate = formatter.format(dateTime.toLocal());
  return returnDate;
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

String formatDateForFrontend(DateTime dateTime) {
  final formatter = DateFormat('dd. MM. yyyy HH:mm');
  final returnDate = formatter.format(dateTime.toLocal());
  return returnDate;
}

DateTime getDatesForNewSeason(bool from) {
  int year = DateTime.now().year;
  int month = DateTime.now().month;
  DateTime fromDate;
  DateTime toDate;
  if (month <= 6) {
    fromDate = DateTime.utc(year, 1, 1);
    toDate = DateTime.utc(year, 7, 1);
  } else {
    fromDate = DateTime.utc(year, 9, 1);
    toDate = DateTime.utc(year, 12, 31);
  }
  return from ? fromDate : toDate;
}
