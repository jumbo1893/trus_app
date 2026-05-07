import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/features/auth/repository/auth_repository.dart';
import 'package:trus_app/features/general/notifier/safe_state_notifier.dart';
import 'package:trus_app/features/home/screens/home_screen.dart';
import 'package:trus_app/features/main/controller/screen_notifier.dart';
import 'package:trus_app/features/main/state/main_state.dart';
import 'package:trus_app/features/player/repository/player_repository.dart';

import '../../../models/api/player/stats/player_stats.dart';
import '../../../services/ws/player_update_service.dart';
import '../../fine/match/screens/fine_match_screen.dart';
import '../../general/notifier/global_variables_notifier.dart';
import '../main_ui_event_type.dart';
import '../widget/main_ui_event.dart';
import '../menu/bottom_sheet_navigation_manager.dart';

final mainNotifierProvider =
StateNotifierProvider<MainNotifier, MainState>((ref) {
  return MainNotifier(
    ref: ref,
    repository: ref.read(playerRepositoryProvider),
    authRepository: ref.read(authRepositoryProvider),
  );
});

class MainNotifier extends SafeStateNotifier<MainState> {
  final PlayerRepository repository;
  final AuthRepository authRepository;
  final PlayerUpdatesService _ws = PlayerUpdatesService();

  int _uiEventId = 0;

  MainNotifier({
    ref,
    required this.repository,
    required this.authRepository,
  }) : super(ref, MainState.initial()) {
    _init();

    ref.listen<int?>(
      globalVariablesProvider.select((s) => s.player?.id),
          (prev, next) => Future.microtask(() => _setupForPlayer(next)),
      fireImmediately: true,
    );

    ref.onDispose(() {
      _ws.disconnect();
    });
  }

  void _init() {
    String? user = authRepository.getCurrentUserName();
    if (user != null) {
      state = state.copyWith(
        userName: "píč $user",
      );
    }
  }

  void _emitUiEvent(MainUiEventType type) {
    _uiEventId++;

    safeSetState(
      state.copyWith(
        uiEvent: MainUiEvent(
          type: type,
          id: _uiEventId,
        ),
      ),
    );
  }

  Future<void> _setupForPlayer(int? playerId) async {
    if (playerId == null) {
      safeSetState(state.copyWith(
        currentPlayerId: null,
        wsConnected: false,
        playerStats: const AsyncValue.loading(),
      ));
      _ws.disconnect();
      return;
    }

    if (state.currentPlayerId == playerId) return;

    _ws.disconnect();

    safeSetState(state.copyWith(
      currentPlayerId: playerId,
      wsConnected: false,
    ));

    await loadPlayerStats(playerId);
    _subscribePlayerStatsUpdates(playerId);
  }

  Future<void> loadPlayerStats(int playerId) async {
    final cached = repository.getCachedPlayerStats(playerId);
    if (cached != null) {
      safeSetState(state.copyWith(playerStats: AsyncValue.data(cached)));
    } else {
      safeSetState(state.copyWith(playerStats: const AsyncValue.loading()));
    }

    final result = await AsyncValue.guard(
          () => runUiWithResult<PlayerStats>(
            () => repository.fetchPlayerStats(playerId),
        showLoading: cached == null,
        successSnack: null,
      ),
    );

    if (!mounted) return;

    safeSetState(state.copyWith(playerStats: result));
  }

  void _subscribePlayerStatsUpdates(int playerId) {
    _ws.connect(
      playerId: playerId,
      onUpdate: (PlayerStats stats) {
        if (!mounted) return;

        if (state.currentPlayerId != playerId) return;

        safeSetState(
          state.copyWith(
            wsConnected: true,
            playerStats: AsyncValue.data(stats),
          ),
        );
      },
    );

    safeSetState(state.copyWith(wsConnected: true));
  }

  void onModalBottomSheetMenuTapped(String id) {
    clearUi();

    if (id == BottomSheetNavigationManager.deleteAccount) {
      onDeleteAccountTapped();
    } else {
      ref.read(screenNotifierProvider.notifier).changeByFragmentId(id);
    }
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

    switch (index) {
      case 0:
        screenNotifier.changeByFragmentId(HomeScreen.id);
        break;
      case 1:
        screenNotifier.changeByFragmentId(FineMatchScreen.id);
        break;
      case 2:
        break;
      case 3:
        onStatsTapped();
        break;
      case 4:
        onMenuTapped();
        break;
      default:
        screenNotifier.changeByFragmentId(HomeScreen.id);
    }
  }
}