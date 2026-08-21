enum StepPeriod { today, betweenMatches, sinceLastMatch, allTime }

extension StepPeriodApi on StepPeriod {
  String get apiValue => switch (this) {
    StepPeriod.today => 'TODAY',
    StepPeriod.betweenMatches => 'BETWEEN_MATCHES',
    StepPeriod.sinceLastMatch => 'SINCE_LAST_MATCH',
    StepPeriod.allTime => 'ALL_TIME',
  };
}

class StepLeaderboardEntry {
  final int userId;
  final String userName;
  final int stepCount;
  final int dayCount;
  final double averageStepsPerDay;

  const StepLeaderboardEntry({
    required this.userId,
    required this.userName,
    required this.stepCount,
    required this.dayCount,
    required this.averageStepsPerDay,
  });

  factory StepLeaderboardEntry.fromJson(Map<String, dynamic> json) {
    return StepLeaderboardEntry(
      userId: (json['userId'] as num).toInt(),
      userName: (json['userName'] as String?)?.trim().isNotEmpty == true
          ? json['userName'] as String
          : 'Uživatel',
      stepCount: (json['stepCount'] as num?)?.toInt() ?? 0,
      dayCount: (json['dayCount'] as num?)?.toInt() ?? 0,
      averageStepsPerDay:
          (json['averageStepsPerDay'] as num?)?.toDouble() ?? 0,
    );
  }
}

class StepMatch {
  final int matchId;
  final String opponentName;
  final DateTime date;

  const StepMatch({
    required this.matchId,
    required this.opponentName,
    required this.date,
  });

  factory StepMatch.fromJson(Map<String, dynamic> json) => StepMatch(
    matchId: (json['matchId'] as num).toInt(),
    opponentName:
        (json['opponentName'] as String?)?.trim().isNotEmpty == true
        ? (json['opponentName'] as String).trim()
        : 'Neznámý soupeř',
    date: DateTime.parse(json['date'] as String),
  );
}

class StepLeaderboardData {
  final List<StepLeaderboardEntry> entries;
  final StepMatch? previousMatch;
  final StepMatch? lastMatch;
  final DateTime? from;
  final DateTime? to;

  const StepLeaderboardData({
    required this.entries,
    required this.previousMatch,
    required this.lastMatch,
    required this.from,
    required this.to,
  });

  factory StepLeaderboardData.fromJson(Map<String, dynamic> json) {
    final lastMatchJson = json['lastMatch'];
    final previousMatchJson = json['previousMatch'];
    return StepLeaderboardData(
      entries: (json['entries'] as List<dynamic>? ?? const [])
          .map(
            (item) =>
                StepLeaderboardEntry.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
      previousMatch: previousMatchJson is Map<String, dynamic>
          ? StepMatch.fromJson(previousMatchJson)
          : null,
      lastMatch: lastMatchJson is Map<String, dynamic>
          ? StepMatch.fromJson(lastMatchJson)
          : null,
      from: _parseDate(json['from']),
      to: _parseDate(json['to']),
    );
  }

  static DateTime? _parseDate(dynamic value) => value is String
      ? DateTime.tryParse(value)
      : null;
}

class StepSyncDay {
  final DateTime date;
  final int stepCount;
  final String source;
  final DateTime measuredUntil;

  const StepSyncDay({
    required this.date,
    required this.stepCount,
    required this.source,
    required this.measuredUntil,
  });

  Map<String, dynamic> toJson() => {
    'date': _dateOnly(date),
    'stepCount': stepCount,
    'source': source,
    'timezone': 'Europe/Prague',
    'measuredUntil': measuredUntil.toUtc().toIso8601String(),
  };

  static String _dateOnly(DateTime value) =>
      '${value.year.toString().padLeft(4, '0')}-'
      '${value.month.toString().padLeft(2, '0')}-'
      '${value.day.toString().padLeft(2, '0')}';
}
