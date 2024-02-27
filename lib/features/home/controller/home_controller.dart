import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/api/home/chart.dart';
import '../../../models/api/home/home_setup.dart';
import '../../../models/api/pkfl/pkfl_match_api_model.dart';
import '../../../models/api/player_api_model.dart';
import '../../auth/repository/auth_repository.dart';
import '../../general/read_operations.dart';
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

class HomeController implements ReadOperations {
  final HomeApiService homeApiService;
  final PlayerApiService playerApiService;
  final AuthRepository authRepository;
  final ProviderRef ref;
  String birthday = "";
  List<String> randomFacts = [];
  Chart? chart;
  int? playerId;
  PkflMatchApiModel? nextMatch;
  PkflMatchApiModel? lastMatch;
  HomeSetup? homeSetup;

  HomeController({
    required this.homeApiService,
    required this.playerApiService,
    required this.authRepository,
    required this.ref,
  });

  Future<List<String>> getRandomFacts() async {
    return randomFacts;
  }

  Future<String> getUpcomingBirthday() async {
    return birthday;
  }

  Future<PkflMatchApiModel?> getNextPkflMatch() async {
    return nextMatch;
  }

  Future<PkflMatchApiModel?> getLastPkflMatch() async {
    return lastMatch;
  }

  Future<void> setupPlayerId(int playerId) async {
    await authRepository.editCurrentUser(null, null, playerId);
  }

  Future<void> reloadSetupHome(bool? updateNeeded) async {
    HomeSetup homeSetup = await homeApiService.setupHome(playerId, updateNeeded);
    this.homeSetup = homeSetup;
  }

  Future<HomeSetup> setupHome(bool changedMatch) async {
    if(homeSetup == null || changedMatch) {
      await reloadSetupHome(false);
    }
    birthday = homeSetup!.nextBirthday;
    randomFacts = homeSetup!.randomFacts;
    chart = homeSetup!.chart;
    nextMatch = homeSetup!.nextAndLastPkflMatch[0];
    lastMatch = homeSetup!.nextAndLastPkflMatch[1];
    return homeSetup!;
  }

  @override
  Future<List<PlayerApiModel>> getModels() async {
    return await playerApiService.getPlayers();
  }
}
