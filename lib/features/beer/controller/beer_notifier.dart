import '../../main/controller/navigation_guard.dart';
import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/features/beer/lines/new_player_lines_calculator.dart';
import 'package:trus_app/features/beer/state/beer_state.dart';
import 'package:trus_app/features/general/notifier/app_notifier.dart';

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
import '../lines/player_lines.dart';
import '../repository/beer_api_service.dart';

final beerNotifierProvider =
    StateNotifierProvider.autoDispose<BeerNotifier, BeerState>((ref) {
      return BeerNotifier(beerApi: ref.read(beerApiServiceProvider), ref: ref);
    });

class BeerNotifier extends AppNotifier<BeerState> {
  final BeerApiService beerApi;

  static const _seasonArgs = SeasonArgs(false, true, true);

  bool _initialized = false;
  SeasonApiModel? _selectedSeason;
  bool _changingContext = false;
  bool _suppressSeasonListen = false;

  BeerNotifier({required this.beerApi, required Ref ref})
    : super(ref, BeerState.initial()) {
    // ✅ posloucháme sezonu uvnitř notifieru
    ref.listen<DropdownState>(seasonDropdownNotifierProvider(_seasonArgs), (
      _,
      next,
    ) {
      if (_suppressSeasonListen) return;

      final season = next.getSelected() as SeasonApiModel?;
      if (season?.id == null) return;

      // guard proti loopu: když je stejná sezóna, nic nedělej
      //if (state.selectedSeason?.id == season!.id) return;

      Future.microtask(() => selectSeason(season!));
    }, fireImmediately: false);
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
    state = state.copyWith(matches: const AsyncValue.loading());
    try {
      final setup = await runUiWithResult<BeerSetupResponse>(
        () => beerApi.setupBeers(
          (matchId != null && matchId > 0) ? matchId : null,
          (matchId == null || matchId <= 0) ? pickedSeason?.id : null,
        ),
        loadingMessage: 'Načítám zápis piv…',
      );
      if (mounted) _applySetup(setup);
    } catch (error, stack) {
      _initialized = false;
      if (mounted)
        state = state.copyWith(matches: AsyncValue.error(error, stack));
    }
  }

  bool _refreshing = false;
  Future<void> refreshOnResume() async {
    final matchId = state.selectedMatch?.id;
    if (!_initialized ||
        state.matches.isLoading ||
        matchId == null ||
        _refreshing ||
        _changingContext ||
        _saveFuture != null)
      return;
    if (state.hasChanges) {
      ui.showSnack(
        'Máš neuložené změny. Zápis zůstal zachovaný.',
        duration: const Duration(seconds: 4),
      );
      return;
    }
    _refreshing = true;
    try {
      final setup = await runUiWithResult<BeerSetupResponse>(
        () => beerApi.setupBeers(matchId, null),
        loadingMessage: 'Aktualizuji zápis piv…',
      );
      if (mounted && state.selectedMatch?.id == matchId && !state.hasChanges) {
        _applySetup(setup);
      }
    } catch (_) {
      /* Keep existing data; the request reports its error. */
    } finally {
      _refreshing = false;
    }
  }

  void _applySetup(BeerSetupResponse setup) {
    _selectedSeason = setup.season;
    if (setup.match != null) {
      ref.read(screenVariablesNotifierProvider.notifier).setMatch(setup.match!);
    } else {
      ref.read(screenVariablesNotifierProvider.notifier).setMatchId(-1);
    }
    _suppressSeasonListen = true;
    try {
      ref
          .read(seasonDropdownNotifierProvider(_seasonArgs).notifier)
          .selectDropdown(setup.season);
    } finally {
      _suppressSeasonListen = false;
    }

    final initialValues = setup.beerList
        .map((b) => '${b.beerNumber}|${b.liquorNumber}')
        .toList();

    state = state.copyWith(
      selectedMatch: setup.match,
      clearSelectedMatch: setup.match == null,
      matches: AsyncValue.data(setup.matchList),
      beers: setup.beerList,
      initialBeerValues: initialValues,
      playerIndex: 0,
    );

    _initPlayerLinesFromBeers();
  }

