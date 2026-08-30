import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/models/api/participation/match_participation_detail.dart';

class MatchParticipationState {
  final AsyncValue<MatchParticipationDetail> detail;

  const MatchParticipationState({required this.detail});

  factory MatchParticipationState.initial() =>
      const MatchParticipationState(detail: AsyncValue.loading());

  MatchParticipationState copyWith({
    AsyncValue<MatchParticipationDetail>? detail,
  }) {
    return MatchParticipationState(detail: detail ?? this.detail);
  }
}
