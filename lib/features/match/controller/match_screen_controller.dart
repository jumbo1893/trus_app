import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/config.dart';
import 'package:trus_app/features/season/repository/season_api_service.dart';
import 'package:trus_app/models/api/season_api_model.dart';
import '../../../common/utils/season_util.dart';
import '../../../models/api/match/match_api_model.dart';
import '../../general/read_operations.dart';
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
    if(screenPickedSeason == null) {
      setPickedSeason(returnCurrentSeason(seasonList));
    }
    else {
      setPickedSeason(returnSeasonById(seasonList, screenPickedSeason!.id!));
    }
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