  // ==========================================================
  // DROPDOWNS
  // ==========================================================
  void _restoreSeason() {
    if (_selectedSeason == null) return;
    _suppressSeasonListen = true;
    try {
      ref
          .read(seasonDropdownNotifierProvider(_seasonArgs).notifier)
          .selectDropdown(_selectedSeason!);
    } finally {
      _suppressSeasonListen = false;
    }
  }

  Future<void> selectSeason(SeasonApiModel season) async {
    if (season.id == _selectedSeason?.id) return;
    if (_changingContext) {
      _restoreSeason();
      return;
    }
    _changingContext = true;
    try {
      if (!await _confirmContextChange()) {
        _restoreSeason();
        return;
      }
      final setup = await runUiWithResult<BeerSetupResponse>(
        () => beerApi.setupBeers(null, season.id),
        loadingMessage: 'Načítám sezonu…',
      );
      if (mounted) _applySetup(setup);
    } catch (_) {
      if (mounted) _restoreSeason();
    } finally {
      _changingContext = false;
    }
  }

  Future<void> selectMatch(MatchApiModel match) async {
    if (match.id == state.selectedMatch?.id || _changingContext) return;
    _changingContext = true;
    try {
      if (!await _confirmContextChange()) return;
      final setup = await runUiWithResult<BeerSetupResponse>(
        () => beerApi.setupBeers(match.id, null),
        loadingMessage: 'Načítám zápas…',
      );
      if (mounted) _applySetup(setup);
    } catch (_) {
      /* Keep the current match and data on failure. */
    } finally {
      _changingContext = false;
    }
  }

  Future<bool> _confirmContextChange() async {
    if (!state.hasChanges) return true;
    final guard = ref.read(navigationGuardProvider).guard;
    return guard != null ? await guard() : false;
  }

  void discardChanges() {
    for (var i = 0; i < state.beers.length; i++) {
      final values = state.initialBeerValues[i].split('|');
      state.beers[i].beerNumber = int.parse(values[0]);
      state.beers[i].liquorNumber = int.parse(values[1]);
    }
    state = state.copyWith(beers: [...state.beers]);
    _initPlayerLinesFromBeers();
  }

  // ==========================================================
  // MODE (LIST/PAINT)
  // ==========================================================
  void toggleMode(bool draw) {
    state = state.copyWith(drawMode: draw);
  }

  // ==========================================================
  // LISTVIEW (DOUBLE)
  // ==========================================================
  void addNumber(int index, bool beer, List<double>? newLineCoordinates) {
    final list = [...state.beers];
    if (index < 0 || index >= list.length) return;

    // ✅ inkrementální změna čárek
    if (newLineCoordinates != null) {
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
  Future<void>? _saveFuture;
  Future<void> changeBeers() =>
      _saveFuture ??= _saveBeers().whenComplete(() => _saveFuture = null);

  Future<void> _saveBeers() async {
    if (!state.hasChanges) return;

    final matchId = state.selectedMatch?.id;
    if (matchId == null) {
      ui.showSnack("Není vybraný zápas");
      return;
    }

    final savedValues = state.beers
        .map((b) => '${b.beerNumber}|${b.liquorNumber}')
        .toList();
    final payload = BeerList(
      matchId: matchId,
      beerList: _toBeerNoMatchList(state.beers),
    );

    await runUiWithResult<BeerMultiAddResponse>(
      () => beerApi.addBeers(payload),
      showLoading: true,
      successSnack: 'Zápis piv byl uložen',
      loadingMessage: "Ukládám…",
    );

    if (!mounted) return;
    state = state.copyWith(initialBeerValues: savedValues);
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
      randLine(),
      beer,
      beer
          ? state.beers[playerIndex].beerNumber
          : state.beers[playerIndex].liquorNumber,
    );
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
