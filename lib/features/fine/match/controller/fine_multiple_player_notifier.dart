import '../../../../common/widgets/entry_draft_scope.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/features/fine/match/repository/fine_match_api_service.dart';
import 'package:trus_app/features/fine/repository/fine_api_service.dart';
import 'package:trus_app/features/general/notifier/app_notifier.dart';
import '../screens/fine_match_screen.dart';
import 'fine_match_notifier.dart';
import 'package:trus_app/features/main/controller/screen_variables_notifier.dart';

import '../../../../models/api/fine_api_model.dart';
import '../../../../models/api/receivedfine/received_fine_api_model.dart';
import '../../../../models/api/receivedfine/received_fine_list.dart';
import '../../../../models/api/receivedfine/received_fine_response.dart';
import '../fine_multiple_player_args.dart';
import '../state/fine_multiple_player_state.dart';

final fineMultiplePlayerNotifier = StateNotifierProvider.autoDispose
    .family<
      FineMultiplePlayerNotifier,
      FineMultiplePlayerState,
      FineMultiplePlayerArgs
    >((ref, args) {
      return FineMultiplePlayerNotifier(
        ref: ref,
        api: ref.read(fineMatchApiServiceProvider),
        fineApiService: ref.read(fineApiServiceProvider),
        args: args,
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
  }) : super(ref, FineMultiplePlayerState.initial()) {
    Future.microtask(() => setupReceivedFines(args));
  }

  Future<void> setupReceivedFines(FineMultiplePlayerArgs args) async {
    final fines = await runUiWithResult<List<FineApiModel>>(
      () => fineApiService.getFines(),
      showLoading: true,
      successSnack: null,
      loadingMessage: "Načítám pokuty…",
    );

    final initialValues = convertFinesToReceivedFines(
      fines,
      args.matchId,
    ).map((e) => e.numberToString(true)).toList();

    state = state.copyWith(
      receivedFines: convertFinesToReceivedFines(fines, args.matchId),
      initialFineValues: initialValues,
      matchId: args.matchId,
      playerIdList: args.playerIdList,
    );
  }

  List<ReceivedFineApiModel> convertFinesToReceivedFines(
    List<FineApiModel> fineList,
    int matchId,
  ) {
    List<ReceivedFineApiModel> returnList = [];
    for (FineApiModel fine in fineList) {
      returnList.add(
        ReceivedFineApiModel(
          matchId: matchId,
          playerId: -1,
          fine: fine,
          fineNumber: 0,
        ),
      );
    }
    return returnList;
  }

  String get draftId =>
      "fine-multiple:${args.matchId}:${([...args.playerIdList]..sort()).join(',')}";
  Map<String, int> get draftValues => {
    for (final f in state.receivedFines) '${f.fine.id}': f.fineNumber,
  };
  Map<String, int> get draftBaseline => {
    for (var i = 0; i < state.receivedFines.length; i++)
      '${state.receivedFines[i].fine.id}': int.parse(
        state.initialFineValues[i],
      ),
  };
  void restoreDraft(Map<String, int> values) {
    for (final f in state.receivedFines) {
      if (!f.fine.inactive && values.containsKey('${f.fine.id}'))
        f.fineNumber = values['${f.fine.id}']!;
    }
    state = state.copyWith(receivedFines: [...state.receivedFines]);
  }
  // ==========================================================
  // LISTVIEW / ADD BUILDER
  // ==========================================================

  void addNumber(int index) {
    if (state.receivedFines[index].fine.inactive) return;
    final list = [...state.receivedFines];
    list[index].addNumber(true);
    state = state.copyWith(receivedFines: list);
  }

  void removeNumber(int index) {
    if (state.receivedFines[index].fine.inactive) return;
    final list = [...state.receivedFines];
    list[index].removeNumber(true);
    state = state.copyWith(receivedFines: list);
  }

  // ==========================================================
  // CONFIRM
  // ==========================================================

  Future<void> changeFines({bool navigate = true}) async {
    if (!state.hasChanges) return;
    final payload = ReceivedFineList(
      matchId: state.matchId,
      playerId: null,
      fineList: state.receivedFines,
      playerIdList: state.playerIdList,
    );

    await runUiWithResult<ReceivedFineResponse>(
      () => api.addFines(payload, true),
      showLoading: true,
      successResultSnack: true,
      loadingMessage: "Ukládám nové pokuty…",
    );
    if (!mounted) return;
    state = state.copyWith(
      initialFineValues: state.receivedFines
          .map((f) => f.numberToString(true))
          .toList(),
    );
    await clearEntryDraft(ref, draftId);
    if (!mounted) return;
    ref.invalidate(fineMatchNotifierProvider);
    if (!navigate) return;
    ref
        .read(screenVariablesNotifierProvider.notifier)
        .setMatchId(state.matchId);
    changeFragment(FineMatchScreen.id);
  }
}
