import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/models/api/participation/match_participation_status.dart';

class PendingParticipation {
  final int footballMatchId;
  final MatchParticipationStatus status;
  final String? comment;
  final bool? playing;

  const PendingParticipation({
    required this.footballMatchId,
    required this.status,
    this.comment,
    this.playing,
  });
}

final pendingParticipationProvider = StateProvider<PendingParticipation?>(
  (ref) => null,
);
