import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/features/beer/lines/new_player_lines_calculator.dart';
import 'package:trus_app/features/beer/state/beer_state.dart';
import 'package:trus_app/features/general/notifier/app_notifier.dart';
import 'package:trus_app/features/home/screens/home_screen.dart';
import 'package:trus_app/features/main/controller/screen_variables_notifier.dart';
import 'package:trus_app/models/api/beer/beer_list.dart';
import 'package:trus_app/models/api/beer/beer_no_match.dart';
import 'package:trus_app/models/api/beer/beer_no_match_with_player.dart';
import 'package:trus_app/models/api/beer/beer_setup_response.dart';
import 'package:trus_app/models/api/match/match_api_model.dart';
import 'package:trus_app/models/api/season_api_model.dart';

import '../../../common/widgets/notifier/dropdown/dropdown_state.dart';
import '../../../models/api/beer/beer_multi_add_response.dart';
import '../../season/controller/season_dropdown_notifier.dart';
import '../../season/season_args.dart';
import '../beer_screen_mode.dart';
import '../lines/player_lines.dart';
import '../repository/beer_api_service.dart';

final beerNotifierProvider =
    StateNotifierProvider.autoDispose<BeerNotifier, BeerState>((ref) {
  return BeerNotifier(
    beerApi: ref.read(beerApiServiceProvider),
    ref: ref,
  );
});

class BeerNotifier extends AppNotifier<BeerState> {
  final BeerApiService beerApi;

  static const _seasonArgs = SeasonArgs(false, true, true);

  bool _initialized = false;
  bool _suppressSeasonListen = false;

