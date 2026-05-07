import '../../../../models/api/receivedfine/received_fine_api_model.dart';
import '../../../general/state/loading_error_state.dart';

class FinePlayerState extends ErrorState {
  final List<ReceivedFineApiModel> receivedFines;
  final List<String> initialFineValues;
  final int matchId;
  final int playerId;

  const FinePlayerState({
    required this.receivedFines,
    required this.initialFineValues,
    required this.matchId,
    required this.playerId,
    super.errors,
  });

  factory FinePlayerState.initial() => const FinePlayerState(
    receivedFines: [],
    initialFineValues: [],
    matchId: -1,
    playerId: -1,
  );

  bool get hasChanges {
    if (receivedFines.length != initialFineValues.length) return false;

    for (int i = 0; i < receivedFines.length; i++) {
      if (receivedFines[i].numberToString(true) != initialFineValues[i]) {
        return true;
      }
    }
    return false;
  }

  @override
  FinePlayerState copyWith({
    List<ReceivedFineApiModel>? receivedFines,
    List<String>? initialFineValues,
    Map<String, String>? errors,
    int? matchId,
    int? playerId,
  }) {
    return FinePlayerState(
      receivedFines: receivedFines ?? this.receivedFines,
      initialFineValues: initialFineValues ?? this.initialFineValues,
      errors: errors ?? this.errors,
      matchId: matchId ?? this.matchId,
      playerId: playerId ?? this.playerId,
    );
  }
}