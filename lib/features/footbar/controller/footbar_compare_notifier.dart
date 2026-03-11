
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/config.dart';
import 'package:trus_app/features/footbar/repository/footbar_api_service.dart';
import 'package:trus_app/features/general/notifier/app_notifier.dart';
import 'package:trus_app/features/main/controller/screen_variables_notifier.dart';
import 'package:trus_app/models/api/footbar/footbar_session.dart';
import 'package:trus_app/models/api/footbar/footbar_session_setup.dart';
import 'package:trus_app/models/api/match/match_api_model.dart';
import 'package:trus_app/models/api/player/player_api_model.dart';
import 'package:trus_app/models/api/season_api_model.dart';

import '../../../common/widgets/notifier/dropdown/dropdown_state.dart';
import '../../../models/api/footbar/footbar_account_sessions.dart';
import '../../season/controller/season_dropdown_notifier.dart';
import '../../season/season_args.dart';
import '../state/footbar_compare_state.dart';

final footbarCompareNotifierProvider = StateNotifierProvider.autoDispose<
    FootbarCompareNotifier, FootbarCompareState>((ref) {
  return FootbarCompareNotifier(
    footbarApi: ref.read(footbarApiServiceProvider),
    ref: ref,
  );
});

class FootbarCompareNotifier extends AppNotifier<FootbarCompareState> {
  final FootbarApiService footbarApi;

  static const _seasonArgs = SeasonArgs(false, true, true);

  bool _suppressSeasonListen = false;

  FootbarCompareNotifier({
    required this.footbarApi,
    required Ref ref,
  }) : super(ref, FootbarCompareState.initial()) {
    // ✅ posloucháme sezonu uvnitř notifieru
    ref.listen<DropdownState>(
      seasonDropdownNotifierProvider(_seasonArgs),
      (_, next) {
        if (_suppressSeasonListen) return;

        final season = next.getSelected() as SeasonApiModel?;
        if (season?.id == null) return;

        // guard proti loopu: když je stejná sezóna, nic nedělej
        //if (state.selectedSeason?.id == season!.id) return;

        Future.microtask(() => selectSeason(season!));
      },
    );
    Future.microtask(init);
  }

  Future<void> init() async {
    int matchSeasonId =
        ref.read(screenVariablesNotifierProvider).matchModel.seasonId;
    int? seasonId = (matchSeasonId > 0 || matchSeasonId == otherSeasonId)
        ? matchSeasonId
        : null;
    final setup = await runUiWithResult<FootbarSessionSetup>(
      () => footbarApi.getSessionSetup(seasonId),
      showLoading: true,
      successSnack: null,
      loadingMessage: "Načítám footbar statistiky…",
    );
    _applySetup(setup);
  }

  void _applySetup(FootbarSessionSetup setup) {
    // Sync sezonního dropdownu na setup.season bez vyvolání reload smyčky
    _suppressSeasonListen = true;
    try {
      ref
          .read(seasonDropdownNotifierProvider(_seasonArgs).notifier)
          .selectDropdown(setup.season);
    } finally {
      _suppressSeasonListen = false;
    }
    state = state.copyWith(
      selectedMatch: setup.match,
      selectedAccountSession: findByMatch(setup.sessions, setup.match),
      matches: AsyncValue.data(setup.matches),
      sessions: setup.sessions,
    );
    setSessions();
  }

  void setSessions() {
    state = state.copyWith(
        leftSelectedPlayer: state.selectedAccountSession?.primaryPlayer,
        rightSelectedPlayer: state.selectedAccountSession?.secondaryPlayer,
        players: AsyncValue.data(state.selectedAccountSession?.players ?? []),
        leftSession: findByPlayer(state.selectedAccountSession?.sessions ?? [],
            state.selectedAccountSession?.primaryPlayer),
        rightSession: findByPlayer(state.selectedAccountSession?.sessions ?? [],
            state.selectedAccountSession?.secondaryPlayer));
  }

  FootbarAccountSessions? findByMatch(
      List<FootbarAccountSessions> sessions,
      MatchApiModel? selectedMatch,
      ) {
    if (selectedMatch == null) return null;

    for (final s in sessions) {
      if (s.match == selectedMatch) return s;
    }
    return null;
  }

  FootbarSession? findByPlayer(
      List<FootbarSession> sessions,
      PlayerApiModel? selectedPlayer,
      ) {
    if (selectedPlayer == null) return null;

    for (final s in sessions) {
      if (s.player == selectedPlayer) return s;
    }
    return null;
  }

  // ==========================================================
  // DROPDOWNS
  // ==========================================================
  Future<void> selectSeason(SeasonApiModel season) async {
    final setup = await runUiWithResult<FootbarSessionSetup>(
      () => footbarApi.getSessionSetup(
        season.id,
      ),
      showLoading: true,
      successSnack: null,
      loadingMessage: "Načítám statistiky…",
    );
    _applySetup(setup);
  }

  Future<void> selectMatch(MatchApiModel match) async {
    state = state.copyWith(
      selectedMatch: match,
      selectedAccountSession: findByMatch(state.sessions, match)
    );
    setSessions();
  }

  Future<void> setLeftPlayer(PlayerApiModel player) async {
    state = state.copyWith(
      leftSelectedPlayer: player,
      leftSession: findByPlayer(state.selectedAccountSession?.sessions ?? [], player),
    );
  }

  Future<void> setRightPlayer(PlayerApiModel player) async {
    state = state.copyWith(
      rightSelectedPlayer: player,
      rightSession: findByPlayer(state.selectedAccountSession?.sessions ?? [], player),
    );
  }
}
