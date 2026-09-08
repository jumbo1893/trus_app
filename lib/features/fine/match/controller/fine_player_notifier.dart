import '../../../../common/widgets/entry_draft_scope.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/features/fine/match/fine_player_args.dart';
import 'package:trus_app/features/fine/match/repository/fine_match_api_service.dart';
import 'package:trus_app/features/general/notifier/app_notifier.dart';
import '../screens/fine_match_screen.dart';
import 'fine_match_notifier.dart';
import 'package:trus_app/features/main/controller/screen_variables_notifier.dart';

import '../../../../models/api/receivedfine/received_fine_api_model.dart';
import '../../../../models/api/receivedfine/received_fine_list.dart';
import '../../../../models/api/receivedfine/received_fine_response.dart';
import '../state/fine_player_state.dart';

final finePlayerNotifier = StateNotifierProvider.autoDispose
    .family<FinePlayerNotifier, FinePlayerState, FinePlayerArgs>((ref, args) {
      return FinePlayerNotifier(
        ref: ref,
        api: ref.read(fineMatchApiServiceProvider),
        screenController: ref.read(screenVariablesNotifierProvider.notifier),
        args: args,
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
  }) : super(ref, FinePlayerState.initial()) {
    Future.microtask(() => setupReceivedFines(args));
  }

  Future<void> setupReceivedFines(FinePlayerArgs args) async {
    final setups = await runUiWithResult<List<ReceivedFineApiModel>>(
      () => api.setupFinePlayer(args.playerId, args.matchId),
      showLoading: true,
      successSnack: null,
      loadingMessage: "Načítám pokuty…",
    );

    final initialValues = setups.map((e) => e.numberToString(true)).toList();

    state = state.copyWith(
      receivedFines: setups,
      initialFineValues: initialValues,
      matchId: args.matchId,
      playerId: args.playerId,
    );
  }

  String get draftId => "fine:${args.matchId}:${args.playerId}";
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
      playerId: state.playerId,
      fineList: state.receivedFines,
      playerIdList: null,
    );

    await runUiWithResult<ReceivedFineResponse>(
      () => api.addFines(payload, false),
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
