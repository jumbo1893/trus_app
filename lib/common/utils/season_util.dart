
import '../../config.dart';
import '../../models/api/season_api_model.dart';

///seasonList nesmí být prázdný
SeasonApiModel returnCurrentSeason(List<SeasonApiModel> seasonList) {
    for (SeasonApiModel season in seasonList) {
      if (!season.fromDate.isAfter(DateTime.now()) &&
          !season.toDate.isBefore(DateTime.now())) {
        return season;
      }
    }
    for (SeasonApiModel season in seasonList) {
      if (season.id == otherSeasonId) {
        return season;
      }
    }
    return seasonList[0];
}

SeasonApiModel returnSeasonById(List<SeasonApiModel> seasonList, int id) {
  for (SeasonApiModel season in seasonList) {
    if (season.id! == id) {
      return season;
    }
  }
  return seasonList[0];
}