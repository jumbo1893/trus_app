import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/features/footbar/repository/footbar_repository.dart';
import 'package:trus_app/features/footbar/state/footbar_sync_state.dart';
import 'package:trus_app/features/general/notifier/safe_state_notifier.dart';
import 'package:trus_app/features/main/controller/screen_variables_notifier.dart';

import '../../../common/utils/calendar.dart';


final footbarSyncNotifierProvider = StateNotifierProvider.autoDispose<
    FootbarSyncNotifier, FootbarSyncState>((ref) {
  return FootbarSyncNotifier(
    ref,
    ref.read(footbarRepositoryProvider),
    ref.read(screenVariablesNotifierProvider.notifier),
  );
});

class FootbarSyncNotifier extends SafeStateNotifier<FootbarSyncState> {
  final FootbarRepository repository;
  final ScreenVariablesNotifier screenController;

  FootbarSyncNotifier(
    Ref ref,
    this.repository,
    this.screenController,
  ) : super(ref, FootbarSyncState.initial()) {
    Future.microtask(_loadLastSync);
  }

  Future<void> _loadLastSync() async {
    final cached = repository.getCachedLastSync();
    if (cached != null) {
      safeSetState(state.copyWith(lastSync: _getLastUpdateString(cached)));
    }

    final lastSync = await runUiWithResult<DateTime?>(
          () => repository.fetchLastSync(),
      showLoading: (cached == null),
      successSnack: null,
    );
    if (!mounted) return;

    safeSetState(state.copyWith(lastSync: _getLastUpdateString(lastSync)));
  }

  String _getLastUpdateString(DateTime? lastSync) {
    return lastSync == null? "Ještě neproběhla" : formatDateForFrontend(lastSync);
  }

  Future<void> syncAppTeamActivities() async {
    final lastSync = await runUiWithResult<DateTime?>(
          () => repository.api.syncAppTeamActivites(),
      showLoading: true,
      successSnack: "Aktivity týmu úspěšně načteny",
    );
    if (!mounted) return;
    safeSetState(state.copyWith(lastSync: _getLastUpdateString(lastSync)));
  }
}
