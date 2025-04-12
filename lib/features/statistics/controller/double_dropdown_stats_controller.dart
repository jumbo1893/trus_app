import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/features/statistics/controller/stats_controller.dart';
import 'package:trus_app/models/api/interfaces/model_to_string.dart';

import '../../../models/api/season_api_model.dart';
import '../../../models/api/stats/player_stats.dart';
import '../../../models/api/stats/stats.dart';
import '../../beer/repository/beer_api_service.dart';
import '../../season/repository/season_api_service.dart';

final doubleDropdownStatsControllerProvider = Provider((ref) {
  final beerApiRepository = ref.watch(beerApiServiceProvider);
  final seasonApiService = ref.watch(seasonApiServiceProvider);
  return DoubleDropdownStatsController(
      beerApiRepository: beerApiRepository,
      seasonApiService: seasonApiService,
      ref: ref);
});

class DoubleDropdownStatsController extends StatsController {
  final BeerApiService beerApiRepository;
  List<Stats> allStatsList = [];
  Stats? pickedDropdown;
  List<Stats> dropdownList = [];

  final pickedDropdownController =
  StreamController<Stats>.broadcast();

  DoubleDropdownStatsController({
    required this.beerApiRepository, required super.seasonApiService, required super.ref,
  });

  Stream<Stats> pickedDropDown() {
    return pickedDropdownController.stream;
  }

  Future<void> setPickedDropdown(Stats dropdown) async {
    pickedDropdown = dropdown;
    pickedDropdownController.add(dropdown);
    modelList = getPlayerStatsList();
    modelListController.add(modelList);
  }

  Future<List<Stats>> getDropDown() async {
    dropdownList = await beerApiRepository.getBeerStats(pickedSeasonId);
    return dropdownList;
  }

  @override
  Future<void> setPickedSeason(SeasonApiModel season) async {
    modelList = [];
    modelListController.add([]);
    pickedSeasonId = season.id!;
    pickedSeasonController.add(season);
    await getModelsFromRepo(season.id, matchStatsOrPlayerStats, filterText);
  }

  List<PlayerStats> getPlayerStatsList() {
    if(allStatsList.isEmpty) {
      return [];
    }
    if(pickedDropdown == null) {
      return allStatsList[0].playerStats;
    }
    for(Stats stat in allStatsList) {
      if (stat.dropdownText == pickedDropdown!.dropdownText) {
        return stat.playerStats;
      }
    }
    return pickedDropdown!.playerStats;
  }

  @override
  void initOverallStats() {
    overallStatsController.add("");
  }

  void setCurrentDropdown() {
    if(pickedDropdown == null) {
      setPickedDropdown((dropdownList.isNotEmpty ? dropdownList[0] : Stats(dropdownText: "", playerStats: [])));
    }
    else {
      setPickedDropdown(returnDropdownByText());
    }
  }

  Stats returnDropdownByText() {
    for (Stats stat in dropdownList) {
      if (pickedDropdown!.dropdownText == stat.dropdownText) {
        return stat;
      }
    }
    return dropdownList[0];
  }

  @override
  Future<void> getModelsFromRepo(int? seasonId, bool matchStatsOrPlayerStats, String? filter) async {
    List<Stats> statsList = await beerApiRepository.getBeerStats(seasonId);
    allStatsList = statsList;
    modelList = getPlayerStatsList();
    modelListController.add(modelList);
  }



  @override
  Future<void> getDetailedModelsFromRepo(int id) async {

  }

  @override
  Future<void> getDoubleDetailedModelsFromRepo(int firstId, int secondId) async {

  }

  @override
  Future<void> setDoubleDetail(ModelToString modelToString) async {

  }

  @override
  Future<void> setDetail(ModelToString modelToString) async {
  }

}
