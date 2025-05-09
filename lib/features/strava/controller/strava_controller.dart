import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/features/match/repository/match_api_service.dart';
import 'package:trus_app/features/strava/repository/strava_api_service.dart';
import 'package:trus_app/models/api/strava/athlete_activities.dart';

import '../../../models/api/match/match_api_model.dart';
import '../../general/read_operations.dart';

final stravaControllerProvider = Provider((ref) {
  final stravaApiService = ref.watch(stravaApiServiceProvider);
  final matchApiService = ref.watch(matchApiServiceProvider);
  return StravaController(
      stravaApiService: stravaApiService,
      matchApiService: matchApiService,
      ref: ref);
});

class StravaController implements ReadOperations {
  final StravaApiService stravaApiService;
  final MatchApiService matchApiService;
  final Ref ref;
  final matchListController =
      StreamController<List<MatchApiModel>>.broadcast();
  final pickedMatchController =
  StreamController<MatchApiModel>.broadcast();
  final athleteActivitiesListStream =
  StreamController<List<AthleteActivities>>.broadcast();
  MatchApiModel? screenPickedMatch;
  List<MatchApiModel> matchList = [];

  StravaController({
    required this.stravaApiService,
    required this.matchApiService,
    required this.ref,
  });

  Stream<List<AthleteActivities>> streamAthleteActivities() {
    return athleteActivitiesListStream.stream;
  }

  Stream<List<MatchApiModel>> matches() {
    return matchListController.stream;
  }

  Stream<MatchApiModel> pickedMatch() {
    return pickedMatchController.stream;
  }

  void setCurrentMatch() {
    if(screenPickedMatch == null) {
      setPickedMatch(returnLastMatch(matchList));
    }
    else {
      setPickedMatch(returnMatchById(matchList, screenPickedMatch!.id!));
    }
  }

  MatchApiModel returnLastMatch(List<MatchApiModel> matchList) {
    final now = DateTime.now();

    final pastMatches = matchList.where((match) => match.date.isBefore(now)).toList();

    if (pastMatches.isEmpty) {
      throw ArgumentError("Neexistuje žádný odehraný zápas (v minulosti).");
    }

    return pastMatches.reduce((a, b) => a.date.isAfter(b.date) ? a : b);
  }

  MatchApiModel returnMatchById(List<MatchApiModel> matchList, int id) {
    return matchList.firstWhere((match) => match.id == id, orElse: () => matchList[0]);
  }

  Future<void> setPickedMatch(MatchApiModel match) async {
    pickedMatchController.add(match);
    screenPickedMatch = match;
    athleteActivitiesListStream.add(await getModels());
  }

  Future<List<MatchApiModel>> getMatches() async {
    matchList = await matchApiService.getMatches();
    return matchList;
  }

  @override
  Future<List<AthleteActivities>> getModels() async {
    if(screenPickedMatch == null) {
      return [];
    }
    else {
      return await stravaApiService.getFootballMatchActivities(screenPickedMatch!.footballMatch!.id!);
    }
  }

  Future<void> syncMatches() async {
    await stravaApiService.syncActivities();
    setCurrentMatch();
  }

  Future<String> getUrlStravaConnection() async {
    return await stravaApiService.connectToStrava();
  }
}
