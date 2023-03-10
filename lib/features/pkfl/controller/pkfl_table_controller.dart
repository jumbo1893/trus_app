import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/features/pkfl/tasks/retrieve_teams_task.dart';
import 'package:trus_app/models/pkfl/pkfl_team.dart';
import '../repository/pkfl_repository.dart';

final pkflTableControllerProvider = Provider((ref) {
  final pkflRepository = ref.watch(pkflRepositoryProvider);
  return PkflTableController(pkflRepository: pkflRepository, ref: ref);
});

class PkflTableController {
  final PkflRepository pkflRepository;
  final ProviderRef ref;
  final snackBarController = StreamController<String>.broadcast();
  PkflTableController({
    required this.pkflRepository,
    required this.ref,
  });

  Stream<String> snackBar() {
    return snackBarController.stream;
  }

  Future<List<PkflTeam>> getPkflTeams() async {
    String url = "";
    List<PkflTeam> teams = [];
    url = await pkflRepository.getPkflTableUrl();
    RetrieveTeamsTask teamsTask = RetrieveTeamsTask(url);
    try {
      await teamsTask.returnPkflTeams().then((value) => teams = value);
    } catch (e, stacktrace) {
      print(stacktrace);
      snackBarController.add(e.toString());
    }
    return teams;
  }
}
