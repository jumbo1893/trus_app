import 'dart:async';
import '../../../../common/widgets/entry_draft_scope.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/features/fine/match/repository/fine_match_api_service.dart';
import 'package:trus_app/features/fine/repository/fine_api_service.dart';
import 'package:trus_app/features/general/notifier/app_notifier.dart';
import 'fine_match_notifier.dart';

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
  Future<void>? _saving;
  bool _needsSave = false;
  bool saving = false;
  bool saveFailed = false;

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
    _scheduleSave();
  }
  // ==========================================================
  // LISTVIEW / ADD BUILDER
  // ==========================================================

  void addNumber(int index) {
    if (state.receivedFines[index].fine.inactive) return;
    final list = [...state.receivedFines];
    list[index].addNumber(true);
    state = state.copyWith(receivedFines: list);
    _scheduleSave();
  }

  void removeNumber(int index) {
    if (state.receivedFines[index].fine.inactive) return;
    final list = [...state.receivedFines];
    list[index].fineNumber--;
    state = state.copyWith(receivedFines: list);
    _scheduleSave();
  }

  void _scheduleSave() {
    if (state.matchId <= 0) return;
    _needsSave = true;
    if (_saving == null) {
      unawaited(changeFines(navigate: false).catchError((Object _) {}));
    }
  }

  // ==========================================================
  // CONFIRM
  // ==========================================================

  Future<void> changeFines({bool navigate = true}) async {
    if (_saving != null) {
      _needsSave = true;
      return _saving!;
    }
    _needsSave = true;
    final operation = _savePending();
    _saving = operation;
    try {
      await operation;
    } finally {
      _saving = null;
    }
  }

  Future<void> _savePending() async {
    while (_needsSave && mounted) {
      _needsSave = false;
      if (!state.hasChanges) continue;
      final snapshot = state.receivedFines.map((f) => f.fineNumber).toList();
      final delta = [
        for (var i = 0; i < snapshot.length; i++)
          snapshot[i] - int.parse(state.initialFineValues[i]),
      ];
      final payload = ReceivedFineList(
        matchId: state.matchId,
        playerId: null,
        fineList: [
          for (var i = 0; i < state.receivedFines.length; i++)
            ReceivedFineApiModel(
              matchId: state.matchId,
              playerId: -1,
              fine: state.receivedFines[i].fine,
              fineNumber: delta[i],
            ),
        ],
        playerIdList: state.playerIdList,
      );
      saving = true;
      saveFailed = false;
      state = state.copyWith(receivedFines: [...state.receivedFines]);
      try {
        await runUiWithResult<ReceivedFineResponse>(
          () => api.addFines(payload, true),
          showLoading: false,
          showErrorDialog: false,
        );
      } catch (_) {
        if (mounted) {
          saving = false;
          saveFailed = true;
          state = state.copyWith(receivedFines: [...state.receivedFines]);
        }
        rethrow;
      }
      if (!mounted) return;
      state = state.copyWith(
        receivedFines: [...state.receivedFines],
        initialFineValues: snapshot.map((n) => '$n').toList(),
      );
      ref.invalidate(fineMatchNotifierProvider);
      if (!state.hasChanges) await clearEntryDraft(ref, draftId);
    }
    if (mounted) {
      saving = false;
      state = state.copyWith(receivedFines: [...state.receivedFines]);
    }
  }
}
