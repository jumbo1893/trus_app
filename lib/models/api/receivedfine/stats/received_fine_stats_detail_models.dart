class FineStatsModel {
  final int id;
  final String name;
  final int amount;

  const FineStatsModel({
    required this.id,
    required this.name,
    required this.amount,
  });

  factory FineStatsModel.fromJson(Map<String, dynamic> json) {
    return FineStatsModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      amount: json['amount'] ?? 0,
    );
  }
}

class StatsPlayerModel {
  final int id;
  final String name;

  const StatsPlayerModel({
    required this.id,
    required this.name,
  });

  factory StatsPlayerModel.fromJson(Map<String, dynamic> json) {
    return StatsPlayerModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
    );
  }
}

class StatsMatchModel {
  final int id;
  final String name;
  final DateTime date;
  final int? seasonId;

  const StatsMatchModel({
    required this.id,
    required this.name,
    required this.date,
    this.seasonId,
  });

  factory StatsMatchModel.fromJson(Map<String, dynamic> json) {
    return StatsMatchModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      date: DateTime.parse(json['date']),
      seasonId: json['seasonId'],
    );
  }
}

class FineCountModel {
  final FineStatsModel fine;
  final int count;
  final int totalAmount;

  const FineCountModel({
    required this.fine,
    required this.count,
    required this.totalAmount,
  });

  factory FineCountModel.fromJson(Map<String, dynamic> json) {
    return FineCountModel(
      fine: FineStatsModel.fromJson(json['fine']),
      count: json['count'] ?? 0,
      totalAmount: json['totalAmount'] ?? 0,
    );
  }
}

sealed class ReceivedFineStatsDetailResponse {
  const ReceivedFineStatsDetailResponse();
}

class ReceivedFineMatchDetailResponse extends ReceivedFineStatsDetailResponse {
  final List<PlayerWithFinesModel> players;
  final List<FineWithPlayersModel> fines;

  const ReceivedFineMatchDetailResponse({
    required this.players,
    required this.fines,
  });

  factory ReceivedFineMatchDetailResponse.fromJson(Map<String, dynamic> json) {
    return ReceivedFineMatchDetailResponse(
      players: (json['players'] as List<dynamic>? ?? [])
          .map((item) => PlayerWithFinesModel.fromJson(item))
          .toList(),
      fines: (json['fines'] as List<dynamic>? ?? [])
          .map((item) => FineWithPlayersModel.fromJson(item))
          .toList(),
    );
  }
}

class PlayerWithFinesModel {
  final StatsPlayerModel player;
  final int totalAmount;
  final int totalCount;
  final List<FineCountModel> fines;

  const PlayerWithFinesModel({
    required this.player,
    required this.totalAmount,
    required this.totalCount,
    required this.fines,
  });

  factory PlayerWithFinesModel.fromJson(Map<String, dynamic> json) {
    return PlayerWithFinesModel(
      player: StatsPlayerModel.fromJson(json['player']),
      totalAmount: json['totalAmount'] ?? 0,
      totalCount: json['totalCount'] ?? 0,
      fines: (json['fines'] as List<dynamic>? ?? [])
          .map((item) => FineCountModel.fromJson(item))
          .toList(),
    );
  }
}

class FineWithPlayersModel {
  final FineStatsModel fine;
  final int totalAmount;
  final int totalCount;
  final List<PlayerFineCountModel> players;

  const FineWithPlayersModel({
    required this.fine,
    required this.totalAmount,
    required this.totalCount,
    required this.players,
  });

  factory FineWithPlayersModel.fromJson(Map<String, dynamic> json) {
    return FineWithPlayersModel(
      fine: FineStatsModel.fromJson(json['fine']),
      totalAmount: json['totalAmount'] ?? 0,
      totalCount: json['totalCount'] ?? 0,
      players: (json['players'] as List<dynamic>? ?? [])
          .map((item) => PlayerFineCountModel.fromJson(item))
          .toList(),
    );
  }
}

class PlayerFineCountModel {
  final StatsPlayerModel player;
  final int count;
  final int totalAmount;

  const PlayerFineCountModel({
    required this.player,
    required this.count,
    required this.totalAmount,
  });

  factory PlayerFineCountModel.fromJson(Map<String, dynamic> json) {
    return PlayerFineCountModel(
      player: StatsPlayerModel.fromJson(json['player']),
      count: json['count'] ?? 0,
      totalAmount: json['totalAmount'] ?? 0,
    );
  }
}

class ReceivedFinePlayerDetailResponse extends ReceivedFineStatsDetailResponse {
  final List<MatchWithFinesModel> matches;
  final List<FineWithMatchesModel> fines;

  const ReceivedFinePlayerDetailResponse({
    required this.matches,
    required this.fines,
  });

  factory ReceivedFinePlayerDetailResponse.fromJson(Map<String, dynamic> json) {
    return ReceivedFinePlayerDetailResponse(
      matches: (json['matches'] as List<dynamic>? ?? [])
          .map((item) => MatchWithFinesModel.fromJson(item))
          .toList(),
      fines: (json['fines'] as List<dynamic>? ?? [])
          .map((item) => FineWithMatchesModel.fromJson(item))
          .toList(),
    );
  }
}

class MatchWithFinesModel {
  final StatsMatchModel match;
  final int totalAmount;
  final int totalCount;
  final List<FineCountModel> fines;

  const MatchWithFinesModel({
    required this.match,
    required this.totalAmount,
    required this.totalCount,
    required this.fines,
  });

  factory MatchWithFinesModel.fromJson(Map<String, dynamic> json) {
    return MatchWithFinesModel(
      match: StatsMatchModel.fromJson(json['match']),
      totalAmount: json['totalAmount'] ?? 0,
      totalCount: json['totalCount'] ?? 0,
      fines: (json['fines'] as List<dynamic>? ?? [])
          .map((item) => FineCountModel.fromJson(item))
          .toList(),
    );
  }
}

class FineWithMatchesModel {
  final FineStatsModel fine;
  final int totalAmount;
  final int totalCount;
  final List<MatchFineCountModel> matches;

  const FineWithMatchesModel({
    required this.fine,
    required this.totalAmount,
    required this.totalCount,
    required this.matches,
  });

  factory FineWithMatchesModel.fromJson(Map<String, dynamic> json) {
    return FineWithMatchesModel(
      fine: FineStatsModel.fromJson(json['fine']),
      totalAmount: json['totalAmount'] ?? 0,
      totalCount: json['totalCount'] ?? 0,
      matches: (json['matches'] as List<dynamic>? ?? [])
          .map((item) => MatchFineCountModel.fromJson(item))
          .toList(),
    );
  }
}

class MatchFineCountModel {
  final StatsMatchModel match;
  final int count;
  final int totalAmount;

  const MatchFineCountModel({
    required this.match,
    required this.count,
    required this.totalAmount,
  });

  factory MatchFineCountModel.fromJson(Map<String, dynamic> json) {
    return MatchFineCountModel(
      match: StatsMatchModel.fromJson(json['match']),
      count: json['count'] ?? 0,
      totalAmount: json['totalAmount'] ?? 0,
    );
  }
}
