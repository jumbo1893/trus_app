import '../../../../models/api/receivedfine/received_fine_api_model.dart';
import '../../../general/state/loading_error_state.dart';


class FineMultiplePlayerState extends ErrorState {
  final List<ReceivedFineApiModel> receivedFines;
  final int matchId;
  final List<int> playerIdList;
  final List<String> initialFineValues;

  const FineMultiplePlayerState({
    required this.receivedFines,
    required this.initialFineValues,
    required this.matchId,
    required this.playerIdList,
    super.errors,
  });

  factory FineMultiplePlayerState.initial() => const FineMultiplePlayerState(
    receivedFines: [],
    initialFineValues: [],
    matchId: -1,
    playerIdList: [],
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
  FineMultiplePlayerState copyWith({
    List<ReceivedFineApiModel>? receivedFines,
    List<String>? initialFineValues,
    Map<String, String>? errors,
    int? matchId,
    List<int>? playerIdList,
  }) {
    return FineMultiplePlayerState(
      receivedFines: receivedFines ?? this.receivedFines,
      initialFineValues: initialFineValues ?? this.initialFineValues,
      errors: errors ?? this.errors,
      matchId: matchId ?? this.matchId,
      playerIdList: playerIdList ?? this.playerIdList,
    );
  }
}
