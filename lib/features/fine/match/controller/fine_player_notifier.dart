import 'dart:async';
import '../../../../common/widgets/entry_draft_scope.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/features/fine/match/fine_player_args.dart';
import 'package:trus_app/features/fine/match/repository/fine_match_api_service.dart';
import 'package:trus_app/features/general/notifier/app_notifier.dart';
import 'fine_match_notifier.dart';

import '../../../../models/api/receivedfine/received_fine_api_model.dart';
import '../../../../models/api/receivedfine/received_fine_list.dart';
import '../../../../models/api/receivedfine/received_fine_response.dart';
import '../state/fine_player_state.dart';

final finePlayerNotifier = StateNotifierProvider.autoDispose
    .family<FinePlayerNotifier, FinePlayerState, FinePlayerArgs>((ref, args) {
      return FinePlayerNotifier(
        ref: ref,
        api: ref.read(fineMatchApiServiceProvider),
        args: args,
      );
    });

class FinePlayerNotifier extends AppNotifier<FinePlayerState> {
  final FineMatchApiService api;
  final FinePlayerArgs args;
  Future<void>? _saving;
  bool _needsSave = false;
  bool saving = false;
  bool saveFailed = false;

  FinePlayerNotifier({
    required Ref ref,
    required this.api,
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
    list[index].removeNumber(true);
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
      final payload = ReceivedFineList(
        matchId: state.matchId,
        playerId: state.playerId,
        fineList: [
          for (var i = 0; i < state.receivedFines.length; i++)
            ReceivedFineApiModel(
              id: state.receivedFines[i].id,
              matchId: state.matchId,
              playerId: state.playerId,
              fine: state.receivedFines[i].fine,
              fineNumber: snapshot[i],
            ),
        ],
        playerIdList: null,
      );
      saving = true;
      saveFailed = false;
      state = state.copyWith(receivedFines: [...state.receivedFines]);
      try {
        await runUiWithResult<ReceivedFineResponse>(
          () => api.addFines(payload, false),
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
      state = state.copyWith(initialFineValues: snapshot.map((n) => '$n').toList());
      ref.invalidate(fineMatchNotifierProvider);
      if (!state.hasChanges) await clearEntryDraft(ref, draftId);
    }
    if (mounted) {
      saving = false;
      state = state.copyWith(receivedFines: [...state.receivedFines]);
    }
  }
}
