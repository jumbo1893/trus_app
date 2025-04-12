import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/features/general/read_operations.dart';

import '../../../models/api/football/football_match_api_model.dart';
import '../repository/football_api_service.dart';

final footballControllerProvider = Provider((ref) {
  final footballApiService = ref.watch(footballApiServiceProvider);
  return FootballController(ref: ref, footballApiService: footballApiService);
});

class FootballController implements ReadOperations{
  final FootballApiService footballApiService;
  final Ref ref;
  final snackBarController = StreamController<String>.broadcast();
  FootballController({
    required this.footballApiService,
    required this.ref,
  });

  Stream<String> snackBar() {
    return snackBarController.stream;
  }

  @override
  Future<List<FootballMatchApiModel>> getModels() async {
    List<FootballMatchApiModel> matches = await footballApiService.getTeamFixtures();
    if(matches.isEmpty) {
      matches.add(FootballMatchApiModel.noMatch());
    }
    return matches;
  }
}
