import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/features/fine/match/repository/fine_match_api_service.dart';
import 'package:trus_app/features/fine/repository/fine_api_service.dart';
import 'package:trus_app/features/general/notifier/app_notifier.dart';
import 'package:trus_app/features/home/screens/home_screen.dart';

import '../../../../models/api/fine_api_model.dart';
import '../../../../models/api/receivedfine/received_fine_api_model.dart';
import '../../../../models/api/receivedfine/received_fine_list.dart';
import '../../../../models/api/receivedfine/received_fine_response.dart';
import '../fine_multiple_player_args.dart';
import '../state/fine_multiple_player_state.dart';


final fineMultiplePlayerNotifier =
StateNotifierProvider.autoDispose.family<FineMultiplePlayerNotifier, FineMultiplePlayerState, FineMultiplePlayerArgs>((ref, args) {
  return FineMultiplePlayerNotifier(
    ref: ref,
    api: ref.read(fineMatchApiServiceProvider),
    fineApiService: ref.read(fineApiServiceProvider),
    args: args
  );
});

class FineMultiplePlayerNotifier extends AppNotifier<FineMultiplePlayerState> {
  final FineMatchApiService api;
  final FineMultiplePlayerArgs args;
  final FineApiService fineApiService;

  FineMultiplePlayerNotifier({
    required Ref ref,
    required this.api,
    required this.fineApiService,
    required this.args,
  }) : super(
    ref, FineMultiplePlayerState.initial(),
  ) {
    Future.microtask(() => setupReceivedFines(args));
  }

  Future<void> setupReceivedFines(FineMultiplePlayerArgs args) async {
    final fines = await runUiWithResult<List<FineApiModel>>(
          () => fineApiService.getFines(),
      showLoading: true,
      successSnack: null,
      loadingMessage: "Načítám pokuty…",
    );
    state = state.copyWith(
        receivedFines: convertFinesToReceivedFines(fines, args.matchId),
        matchId: args.matchId,
        playerIdList: args.playerIdList
    );
  }

  List<ReceivedFineApiModel> convertFinesToReceivedFines(List<FineApiModel> fineList, int matchId) {
    List<ReceivedFineApiModel> returnList = [];
    for(FineApiModel fine in fineList) {
      returnList.add(ReceivedFineApiModel(matchId: matchId, playerId: -1, fine: fine, fineNumber: 0));
    }
    return returnList;
  }

  // ==========================================================
  // LISTVIEW / ADD BUILDER
  // ==========================================================


  void addNumber(int index) {
    final list = [...state.receivedFines];
    list[index].addNumber(true);
    state = state.copyWith(receivedFines: list);
  }

  void removeNumber(int index) {
    final list = [...state.receivedFines];
    list[index].removeNumber(true);
    state = state.copyWith(receivedFines: list);
  }

  // ==========================================================
  // CONFIRM
  // ==========================================================

  void changeFines() async {
    final payload = ReceivedFineList(
      matchId: state.matchId,
      playerId: null,
      fineList: state.receivedFines,
      playerIdList: state.playerIdList,
    );

    final result = await runUiWithResult<ReceivedFineResponse>(
          () => api.addFines(payload, true),
      showLoading: true,
      successResultSnack: true,
      loadingMessage: "Ukládám nové pokuty…",
    );
    ui.showSnack(result.toStringForSnackBar());
    changeFragment(HomeScreen.id);
  }
}
