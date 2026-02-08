enum MatchScreenScenario {
  createEmpty,               // nový zápas, nic nevíme
  createFromFootballMatch,   // nový zápas z footballMatch
  loadFromMatchScreen,             // editace existujícího zápasu
  loadFootballMatchDetail,   // detail zápasu
  loadMutualMatches,   // vzájemné zápasy
  editFromHomeScreen,
}