import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/features/fine/match/screens/fine_player_screen.dart';
import 'package:trus_app/features/fine/match/state/fine_match_state.dart';
import 'package:trus_app/features/main/screen_controller.dart';
import 'package:trus_app/models/api/match/match_api_model.dart';
import 'package:trus_app/models/api/season_api_model.dart';

import '../../../../common/widgets/notifier/dropdown/dropdown_state.dart';
import '../../../../models/api/player/player_api_model.dart';
import '../../../../models/api/receivedfine/received_fine_setup.dart';
import '../../../season/controller/season_dropdown_notifier.dart';
import '../../../season/season_args.dart';
import '../repository/fine_match_api_service.dart';
import '../screens/multiple_fine_players_screen.dart';

final fineMatchNotifierProvider =
    StateNotifierProvider.autoDispose<FineMatchNotifier, FineMatchState>((ref) {
  return FineMatchNotifier(
    fineApi: ref.read(fineMatchApiServiceProvider),
    screenController: ref.read(screenControllerProvider),
    ref: ref,
  );
});

class FineMatchNotifier extends StateNotifier<FineMatchState> {
  final FineMatchApiService fineApi;
  final ScreenController screenController;
  final Ref ref;

  static const _seasonArgs = SeasonArgs(false, true, true);

  bool _initialized = false;
  bool _suppressSeasonListen = false;

  FineMatchNotifier({
    required this.fineApi,
    required this.screenController,
    required this.ref,
  }) : super(FineMatchState.initial()) {
    // ✅ posloucháme sezonu uvnitř notifieru (stejně jako MatchNotifier)
    ref.listen<DropdownState>(
      seasonDropdownNotifierProvider(_seasonArgs),
      (_, next) {
        if (_suppressSeasonListen) return;

        final season = next.getSelected() as SeasonApiModel?;
        if (season?.id == null) return;

        // guard proti loopu: když je stejná sezóna, nic nedělej
        //if (state.selectedSeason?.id == season!.id) return;

        selectSeason(season!);
      },
      fireImmediately: false,
    );
  }

  // ==========================================================
  // INIT
  // ==========================================================
  Future<void> init({int? matchId}) async {
    if (_initialized) return;
    _initialized = true;

    state = state.copyWith(
      loading: state.loading.loading("Načítám…"),
      successMessage: null,
    );

    try {
      // 2) vyber sezonu z dropdownu (už může být loaded), fallback na "current"
      final dropdown = ref.read(seasonDropdownNotifierProvider(_seasonArgs));
      final pickedSeason = dropdown.getSelected() as SeasonApiModel?;

      // 3) první setup: matchId když existuje, jinak seasonId
      final setup = await fineApi.setupFineMatch(
        (matchId != null && matchId > 0) ? matchId : null,
        (matchId == null || matchId <= 0) ? pickedSeason?.id : null,
      );

      _applySetup(setup);

      state = state.copyWith(loading: state.loading.idle());
    } catch (e) {
      state = state.copyWith(
        loading: state.loading.errorMessage(e.toString()),
      );
    }
  }

  void _applySetup(ReceivedFineSetup setup) {
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
      //selectedSeason: setup.season,
      matches: AsyncValue.data(setup.matchList),
      otherPlayers: setup.otherPlayers,
      playersInMatch: setup.playersInMatch,
      allPlayers: setup.playersInMatch+setup.otherPlayers,
      checkedPlayers: [],
      multiCheck: false
    );
  }

  // ==========================================================
  // DROPDOWNS
  // ==========================================================
  Future<void> selectSeason(SeasonApiModel season) async {
    state = state.copyWith(
      //selectedSeason: season,
      loading: state.loading.loading("Načítám…"),
      successMessage: null,
    );

    try {
      final setup = await fineApi.setupFineMatch(
        null,
        season.id,
      );
      _applySetup(setup);
      state = state.copyWith(loading: state.loading.idle());
    } catch (e) {
      state = state.copyWith(
        loading: state.loading.errorMessage(e.toString()),
      );
    }
  }

  Future<void> selectMatch(MatchApiModel match) async {
    state = state.copyWith(
      selectedMatch: match,
      loading: state.loading.loading("Načítám…"),
      successMessage: null,
    );

    try {
      // při změně zápasu load přes matchId
      final setup = await fineApi.setupFineMatch(
        match.id,
        null,
      );
      _applySetup(setup);
      state = state.copyWith(loading: state.loading.idle());
    } catch (e) {
      state = state.copyWith(
        loading: state.loading.errorMessage(e.toString()),
      );
    }
  }

  void toggleCheckedPlayer(PlayerApiModel player) {
    if (!state.allPlayers.any((p) => p == player)) return;

    final current = state.checkedPlayers;
    final exists = current.any((p) => p == player);

    final next = exists
        ? current.where((p) => p != player).toList()
        : [...current, player];

    state = state.copyWith(checkedPlayers: next);
  }

  void setSelectedPlayer(PlayerApiModel player) {
    screenController.setPlayer(player);
    screenController.changeFragment(FinePlayerScreen.id);
  }

  List<int> getCheckedPlayerIdList() {
    List<int> playerIds = [];
    for(PlayerApiModel player in state.checkedPlayers) {
      playerIds.add(player.id!);
    }
    return playerIds;
  }

  void onIconClick(int index) {
    switch (index) {
      case 0:
        if(state.checkedPlayers.isEmpty) {
          state = state.copyWith(
            loading: state.loading.errorMessage("Musí být označen aspoň jeden hráč!"),
          );
        }
        else {
          screenController.setMatch(state.selectedMatch!);
          screenController.setPlayerIdList(getCheckedPlayerIdList());
          screenController.changeFragment(MultipleFinePlayersScreen.id);
        }
        break;
    //všichni hráči
      case 1:
        state = state.copyWith(checkedPlayers: state.allPlayers);
          break;

    //nehrající
      case 2:
        state = state.copyWith(checkedPlayers: state.otherPlayers);
        break;
    //hrající
      case 3:
        state = state.copyWith(checkedPlayers: state.playersInMatch);
        break;
    }
  }

  void cleanCheckPlayers() {
    state = state.copyWith(checkedPlayers: []);
  }

  void switchScreen(bool multi) {
    cleanCheckPlayers();
    state = state.copyWith(multiCheck: multi);
  }

  void clearErrorMessage() {
    state = state.copyWith(
      loading: state.loading.errorMessage(null),
    );
  }

}
