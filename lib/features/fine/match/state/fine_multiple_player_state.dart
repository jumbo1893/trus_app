import '../../../../models/api/receivedfine/received_fine_api_model.dart';
import '../../../general/state/loading_error_state.dart';


class FineMultiplePlayerState extends ErrorState {
  final List<ReceivedFineApiModel> receivedFines;
  final int matchId;
  final List<int> playerIdList;

  const FineMultiplePlayerState({
    required this.receivedFines,
    required this.matchId,
    required this.playerIdList,
    super.errors,
  });

  factory FineMultiplePlayerState.initial() => const FineMultiplePlayerState(
    receivedFines: [],
    matchId: -1,
    playerIdList: [],
  );

  @override
  FineMultiplePlayerState copyWith({
    List<ReceivedFineApiModel>? receivedFines,
    Map<String, String>? errors,
    int? matchId,
    List<int>? playerIdList,
  }) {
    return FineMultiplePlayerState(
      receivedFines: receivedFines ?? this.receivedFines,
      errors: errors ?? this.errors,
      matchId: matchId ?? this.matchId,
      playerIdList: playerIdList ?? this.playerIdList,
    );
  }
}
