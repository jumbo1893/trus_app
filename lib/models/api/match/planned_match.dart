class PlannedMatch {
  final int id;
  final DateTime date;
  final String? opponent;
  final String type;
  final bool? home;
  final int? seasonId;
  final int? footballMatchId;
  final String? opponentLogoUrl;
  final int? footballRound;
  final String? footballStadium;
  final String status;
  final int? matchId;
  final String? description;
  final bool hasPhoto;

  PlannedMatch({
    required this.id,
    required this.date,
    this.opponent,
    required this.type,
    this.home,
    this.seasonId,
    this.footballMatchId,
    this.opponentLogoUrl,
    this.footballRound,
    this.footballStadium,
    required this.status,
    this.matchId,
    this.description,
    this.hasPhoto = false,
  });

  factory PlannedMatch.fromJson(Map<String, dynamic> json) => PlannedMatch(
    id: json['id'] as int,
    date: DateTime.parse(json['date'] as String),
    opponent: json['opponent'] as String?,
    type: json['type'] as String,
    home: json['home'] as bool?,
    seasonId: json['seasonId'] as int?,
    footballMatchId: json['footballMatchId'] as int?,
    opponentLogoUrl: json['opponentLogoUrl'] as String?,
    footballRound: json['footballRound'] as int?,
    footballStadium: json['footballStadium'] as String?,
    status: json['status'] as String,
    matchId: json['matchId'] as int?,
    description: json['description'] as String?,
    hasPhoto: json['hasPhoto'] as bool? ?? false,
  );
}
