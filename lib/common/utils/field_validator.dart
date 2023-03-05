import '../../models/season_model.dart';

String? fieldValidator(String value) {
  return "";
}

String validateEmptyField(String value) {
  if(value.isNotEmpty) {
    return "";
  }
  return "toto musíš vyplnit";
}

String validateSeasons(List<SeasonModel>? allSeasons, DateTime seasonFrom, DateTime seasonTo, SeasonModel? currentSeason) {
  if (!seasonFrom.isBefore(seasonTo)) {
    return "Konečné datum musí být starší";
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
        return "Datum se kryje s jinými sezonami";
      }

    }
    else if (currentSeason == null) {
      if ((!seasonFrom.isBefore(seasonModel.fromDate) &&
          !seasonFrom.isAfter(seasonModel.toDate)) ||
          (!seasonTo.isBefore(seasonModel.fromDate) &&
              !seasonTo.isAfter(seasonModel.toDate)) ||
          (!seasonFrom.isAfter(seasonModel.fromDate) &&
              !seasonTo.isBefore(seasonModel.toDate))) {
        return "Datum se kryje s jinými sezonami";
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
      return "Částka musí být vyšší než 0";
    }
    return "";
  }
  catch (e) {
    return "Částka musí být číselná hodnota";
  }
}