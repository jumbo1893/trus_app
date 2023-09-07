import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/features/beer/repository/beer_repository.dart';
import 'package:trus_app/features/fine/match/repository/fine_match_repository.dart';
import 'package:trus_app/features/match/repository/match_repository.dart';
import 'package:trus_app/features/pkfl/repository/pkfl_repository.dart';
import 'package:trus_app/features/player/repository/player_repository.dart';
import 'package:trus_app/features/season/repository/season_repository.dart';
import 'package:trus_app/features/statistics/repository/stats_repository.dart';
import 'package:trus_app/models/helper/player_stats_helper_model.dart';
import 'package:trus_app/models/match_model.dart';
import 'package:trus_app/models/player_model.dart';

import '../../../models/api/home_setup.dart';
import '../../../models/enum/model.dart';
import '../../../models/pkfl/pkfl_match.dart';
import '../../../models/season_model.dart';
import '../../fine/repository/fine_repository.dart';
import '../../pkfl/tasks/retrieve_matches_task.dart';
import '../repository/home_api_service.dart';

final homeControllerProvider = Provider((ref) {
  final homeRepository = ref.watch(homeApiServiceProvider);
  final pkflRepository = ref.watch(pkflRepositoryProvider);
  return HomeController(
      homeRepository: homeRepository,
      pkflRepository: pkflRepository,
      ref: ref);
});

class HomeController {
  final HomeApiService homeRepository;
  final PkflRepository pkflRepository;
  final ProviderRef ref;
  String birthday = "";
  List<String> randomFacts = [];

  HomeController({
    required this.homeRepository,
    required this.pkflRepository,
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

  Future<HomeSetup> setupHome() async {
    HomeSetup homeSetup = await homeRepository.setupHome();
    birthday = homeSetup.nextBirthday;
    randomFacts = homeSetup.randomFacts;
    return homeSetup;
  }
}
