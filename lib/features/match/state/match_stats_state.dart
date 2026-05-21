class MatchStatsState {
  final String goals;
  final String assists;
  final String beers;
  final String fines;
  final String overall;

  const MatchStatsState({
    required this.goals,
    required this.assists,
    required this.beers,
    required this.fines,
    required this.overall,
  });

  MatchStatsState copyWith({
    String? goals,
    String? assists,
    String? beers,
    String? fines,
    String? overall,
  }) {
    return MatchStatsState(
      goals: goals ?? this.goals,
      assists: assists ?? this.assists,
      beers: beers ?? this.beers,
      fines: fines ?? this.fines,
      overall: overall ?? this.overall,
    );
  }

  MatchStatsState.init({
    this.goals = "",
    this.assists = "",
    this.beers = "",
    this.fines = "",
    this.overall = "",
  });
}
