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

String validateSeasons(List<SeasonModel>? allSeasons, DateTime seasonFrom, DateTime seasonTo, SeasonModel? currentSeason) {
  if (!seasonFrom.isBefore(seasonTo)) {
    return endCalendarDateNotOlderValidation;
  }
  else if (allSeasons != null || allSeasons!.isNotEmpty) {
    return _validateSeasonsCollision(allSeasons, seasonFrom, seasonTo, currentSeason);
  }

  return "";
}

String _validateSeasonsCollision(List<SeasonModel> allSeasons, DateTime seasonFrom, DateTime seasonTo, SeasonModel? currentSeason) {
  for(SeasonModel seasonModel in allSeasons) {
    if (currentSeason != null && seasonModel.id != currentSeason.id) {
      if ((!seasonFrom.isBefore(seasonModel.fromDate) &&
          !seasonFrom.isAfter(seasonModel.toDate)) ||
          (!seasonTo.isBefore(seasonModel.fromDate) &&
              !seasonTo.isAfter(seasonModel.toDate)) ||
          (!seasonFrom.isAfter(seasonModel.fromDate) &&
              !seasonTo.isBefore(seasonModel.toDate))) {
        return dateCollisionValidation;
      }

    }
    else if (currentSeason == null) {
      if ((!seasonFrom.isBefore(seasonModel.fromDate) &&
          !seasonFrom.isAfter(seasonModel.toDate)) ||
          (!seasonTo.isBefore(seasonModel.fromDate) &&
              !seasonTo.isAfter(seasonModel.toDate)) ||
          (!seasonFrom.isAfter(seasonModel.fromDate) &&
              !seasonTo.isBefore(seasonModel.toDate))) {
        return dateCollisionValidation;
      }

    }
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