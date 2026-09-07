import '../../config.dart';
import '../../models/api/season_api_model.dart';

///seasonList nesmí být prázdný
SeasonApiModel returnCurrentSeason(List<SeasonApiModel> seasonList) {
  for (SeasonApiModel season in seasonList) {
    if (isSeasonActiveOn(season, DateTime.now())) {
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

bool isSeasonActiveOn(SeasonApiModel season, DateTime date) {
  final currentDay = _calendarDay(date);
  final firstDay = _calendarDay(season.fromDate);
  final lastDay = _calendarDay(season.toDate);
  return !currentDay.isBefore(firstDay) && !currentDay.isAfter(lastDay);
}

DateTime _calendarDay(DateTime value) {
  final local = value.toLocal();
  return DateTime(local.year, local.month, local.day);
}
