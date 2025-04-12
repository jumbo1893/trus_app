import '../../../models/api/football/football_match_api_model.dart';

abstract class IFootballMatchBoxCallback {
  void onButtonAddPlayersClick(FootballMatchApiModel footballMatchApiModel);
  void onButtonAddGoalsClick(FootballMatchApiModel footballMatchApiModel);
  void onButtonAddBeerClick(FootballMatchApiModel footballMatchApiModel);
  void onButtonAddFineClick(FootballMatchApiModel footballMatchApiModel);
  void onCommonMatchesClick(FootballMatchApiModel footballMatchApiModel);
  void onButtonDetailMatchClick(FootballMatchApiModel footballMatchApiModel);
}