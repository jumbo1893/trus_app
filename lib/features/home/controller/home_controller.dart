import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/features/pkfl/repository/pkfl_repository.dart';

import '../../../models/api/home/chart.dart';
import '../../../models/api/home/home_setup.dart';
import '../../../models/api/player_api_model.dart';
import '../../../models/pkfl/pkfl_match.dart';
import '../../auth/repository/auth_repository.dart';
import '../../general/read_operations.dart';
import '../../pkfl/tasks/retrieve_matches_task.dart';
import '../../player/repository/player_api_service.dart';
import '../repository/home_api_service.dart';

final homeControllerProvider = Provider((ref) {
  final homeApiService = ref.watch(homeApiServiceProvider);
  final playerApiService = ref.watch(playerApiServiceProvider);
  final pkflRepository = ref.watch(pkflRepositoryProvider);
  final authRepository = ref.watch(authRepositoryProvider);
  return HomeController(
      homeApiService: homeApiService,
      playerApiService: playerApiService,
      pkflRepository: pkflRepository,
      authRepository: authRepository,
      ref: ref);
});

class HomeController implements ReadOperations {
  final HomeApiService homeApiService;
  final PlayerApiService playerApiService;
  final PkflRepository pkflRepository;
  final AuthRepository authRepository;
  final ProviderRef ref;
  String birthday = "";
  List<String> randomFacts = [];
  Chart? chart;
  int? playerId;

  HomeController({
    required this.homeApiService,
    required this.playerApiService,
    required this.pkflRepository,
    required this.authRepository,
    required this.ref,
  });

  Future<List<String>> getRandomFacts() async {
    return randomFacts;
  }

  Future<String> getUpcomingBirthday() async {
    return birthday;
  }

  Future<PkflMatch?> getNextPkflMatch() async {
    String url = "";
    List<PkflMatch> matches = [];
    url = await pkflRepository.getPkflTeamUrl();
    RetrieveMatchesTask matchesTask = RetrieveMatchesTask(url);
    try {
      await matchesTask.returnPkflMatches().then((value) => matches = value);
    } catch (e, stacktrace) {
      print(stacktrace);
    }

    return returnNextPkflMatch(matches);
  }

  PkflMatch? returnNextPkflMatch(List<PkflMatch> pkflMatches) {
    PkflMatch? returnMatch;
    for (PkflMatch pkflMatch in pkflMatches) {
      if (pkflMatch.date.isAfter(DateTime.now())) {
        if (returnMatch == null || pkflMatch.date.isBefore(returnMatch.date)) {
          returnMatch = pkflMatch;
        }
      }
    }
    return returnMatch;
  }

  Future<void> setupPlayerId(int playerId) async {
    await authRepository.editCurrentUser(null, null, playerId);
  }

  Future<HomeSetup> setupHome() async {
    HomeSetup homeSetup = await homeApiService.setupHome(playerId);
    birthday = homeSetup.nextBirthday;
    randomFacts = homeSetup.randomFacts;
    chart = homeSetup.chart;
    return homeSetup;
  }

  @override
  Future<List<PlayerApiModel>> getModels() async {
    return await playerApiService.getPlayers();
  }
}
