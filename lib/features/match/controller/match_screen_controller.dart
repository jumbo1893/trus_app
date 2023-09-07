import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/config.dart';
import 'package:trus_app/features/fine/match/repository/fine_match_repository.dart';
import 'package:trus_app/features/match/repository/match_repository.dart';
import 'package:trus_app/features/pkfl/repository/pkfl_repository.dart';
import 'package:trus_app/features/season/repository/season_api_service.dart';
import 'package:trus_app/models/api/interfaces/model_to_string.dart';
import 'package:trus_app/models/api/player_api_model.dart';
import 'package:trus_app/models/api/season_api_model.dart';
import 'package:trus_app/models/helper/player_stats_helper_model.dart';
import 'package:trus_app/models/match_model.dart';

import '../../../common/utils/field_validator.dart';
import '../../../common/utils/season_util.dart';
import '../../../models/api/match/match_api_model.dart';
import '../../../models/pkfl/pkfl_match.dart';
import '../../../models/season_model.dart';
import '../../general/crud_operations.dart';
import '../../general/read_operations.dart';
import '../../pkfl/tasks/retrieve_matches_task.dart';
import '../repository/match_api_service.dart';

final matchScreenControllerProvider = Provider((ref) {
  final matchApiService = ref.watch(matchApiServiceProvider);
  final seasonApiService = ref.watch(seasonApiServiceProvider);
  return MatchScreenController(
      matchApiService: matchApiService,
      seasonApiService: seasonApiService,
      ref: ref);
});

class MatchScreenController implements ReadOperations {
  final MatchApiService matchApiService;
  final SeasonApiService seasonApiService;
  final ProviderRef ref;
  final seasonListController =
      StreamController<List<SeasonApiModel>>.broadcast();
  final pickedSeasonController =
  StreamController<SeasonApiModel>.broadcast();
  final matchListStream =
  StreamController<List<MatchApiModel>>.broadcast();
  SeasonApiModel? screenPickedSeason;
  List<SeasonApiModel> seasonList = [];

  MatchScreenController({
    required this.matchApiService,
    required this.seasonApiService,
    required this.ref,
  });

  Future<List<MatchApiModel>> matches() {
    return matchApiService.getMatches();
  }

  Stream<List<MatchApiModel>> streamMatches() {
    return matchListStream.stream;
  }

  Stream<List<SeasonApiModel>> seasons() {
    return seasonListController.stream;
  }

  Stream<SeasonApiModel> pickedSeason() {
    return pickedSeasonController.stream;
  }

  void setCurrentSeason() {
    setPickedSeason(returnCurrentSeason(seasonList));
  }

  Future<void> setPickedSeason(SeasonApiModel season) async {
    pickedSeasonController.add(season);
    screenPickedSeason = season;
    matchListStream.add(await getModels());
  }

  Future<List<SeasonApiModel>> getSeasons() async {
    seasonList = await seasonApiService.getSeasons(false, true, true);
    return seasonList;
  }

  @override
  Future<List<MatchApiModel>> getModels() async {
    if(screenPickedSeason == null) {
      return [];
    }
    else if(screenPickedSeason!.id == allSeasonId) {
      return await matchApiService.getMatches();
    }
    else {
      return await matchApiService.getMatchesBySeason(screenPickedSeason!.id!);
    }
  }
}
