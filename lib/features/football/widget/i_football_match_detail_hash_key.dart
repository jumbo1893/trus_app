abstract class IFootballMatchDetailHashKey {
  String matchName();
  String dateAndLeague();
  String stadium();
  String referee();
  String result();
  String refereeComment();
  String bestPlayer(bool homeTeam);
  String goalScorers(bool homeTeam);
  String yellowCardPlayers(bool homeTeam);
  String redCardPlayers(bool homeTeam);
  String ownGoalPlayers(bool homeTeam);
}