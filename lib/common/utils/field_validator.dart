import '../../models/season_model.dart';
import '../static_text.dart';

String? fieldValidator(String value) {
  return "";
}

String validateEmptyField(String value) {
  if(value.isNotEmpty) {
    return "";
  }
  return emptyFieldValidation;
}

String validateSeasonDate(DateTime seasonFrom, DateTime seasonTo) {
  if (!seasonFrom.isBefore(seasonTo)) {
    return endCalendarDateNotOlderValidation;
  }
  return "";
}

String validateAmountField(String value) {
  String empty = validateEmptyField(value);
  if(empty.isNotEmpty) {
    return empty;
  }
  try {
    int amount = int.parse(value);
    if(amount <= 0) {
      return amountIsNotPositiveNumberValidation;
    }
    return "";
  }
  catch (e) {
    return amountIsNotANumberValidation;
  }
}