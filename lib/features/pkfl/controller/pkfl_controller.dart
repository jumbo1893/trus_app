import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/features/pkfl/tasks/retrieve_match_detail_task.dart';
import 'package:trus_app/features/pkfl/tasks/retrieve_matches_task.dart';
import 'package:trus_app/features/pkfl/tasks/retrieve_season_url_task.dart';
import 'package:trus_app/models/pkfl/pkfl_match.dart';
import 'package:trus_app/models/pkfl/pkfl_season.dart';
import '../repository/pkfl_repository.dart';

final pkflControllerProvider = Provider((ref) {
  final pkflRepository = ref.watch(pkflRepositoryProvider);
  return PkflController(pkflRepository: pkflRepository, ref: ref);
});

class PkflController {
  final PkflRepository pkflRepository;
  final ProviderRef ref;
  final snackBarController = StreamController<String>.broadcast();
  PkflController({
    required this.pkflRepository,
    required this.ref,
  });

  Stream<String> snackBar() {
    return snackBarController.stream;
  }

  Future<String> url() async {
    return pkflRepository.getPkflTeamUrl();
  }

  Future<List<PkflMatch>> getPkflMatches() async {
    String url = "";
    List<PkflMatch> matches = [];
    url = await pkflRepository.getPkflTeamUrl();
    RetrieveMatchesTask matchesTask = RetrieveMatchesTask(url);
    try {
      await matchesTask.returnPkflMatches().then((value) => matches = value);
    } catch (e, stacktrace) {
      print(stacktrace);
      snackBarController.add(e.toString());
    }
    return matches;
  }

  Future<PkflMatch> getPkflMatchDetail(PkflMatch pickedMatch) async {
    RetrieveMatchDetailTask matchTask =
    RetrieveMatchDetailTask(pickedMatch.urlResult);
    try {
      await matchTask.returnPkflMatchDetail().then(
            (value) {
          pickedMatch.pkflMatchDetail = value;
        },
      );
    } catch (e, stacktrace) {
      print(stacktrace);
      snackBarController.add(e.toString());
    }
    return pickedMatch;
  }

  Future<List<PkflMatch>> getMutualPkflMatches(PkflMatch pickedPkflMatch) async {
    List<PkflMatch> matches = [];
    List<PkflMatch> returnMatches = [];
    String url = await pkflRepository.getPkflTeamUrl();
    RetrieveSeasonUrlTask retrieveSeasonUrlTask =
    RetrieveSeasonUrlTask(url, false);
    List<PkflSeason> pkflSeasons =
    await retrieveSeasonUrlTask.returnPkflSeasons();
    for (PkflSeason pkflSeason in pkflSeasons) {
      RetrieveMatchesTask retrieveMatchesTask =
      RetrieveMatchesTask(pkflSeason.url);
      matches.addAll(await retrieveMatchesTask.returnPkflMatches());
    }
    for (PkflMatch pkflMatch in matches) {
      if(pkflMatch.opponent == pickedPkflMatch.opponent) {
        RetrieveMatchDetailTask retrieveMatchDetailTask =
        RetrieveMatchDetailTask(pkflMatch.urlResult);
        pkflMatch.pkflMatchDetail ??=
        (await retrieveMatchDetailTask.returnPkflMatchDetail());
        returnMatches.add(pkflMatch);
      }
    }
    return returnMatches;
  }
}
