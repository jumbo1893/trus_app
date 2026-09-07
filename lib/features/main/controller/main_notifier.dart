import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/features/auth/repository/auth_repository.dart';
import 'package:trus_app/features/general/notifier/safe_state_notifier.dart';

import 'package:trus_app/features/main/controller/screen_notifier.dart';
import 'package:trus_app/features/main/state/main_state.dart';
import 'package:trus_app/features/player/repository/player_repository.dart';

import '../../../models/api/player/stats/player_stats.dart';
import '../../../services/ws/player_update_service.dart';
import '../navigation_sections.dart';
import '../../general/notifier/global_variables_notifier.dart';
import '../main_ui_event_type.dart';
import '../widget/main_ui_event.dart';

final mainNotifierProvider = StateNotifierProvider<MainNotifier, MainState>((
  ref,
) {
  return MainNotifier(
    ref: ref,
    repository: ref.read(playerRepositoryProvider),
    authRepository: ref.read(authRepositoryProvider),
  );
});

class MainNotifier extends SafeStateNotifier<MainState> {
  final PlayerRepository repository;
  final AuthRepository authRepository;
  final PlayerUpdatesService _ws;

  int? _currentPlayerId;
  int? _currentAppTeamId;

  int _uiEventId = 0;

  MainNotifier({
    ref,
    required this.repository,
    required this.authRepository,
    PlayerUpdatesService? playerUpdatesService,
  }) : _ws = playerUpdatesService ?? PlayerUpdatesService(),
       super(ref, MainState.initial()) {
    _init();

    ref.listen<(int?, int?)>(
      globalVariablesProvider.select((s) => (s.player?.id, s.appTeam?.id)),
      (prev, next) => Future.microtask(() => _setupForPlayer(next.$1, next.$2)),
      fireImmediately: true,
    );

    ref.onDispose(() {
      _ws.disconnect();
    });
  }

  void _init() {
    String? user = authRepository.getCurrentUserName();
    if (user != null) {
      state = state.copyWith(userName: "píč $user");
    }
  }

  void _emitUiEvent(MainUiEventType type) {
    _uiEventId++;

    safeSetState(
      state.copyWith(
        uiEvent: MainUiEvent(type: type, id: _uiEventId),
      ),
    );
  }

  Future<void> _setupForPlayer(int? playerId, int? appTeamId) async {
    if (playerId == null || appTeamId == null) {
      _currentPlayerId = null;
      _currentAppTeamId = null;
      safeSetState(
        state.copyWith(
          currentPlayerId: null,
          wsConnected: false,
          playerStats: const AsyncValue.loading(),
        ),
      );
      _ws.disconnect();
      return;
    }

    if (_currentPlayerId == playerId && _currentAppTeamId == appTeamId) return;

    _ws.disconnect();
    _currentPlayerId = playerId;
    _currentAppTeamId = appTeamId;

    safeSetState(state.copyWith(currentPlayerId: playerId, wsConnected: false));

    await loadPlayerStats(playerId, appTeamId);
    if (!_isCurrentContext(playerId, appTeamId)) return;
    _subscribePlayerStatsUpdates(playerId, appTeamId);
  }

  Future<void> loadPlayerStats(int playerId, int appTeamId) async {
    final cached = repository.getCachedPlayerStats(playerId, appTeamId);
    if (cached != null) {
      safeSetState(state.copyWith(playerStats: AsyncValue.data(cached)));
    } else {
      safeSetState(state.copyWith(playerStats: const AsyncValue.loading()));
    }

    final result = await AsyncValue.guard(
      () => runUiWithResult<PlayerStats>(
        () => repository.fetchPlayerStats(playerId, appTeamId),
        showLoading: cached == null,
        successSnack: null,
      ),
    );

    if (!mounted || !_isCurrentContext(playerId, appTeamId)) return;

    safeSetState(state.copyWith(playerStats: result));
  }

  void _subscribePlayerStatsUpdates(int playerId, int appTeamId) {
    _ws.connect(
      playerId: playerId,
      appTeamId: appTeamId,
      onUpdate: (PlayerStats stats) {
        if (!mounted) return;

        if (!_isCurrentContext(playerId, appTeamId)) return;

        safeSetState(
          state.copyWith(
            wsConnected: true,
            playerStats: AsyncValue.data(stats),
          ),
        );
      },
      onConnected: () {
        if (mounted && _isCurrentContext(playerId, appTeamId)) {
          safeSetState(state.copyWith(wsConnected: true));
        }
      },
      onDisconnected: () {
        if (mounted && _isCurrentContext(playerId, appTeamId)) {
          safeSetState(state.copyWith(wsConnected: false));
        }
      },
    );
  }

  bool _isCurrentContext(int playerId, int appTeamId) =>
      _currentPlayerId == playerId && _currentAppTeamId == appTeamId;

  void onModalBottomSheetMenuTapped(String id) {
    clearUi();
    ref.read(screenNotifierProvider.notifier).changeByFragmentId(id);
  }

  void clearUi() {
    _emitUiEvent(MainUiEventType.pop);
  }

  void onMenuTapped() {
    _emitUiEvent(MainUiEventType.openBottomMenu);
  }

  void onStatsTapped() {
    _emitUiEvent(MainUiEventType.openStatsMenu);
  }

  void onDeleteAccountTapped() {
    _emitUiEvent(MainUiEventType.confirmDelete);
  }

  void onUpperMenuTapped() {
    _emitUiEvent(MainUiEventType.openUpperMenu);
  }

  void showSnackBar() {
    _emitUiEvent(MainUiEventType.showSnackBar);
  }

  void showErrorMessage() {
    _emitUiEvent(MainUiEventType.showErrorDialog);
  }

  void clearUiEvent() {
    safeSetState(state.copyWith(uiEvent: null));
  }

  void onBottomMenuTapped(int index) {
    final screenNotifier = ref.read(screenNotifierProvider.notifier);

    if (index >= 0 && index < sectionIds.length) {
      screenNotifier.changeByFragmentId(sectionIds[index]);
    }
  }
}
