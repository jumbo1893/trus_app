import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/features/beer/lines/new_player_lines_calculator.dart';
import 'package:trus_app/features/beer/state/beer_state.dart';
import 'package:trus_app/features/home/screens/home_screen.dart';
import 'package:trus_app/features/main/screen_controller.dart';
import 'package:trus_app/models/api/beer/beer_list.dart';
import 'package:trus_app/models/api/beer/beer_no_match.dart';
import 'package:trus_app/models/api/beer/beer_no_match_with_player.dart';
import 'package:trus_app/models/api/beer/beer_setup_response.dart';
import 'package:trus_app/models/api/match/match_api_model.dart';
import 'package:trus_app/models/api/season_api_model.dart';

import '../../../common/widgets/notifier/dropdown/dropdown_state.dart';
import '../../season/controller/season_dropdown_notifier.dart';
import '../../season/season_args.dart';
import '../beer_screen_mode.dart';
import '../lines/player_lines.dart';
import '../repository/beer_api_service.dart';

final beerNotifierProvider =
    StateNotifierProvider.autoDispose<BeerNotifier, BeerState>((ref) {
  return BeerNotifier(
    beerApi: ref.read(beerApiServiceProvider),
    screenController: ref.read(screenControllerProvider),
    ref: ref,
  );
});

class BeerNotifier extends StateNotifier<BeerState> {
  final BeerApiService beerApi;
  final ScreenController screenController;
  final Ref ref;

  static const _seasonArgs = SeasonArgs(false, true, true);

  bool _initialized = false;
  bool _suppressSeasonListen = false;

  BeerNotifier({
    required this.beerApi,
    required this.screenController,
    required this.ref,
  }) : super(BeerState.initial()) {
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
      final setup = await beerApi.setupBeers(
        (matchId != null && matchId > 0) ? matchId : null,
        (matchId == null || matchId <= 0) ? pickedSeason?.id : null,
      );

      _applySetup(setup);

      state = state.copyWith(loading: state.loading.idle());
    } catch (e, st) {
      state = state.copyWith(
        loading: state.loading.errorMessage(e.toString()),
      );
    }
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
    state = state.copyWith(
      //selectedSeason: season,
      loading: state.loading.loading("Načítám…"),
      successMessage: null,
    );

    try {
      final setup = await beerApi.setupBeers(
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
      final setup = await beerApi.setupBeers(
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
      state = state.copyWith(
        loading: state.loading.errorMessage("Není vybraný zápas"),
      );
      return;
    }

    state = state.copyWith(
      loading: state.loading.loading("Ukládám…"),
      successMessage: null,
    );

    try {
      final payload = BeerList(
        matchId: matchId,
        beerList: _toBeerNoMatchList(state.beers),
      );

      final result = await beerApi.addBeers(payload);

      state = state.copyWith(
        loading: state.loading.idle(),
        successMessage: result.toString(),
      );

      screenController.changeFragment(HomeScreen.id);
    } catch (e) {
      state = state.copyWith(
        loading: state.loading.errorMessage(e.toString()),
      );
    }
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
