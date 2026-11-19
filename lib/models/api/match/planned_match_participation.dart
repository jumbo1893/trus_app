import 'package:trus_app/models/api/participation/match_participation_status.dart';

class PlannedMatchParticipation {
  const PlannedMatchParticipation({
    this.currentStatus,
    this.currentPlaying,
    required this.attendingPlayerCount,
    required this.maybePlayerCount,
    required this.notAttendingPlayerCount,
    required this.attendingPlayers,
    required this.maybePlayers,
    required this.notAttendingPlayers,
  });

  final MatchParticipationStatus? currentStatus;
  final bool? currentPlaying;
  final int attendingPlayerCount;
  final int maybePlayerCount;
  final int notAttendingPlayerCount;
  final List<String> attendingPlayers;
  final List<String> maybePlayers;
  final List<String> notAttendingPlayers;

  factory PlannedMatchParticipation.fromJson(Map<String, dynamic> json) =>
      PlannedMatchParticipation(
        currentStatus: MatchParticipationStatusExtension.fromJson(
          json['currentStatus'],
        ),
        currentPlaying: json['currentPlaying'] as bool?,
        attendingPlayerCount: json['attendingPlayerCount'] as int? ?? 0,
        maybePlayerCount: json['maybePlayerCount'] as int? ?? 0,
        notAttendingPlayerCount: json['notAttendingPlayerCount'] as int? ?? 0,
        attendingPlayers: List<String>.from(json['attendingPlayers'] ?? []),
        maybePlayers: List<String>.from(json['maybePlayers'] ?? []),
        notAttendingPlayers: List<String>.from(
          json['notAttendingPlayers'] ?? [],
        ),
      );
}
