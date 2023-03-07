import '../../../models/season_model.dart';

SeasonModel calculateAutomaticSeason(List<SeasonModel> allSeasons, DateTime matchDate) {
  for(SeasonModel season in allSeasons) {
    if(!season.fromDate.isAfter(matchDate) && !season.toDate.isBefore(matchDate)) {
      return season;
    }
  }
  return SeasonModel.otherSeason();
}

SeasonModel calculateSeasonFromId(String? seasonId, List<SeasonModel> allSeasons) {
  if (seasonId == null) {
    return SeasonModel.automaticSeason();
  }
  for(SeasonModel season in allSeasons) {
    if(seasonId == season.id) {
      return season;
    }
  }
  return SeasonModel.automaticSeason();
}