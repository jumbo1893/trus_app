class SeasonArgs {
  final bool automaticSeason;
  final bool otherSeason;
  final bool allSeason;
  final bool playedOnly;

  const SeasonArgs(
    this.automaticSeason,
    this.otherSeason,
    this.allSeason, {
    this.playedOnly = false,
  });
}
