import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/features/fine/match/fine_player_args.dart';
import 'package:trus_app/features/fine/match/repository/fine_match_api_service.dart';
import 'package:trus_app/features/general/notifier/app_notifier.dart';
import 'package:trus_app/features/home/screens/home_screen.dart';
import 'package:trus_app/features/main/controller/screen_variables_notifier.dart';

import '../../../../models/api/receivedfine/received_fine_api_model.dart';
import '../../../../models/api/receivedfine/received_fine_list.dart';
import '../../../../models/api/receivedfine/received_fine_response.dart';
import '../state/fine_player_state.dart';


final finePlayerNotifier =
StateNotifierProvider.autoDispose.family<FinePlayerNotifier, FinePlayerState, FinePlayerArgs>((ref, args) {
  return FinePlayerNotifier(
    ref: ref,
    api: ref.read(fineMatchApiServiceProvider),
    screenController: ref.read(screenVariablesNotifierProvider.notifier),
    args: args
  );
});

class FinePlayerNotifier extends AppNotifier<FinePlayerState> {
  final FineMatchApiService api;
  final ScreenVariablesNotifier screenController;
  final FinePlayerArgs args;

  FinePlayerNotifier({
    required Ref ref,
    required this.api,
    required this.screenController,
    required this.args,
  }) : super(
    ref, FinePlayerState.initial(),
  ) {
      Future.microtask(() => setupReceivedFines(args));
  }

  Future<void> setupReceivedFines(FinePlayerArgs args) async {
    final setups = await runUiWithResult<List<ReceivedFineApiModel>>(
          () => api.setupFinePlayer(args.playerId, args.matchId),
      showLoading: true,
      successSnack: null,
      loadingMessage: "Načítám pokuty…",
    );
    state = state.copyWith(
        receivedFines: setups,
        matchId: args.matchId,
        playerId: args.playerId
    );
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
      playerId: state.playerId,
      fineList: state.receivedFines,
      playerIdList: null,
    );
    final result = await runUiWithResult<ReceivedFineResponse>(
          () => api.addFines(payload, false),
      showLoading: true,
      successResultSnack: true,
      loadingMessage: "Ukládám nové pokuty…",
    );
    changeFragment(HomeScreen.id);
  }
}
