import 'dart:async';
import 'dart:collection';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/features/pkfl/tasks/retrieve_match_detail_task.dart';
import 'package:trus_app/features/pkfl/tasks/retrieve_matches_task.dart';
import 'package:trus_app/features/pkfl/tasks/retrieve_season_url_task.dart';
import 'package:trus_app/models/enum/spinner_options.dart';
import 'package:trus_app/models/pkfl/pkfl_match.dart';
import 'package:trus_app/models/pkfl/pkfl_player_stats.dart';
import 'package:trus_app/models/pkfl/pkfl_season.dart';
import '../../../models/pkfl/pkfl_match_player.dart';
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
    return pkflRepository.getPkflUrl();
  }

  Future<List<PkflMatch>> getPkflMatches() async {
    String url = "";
    List<PkflMatch> matches = [];
    url = await pkflRepository.getPkflUrl();
    RetrieveMatchesTask matchesTask = RetrieveMatchesTask(url);
    try {
      await matchesTask.returnPkflMatches().then((value) => matches = value);
    } catch (e, stacktrace) {
      print(stacktrace);
      snackBarController.add(e.toString());
    }
    return matches;
  }
}
