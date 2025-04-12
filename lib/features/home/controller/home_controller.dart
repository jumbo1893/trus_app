import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/features/general/global_variables_controller.dart';
import 'package:trus_app/features/home/widget/i_chart_picked_player_callback.dart';
import 'package:trus_app/features/home/widget/i_football_match_box_callback.dart';
import 'package:trus_app/features/home/widget/i_home_setup.dart';
import 'package:trus_app/features/mixin/chart_controller_mixin.dart';
import 'package:trus_app/features/mixin/chart_list_controller_mixin.dart';
import 'package:trus_app/features/mixin/football_match_detail_controller_mixin.dart';
import 'package:trus_app/features/mixin/string_list_controller_mixin.dart';
import 'package:trus_app/features/mixin/view_controller_mixin.dart';
import 'package:trus_app/models/api/football/football_match_api_model.dart';

import '../../../models/api/home/home_setup.dart';
import '../../../models/api/player/player_api_model.dart';
import '../../../models/enum/match_detail_options.dart';
import '../../auth/repository/auth_repository.dart';
import '../../beer/screens/beer_simple_screen.dart';
import '../../fine/match/screens/fine_match_screen.dart';
import '../../football/screens/match_detail_screen.dart';
import '../../general/read_operations.dart';
import '../../goal/screen/goal_screen.dart';
import '../../main/screen_controller.dart';
import '../../match/screens/add_match_screen.dart';
import '../../player/repository/player_api_service.dart';
import '../repository/home_api_service.dart';

final homeControllerProvider = Provider((ref) {
  final homeApiService = ref.watch(homeApiServiceProvider);
  final playerApiService = ref.watch(playerApiServiceProvider);
  final authRepository = ref.watch(authRepositoryProvider);
  return HomeController(
      homeApiService: homeApiService,
      playerApiService: playerApiService,
      authRepository: authRepository,
      ref: ref);
});

final homeLoadingProvider = StateProvider<bool>((ref) => false);

class HomeController with FootballMatchDetailControllerMixin, ViewControllerMixin, ChartControllerMixin, ChartListControllerMixin, StringListControllerMixin
    implements ReadOperations, IHomeSetup, IFootballMatchBoxCallback, IChartPickedPlayerCallback {
  final HomeApiService homeApiService;
  final PlayerApiService playerApiService;
  final AuthRepository authRepository;
  final Ref ref;
  late HomeSetup homeSetup;
  int playerId = 0;

  HomeController({
    required this.homeApiService,
    required this.playerApiService,
    required this.authRepository,
    required this.ref,
  });

  void loadHomeSetupView() {
    initFootballMatchDetailFields(
       homeSetup.nextAndLastFootballMatch[0], nextMatchKey());
    initFootballMatchDetailFields(
        homeSetup.nextAndLastFootballMatch[1], lastMatchKey());
    initViewFields(
        homeSetup.nextBirthday, nextBirthdayKey());
    initChartFields(
        homeSetup.chart, chartKey());
    initChartListFields(
        homeSetup.charts, chartsKey());
    initStringListFields(
        homeSetup.randomFacts, randomFactKey());
  }

  Future<void> homeSetupView() async {
    Future.delayed(Duration.zero, () => loadHomeSetupView());
  }

  Future<void> setupPlayerId(int playerId) async {
    await authRepository.editCurrentUser(null, null, playerId);
  }

  Future<void> reloadSetupHome() async {
    homeSetup = await homeApiService.setupHome();
    await homeSetupView();
  }

  Future<void> setupHome() async {
    homeSetup = await homeApiService.setupHome();
  }

  @override
  Future<List<PlayerApiModel>> getModels() async {
    return await playerApiService.getPlayers();
  }

  @override
  String lastMatchKey() {
    return "last_match_key";
  }

  @override
  String nextMatchKey() {
    return "next_match_key";
  }

  @override
  String nextBirthdayKey() {
    return "next_birthday_key";
  }

  @override
  String chartKey() {
    return "chart_key";
  }

  @override
  String chartsKey() {
    return "charts_key";
  }

  @override
  String randomFactKey() {
    return "random_fact_key";
  }

  @override
  void onButtonAddBeerClick(FootballMatchApiModel footballMatchApiModel) {
    int matchId = footballMatchApiModel.findMatchIdForCurrentAppTeamInMatchIdAndAppTeamIdList(ref.read(globalVariablesControllerProvider).appTeam);
    if (matchId != -1) {
      ref.read(screenControllerProvider).setMatchId(matchId);
      ref.read(screenControllerProvider).changeFragment(BeerSimpleScreen.id);
    }
  }

  @override
  void onButtonAddFineClick(FootballMatchApiModel footballMatchApiModel) {
    int matchId = footballMatchApiModel.findMatchIdForCurrentAppTeamInMatchIdAndAppTeamIdList(ref.read(globalVariablesControllerProvider).appTeam);
    if (matchId != -1) {
      ref.read(screenControllerProvider).setMatchId(matchId);
      ref.read(screenControllerProvider).changeFragment(FineMatchScreen.id);
    }
  }

  @override
  void onButtonAddGoalsClick(FootballMatchApiModel footballMatchApiModel) {
    int matchId = footballMatchApiModel.findMatchIdForCurrentAppTeamInMatchIdAndAppTeamIdList(ref.read(globalVariablesControllerProvider).appTeam);
    if (matchId != -1) {
      ref.read(screenControllerProvider).setMatchId(matchId);
      ref.read(screenControllerProvider).changeFragment(GoalScreen.id);
    }
  }

  @override
  void onButtonAddPlayersClick(FootballMatchApiModel footballMatchApiModel) {
    int matchId = footballMatchApiModel.findMatchIdForCurrentAppTeamInMatchIdAndAppTeamIdList(ref.read(globalVariablesControllerProvider).appTeam);
    if (matchId == -1) {
      ref.read(screenControllerProvider).setFootballMatch(footballMatchApiModel);
      ref.read(screenControllerProvider).changeFragment(AddMatchScreen.id);
    } else {
      setScreenToEditMatch(matchId);
    }
  }

  void setScreenToEditMatch(int matchId) {
    ref
        .read(screenControllerProvider)
        .setPreferredScreen(MatchDetailOptions.editMatch);
    ref.read(screenControllerProvider).setMatchId(matchId);
    ref.read(screenControllerProvider).changeFragment(MatchDetailScreen.id);
  }

  @override
  void onButtonDetailMatchClick(FootballMatchApiModel footballMatchApiModel) {
    ref
        .read(screenControllerProvider)
        .setPreferredScreen(MatchDetailOptions.footballMatchDetail);
    ref.read(screenControllerProvider).setFootballMatch(footballMatchApiModel);
    ref.read(screenControllerProvider).changeFragment(MatchDetailScreen.id);
  }

  @override
  void onCommonMatchesClick(FootballMatchApiModel footballMatchApiModel) {
    ref
        .read(screenControllerProvider)
        .setPreferredScreen(MatchDetailOptions.mutualMatches);
    ref.read(screenControllerProvider).setFootballMatch(footballMatchApiModel);
    ref.read(screenControllerProvider).changeFragment(MatchDetailScreen.id);
  }

  @override
  Future<void> onPlayerPicked(PlayerApiModel player) async {
    final loading = ref.read(homeLoadingProvider.notifier);
    loading.state = true;
    try {
      await authRepository.setUserPlayerId(player);
      await reloadSetupHome();
    } finally {
      loading.state = false;
    }
  }

  @override
  Future<List<PlayerApiModel>> getPlayers() async {
    return await playerApiService.getPlayers();
  }
}