  BeerNotifier({
    required this.beerApi,
    required Ref ref,
  }) : super(ref, BeerState.initial()) {
    // ✅ posloucháme sezonu uvnitř notifieru
    ref.listen<DropdownState>(
      seasonDropdownNotifierProvider(_seasonArgs),
      (_, next) {
        if (_suppressSeasonListen) return;

        final season = next.getSelected() as SeasonApiModel?;
        if (season?.id == null) return;

        // guard proti loopu: když je stejná sezóna, nic nedělej
        //if (state.selectedSeason?.id == season!.id) return;

        Future.microtask(() =>  selectSeason(season!));
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
    final dropdown = ref.read(seasonDropdownNotifierProvider(_seasonArgs));
    final pickedSeason = dropdown.getSelected() as SeasonApiModel?;

    // 3) první setup: matchId když existuje, jinak seasonId
    final setup = await runUiWithResult<BeerSetupResponse>(
          () => beerApi.setupBeers(
        (matchId != null && matchId > 0) ? matchId : null,
        (matchId == null || matchId <= 0) ? pickedSeason?.id : null,
      ),
      showLoading: true,
      successSnack: null,
      loadingMessage: "Načítám pivka…",
    );
    _applySetup(setup);
  }

  void _applySetup(BeerSetupResponse setup) {
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
      beers: setup.beerList,
      playerIndex: 0,
    );

    //_rebuildPlayerLines();
    _initPlayerLinesFromBeers();
  }

  // ==========================================================
  // DROPDOWNS
  // ==========================================================
  Future<void> selectSeason(SeasonApiModel season) async {
    final setup = await runUiWithResult<BeerSetupResponse>(
            () => beerApi.setupBeers(
          null,
          season.id,
        ),
        showLoading: true,
        successSnack: null,
        loadingMessage: "Načítám sezony…",
      );
      _applySetup(setup);
  }

  Future<void> selectMatch(MatchApiModel match) async {
    final setup = await runUiWithResult<BeerSetupResponse>(
          () => beerApi.setupBeers(
            match.id,
            null,
      ),
      showLoading: true,
      successSnack: null,
      loadingMessage: "Načítám zápas…",
    );
    _applySetup(setup);
  }

  // ==========================================================
  // MODE (LIST/PAINT)
  // ==========================================================
  void toggleMode() {
    state = state.copyWith(
      mode: state.mode == BeerScreenMode.list
          ? BeerScreenMode.paint
          : BeerScreenMode.list,
    );
  }

  // ==========================================================
  // LISTVIEW (DOUBLE)
  // ==========================================================
  void addNumber(int index, bool beer, List<double>? newLineCoordinates) {
    final list = [...state.beers];
    if (index < 0 || index >= list.length) return;

    // ✅ inkrementální změna čárek
    if(newLineCoordinates != null) {
      if (index < _playerLinesList.length) {
        if (beer) {
          _playerLinesList[index].addAllBeerPositions(newLineCoordinates);
        } else {
          _playerLinesList[index].addAllLiquorPositions(newLineCoordinates);
        }
      }
    }
    // změna dat
    list[index].addNumber(beer);
    state = state.copyWith(beers: list);
  }

  void removeNumber(int index, bool beer) {
    final list = [...state.beers];
    if (index < 0 || index >= list.length) return;

    // změna dat
    list[index].removeNumber(beer);
    state = state.copyWith(beers: list);

    // ✅ inkrementální změna čárek
    if (index < _playerLinesList.length) {
      if (beer) {
        _playerLinesList[index].removeLastBeerPosition();
      } else {
        _playerLinesList[index].removeLastLiquorPosition();
      }
    }
  }

  // ==========================================================
  // CONFIRM
  // ==========================================================
  Future<void> changeBeers() async {
    final matchId = state.selectedMatch?.id;
    if (matchId == null) {
      ui.showSnack("Není vybraný zápas");
      return;
    }
    final payload = BeerList(
      matchId: matchId,
      beerList: _toBeerNoMatchList(state.beers),
    );
    final result = await runUiWithResult<BeerMultiAddResponse>(
          () => beerApi.addBeers(payload),
      showLoading: true,
      successResultSnack: true,
      loadingMessage: "Ukládám…",
    );
    ref.read(screenVariablesNotifierProvider.notifier).setMatch(state.selectedMatch!);
    changeFragment(HomeScreen.id);
  }

  List<BeerNoMatch> _toBeerNoMatchList(List<BeerNoMatchWithPlayer> list) {
    return list
        .map(
          (b) => BeerNoMatch(
            id: b.id,
            playerId: b.player.id!,
            beerNumber: b.beerNumber,
            liquorNumber: b.liquorNumber,
          ),
        )
        .toList();
  }

  // ==========================================================
  // PAINT SUPPORT
  // ==========================================================

  final Random _random = Random();
  List<PlayerLines> _playerLinesList = [];

  List<PlayerLines> get playerLinesList => _playerLinesList;

  List<double> randLine() => [
        _random.nextDouble(),
        _random.nextDouble(),
        _random.nextDouble(),
        _random.nextDouble(),
      ];

  NewPlayerLinesCalculator? getPlayerLinesCalculator(bool beer) {
    int playerIndex = state.playerIndex;
    if ((beer && state.beers[playerIndex].beerNumber >= 30) ||
        !beer && state.beers[playerIndex].liquorNumber >= 20) {
      return null;
    }
    return NewPlayerLinesCalculator(
        randLine(), beer, beer? state.beers[playerIndex].beerNumber : state.beers[playerIndex].liquorNumber);
  }

  void _initPlayerLinesFromBeers() {
    _playerLinesList = state.beers.map((b) {
      final lines = PlayerLines();
      for (int i = 0; i < b.beerNumber; i++) {
        lines.addAllBeerPositions(randLine());
      }
      for (int i = 0; i < b.liquorNumber; i++) {
        lines.addAllLiquorPositions(randLine());
      }
      return lines;
    }).toList();

    if (_playerLinesList.isEmpty) {
      state = state.copyWith(playerIndex: 0);
    } else if (state.playerIndex >= _playerLinesList.length) {
      state = state.copyWith(playerIndex: 0);
    }
  }

  void nextPlayer() {
    if (_playerLinesList.isEmpty) return;
    final next = (state.playerIndex + 1) % _playerLinesList.length;
    state = state.copyWith(playerIndex: next);
  }

  void prevPlayer() {
    if (_playerLinesList.isEmpty) return;
    final prev = state.playerIndex - 1;
    state = state.copyWith(
      playerIndex: prev < 0 ? _playerLinesList.length - 1 : prev,
    );
  }
}
