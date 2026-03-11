import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/features/auth/repository/auth_repository.dart';
import 'package:trus_app/features/general/global_variables_controller.dart';
import 'package:trus_app/features/general/notifier/safe_state_notifier.dart';
import 'package:trus_app/features/home/repository/home_repository.dart';
import 'package:trus_app/features/home/state/home_state.dart';
import 'package:trus_app/features/player/repository/player_repository.dart';

import '../../../models/api/football/football_match_api_model.dart';
import '../../../models/api/home/home_setup.dart';
import '../../../models/api/player/player_api_model.dart';
import '../../beer/screens/beer_simple_screen.dart';
import '../../fine/match/screens/fine_match_screen.dart';
import '../../goal/screen/goal_screen.dart';
import '../../main/controller/screen_variables_notifier.dart';
import '../../match/match_notifier_args.dart';
import '../../match/screens/add_match_screen.dart';
import '../../match/screens/match_detail_screen.dart';

final homeNotifierProvider =
    StateNotifierProvider.autoDispose<HomeNotifier, HomeState>((ref) {
  return HomeNotifier(
    ref: ref,
    homeRepository: ref.read(homeRepositoryProvider),
    playerRepository: ref.read(playerRepositoryProvider),
    authRepository: ref.read(authRepositoryProvider),
  );
});

class HomeNotifier extends SafeStateNotifier<HomeState> {
  final HomeRepository homeRepository;
  final PlayerRepository playerRepository;
  final AuthRepository authRepository;

  HomeNotifier({
    required Ref ref,
    required this.homeRepository,
    required this.playerRepository,
    required this.authRepository,
  }) : super(ref, HomeState.initial()) {
    Future.microtask(load);
  }

  Future<void> load() async {
    final cached = homeRepository.getCachedSetup();
    if (cached != null) {
      safeSetState(state.copyWith(setup: AsyncValue.data(cached)));
    }

    final setup = await runUiWithResult<HomeSetup>(
      () => homeRepository.fetchSetup(),
      showLoading: (cached == null),
      successSnack: null,
    );
    if (!mounted) return;

    safeSetState(state.copyWith(setup: AsyncValue.data(setup)));
  }

  Future<void> loadChartPlayersIfNeeded() async {
    // nechceme znovu volat, pokud už máme data (nebo už probíhá loading)
    if (state.chartPlayers is AsyncLoading) return;
    final current = state.chartPlayers.asData?.value;
    if (current != null && current.isNotEmpty) return;
    safeSetState(state.copyWith(chartPlayers: const AsyncValue.loading()));
    final cached = playerRepository.getCachedList();
    if (cached != null) {
      safeSetState(state.copyWith(chartPlayers: AsyncValue.data(cached)));
    }
    await guardSet<List<PlayerApiModel>>(
      action: () => runUiWithResult<List<PlayerApiModel>>(
        () => playerRepository.fetchList(),
        showLoading: false,
        successSnack: null,
      ),
      reduce: (result) => state.copyWith(chartPlayers: result),
    );
  }

  Future<void> refreshChartPlayers() async {
    safeSetState(state.copyWith(chartPlayers: const AsyncValue.loading()));
    await guardSet<List<PlayerApiModel>>(
      action: () => runUiWithResult<List<PlayerApiModel>>(
        () => playerRepository.fetchList(),
        showLoading: false,
        successSnack: null,
      ),
      reduce: (result) => state.copyWith(chartPlayers: result),
    );
  }

  // ====== callbacks (nahrazuje IFootballMatchBoxCallback atd.) ======

  void onButtonAddBeerClick(FootballMatchApiModel footballMatch) {
    final appTeam = ref.read(globalVariablesControllerProvider).appTeam;
    final matchId = footballMatch
            .findMatchIdForCurrentAppTeamInMatchIdAndAppTeamIdList(appTeam) ??
        -1;
    if (matchId != -1) {
      ref.read(screenVariablesNotifierProvider.notifier).setMatchId(matchId);
      changeFragment(BeerSimpleScreen.id);
    }
  }

  void onButtonAddFineClick(FootballMatchApiModel footballMatch) {
    final appTeam = ref.read(globalVariablesControllerProvider).appTeam;
    final matchId = footballMatch
            .findMatchIdForCurrentAppTeamInMatchIdAndAppTeamIdList(appTeam) ??
        -1;
    if (matchId != -1) {
      ref.read(screenVariablesNotifierProvider.notifier).setMatchId(matchId);
      changeFragment(FineMatchScreen.id);
    }
  }

  void onButtonAddGoalsClick(FootballMatchApiModel footballMatch) {
    final appTeam = ref.read(globalVariablesControllerProvider).appTeam;
    final matchId = footballMatch
            .findMatchIdForCurrentAppTeamInMatchIdAndAppTeamIdList(appTeam) ??
        -1;
    if (matchId != -1) {
      ref.read(screenVariablesNotifierProvider.notifier).setMatchId(matchId);
      changeFragment(GoalScreen.id);
    }
  }

  void onButtonAddPlayersClick(FootballMatchApiModel footballMatch) {
    final appTeam = ref.read(globalVariablesControllerProvider).appTeam;
    final matchId = footballMatch
            .findMatchIdForCurrentAppTeamInMatchIdAndAppTeamIdList(appTeam) ??
        -1;

    if (matchId == -1) {
      ref.read(screenVariablesNotifierProvider.notifier).setMatchNotifierArgs(
          MatchNotifierArgs.newByFootballMatch(footballMatch));
      changeFragment(AddMatchScreen.id);
    } else {
      ref
          .read(screenVariablesNotifierProvider.notifier)
          .setMatchNotifierArgs(MatchNotifierArgs.edit(matchId));
      changeFragment(MatchDetailScreen.id);
    }
  }

  void onButtonDetailMatchClick(FootballMatchApiModel footballMatch) {
    ref.read(screenVariablesNotifierProvider.notifier).setMatchNotifierArgs(
        MatchNotifierArgs.footballMatchDetail(footballMatch));
    changeFragment(MatchDetailScreen.id);
  }

  void onCommonMatchesClick(FootballMatchApiModel footballMatch) {
    ref
        .read(screenVariablesNotifierProvider.notifier)
        .setMatchNotifierArgs(MatchNotifierArgs.mutualMatches(footballMatch));
    changeFragment(MatchDetailScreen.id);
  }

  Future<void> onPlayerPicked(PlayerApiModel player) async {
    await runUiWithResult<void>(
      () async {
        await authRepository.setUserPlayerId(player);
        // po změně playera přetáhnout home setup z API:
        final setup = await homeRepository.fetchSetup();
        safeSetState(state.copyWith(setup: AsyncValue.data(setup)));
      },
      loadingMessage: "Přepínám hráče…",
      showLoading: true,
      successSnack: null,
    );
  }
}
