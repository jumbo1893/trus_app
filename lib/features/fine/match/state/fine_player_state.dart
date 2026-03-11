import '../../../../models/api/receivedfine/received_fine_api_model.dart';
import '../../../general/state/loading_error_state.dart';


class FinePlayerState extends ErrorState {
  final List<ReceivedFineApiModel> receivedFines;
  final int matchId;
  final int playerId;

  const FinePlayerState({
    required this.receivedFines,
    required this.matchId,
    required this.playerId,
    super.errors,
  });

  factory FinePlayerState.initial() => const FinePlayerState(
    receivedFines: [],
    matchId: -1,
    playerId: -1,
  );

  @override
  FinePlayerState copyWith({
    List<ReceivedFineApiModel>? receivedFines,
    Map<String, String>? errors,
    int? matchId,
    int? playerId,
  }) {
    return FinePlayerState(
      receivedFines: receivedFines ?? this.receivedFines,
      errors: errors ?? this.errors,
      matchId: matchId ?? this.matchId,
      playerId: playerId ?? this.playerId,
    );
  }
}
