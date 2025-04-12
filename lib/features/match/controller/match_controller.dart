import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/features/general/global_variables_controller.dart';
import 'package:trus_app/features/match/widget/i_match_hash_key.dart';
import 'package:trus_app/features/mixin/boolean_controller_mixin.dart';
import 'package:trus_app/features/mixin/checked_list_controller_mixin.dart';
import 'package:trus_app/features/mixin/date_controller_mixin.dart';
import 'package:trus_app/features/mixin/string_controller_mixin.dart';
import 'package:trus_app/models/api/football/helper/mutual_matches.dart';
import 'package:trus_app/models/api/player/player_api_model.dart';
import 'package:trus_app/models/api/season_api_model.dart';

import '../../../common/static_text.dart';
import '../../../common/utils/field_validator.dart';
import '../../../models/api/football/detail/football_match_detail.dart';
import '../../../models/api/football/football_match_api_model.dart';
import '../../../models/api/match/match_api_model.dart';
import '../../../models/api/match/match_setup.dart';
import '../../../models/enum/match_detail_options.dart';
import '../../football/repository/football_api_service.dart';
import '../../general/crud_operations.dart';
import '../../mixin/dropdown_controller_mixin.dart';
import '../repository/match_api_service.dart';

final matchControllerProvider = Provider((ref) {
  final footballApiService = ref.watch(footballApiServiceProvider);
  final matchApiService = ref.watch(matchApiServiceProvider);
  final globalVariablesController = ref.watch(globalVariablesControllerProvider);
  return MatchController(
      footballApiService: footballApiService,
      matchApiService: matchApiService,
      globalVariablesController: globalVariablesController,
      ref: ref);
});

class MatchController with DropdownControllerMixin, StringControllerMixin, DateControllerMixin, CheckedListControllerMixin, BooleanControllerMixin, IMatchHashKey implements CrudOperations {
  final FootballApiService footballApiService;
  final MatchApiService matchApiService;
  final GlobalVariablesController globalVariablesController;
  final Ref ref;
  final connectWithFootballController = StreamController<bool>.broadcast();
  final matchDetailScreenController = StreamController<int>.broadcast();
  String originalOpponentName = "";
  bool connectWithFootballMatch = true;
  late MatchSetup matchSetup;
  FootballMatchDetail? footballMatchDetail;
  FootballMatchApiModel? footballMatch;
  int matchOptionIndex = 0;
  List<MatchDetailOptions> defaultMatchDetailOptions = [];

  MatchController({
    required this.footballApiService,
    required this.matchApiService,
    required this.globalVariablesController,
    required this.ref,
  });

  Future<void> loadNewMatch() async {
    initStringFields("", nameKey());
    initDateFields(DateTime.now(), dateKey());
    initDropdown(matchSetup.primarySeason, matchSetup.seasonList, seasonKey());
    initCheckedListFields(matchSetup.playerList, [], playerKey());
    initCheckedListFields(matchSetup.fanList, [], fanKey());
    initBooleanFields(true, homeKey());
    footballMatch = matchSetup.footballMatch;
    setupFootballController();
  }

  void loadEditMatch() {
    initStringFields(matchSetup.match!.name, nameKey());
    originalOpponentName = matchSetup.match!.name;
    initDateFields(matchSetup.match!.date, dateKey());
    initDropdown(matchSetup.primarySeason, matchSetup.seasonList, seasonKey());
    initCheckedListFields(matchSetup.playerList, _getListOfPlayersByIds(matchSetup.playerList, matchSetup.match!.playerIdList), playerKey());
    initCheckedListFields(matchSetup.fanList, _getListOfPlayersByIds(matchSetup.fanList, matchSetup.match!.playerIdList), fanKey());
    initBooleanFields(matchSetup.match!.home, homeKey());
    footballMatch = matchSetup.footballMatch;
    setupFootballController();
  }

  Future<void> loadNewMatchByFootballMatch(FootballMatchApiModel footballMatch) async {
    initStringFields(getOpponentName(footballMatch), nameKey());
    initDateFields(footballMatch.date, dateKey());
    initDropdown(matchSetup.primarySeason, matchSetup.seasonList, seasonKey());
    initCheckedListFields(matchSetup.playerList, [], playerKey());
    initCheckedListFields(matchSetup.fanList, [], fanKey());
    initBooleanFields(isHomeMatch(footballMatch), homeKey());
    setupFootballController();
  }

  int getInitialIndex(MatchDetailOptions preferredScreen,
      List<MatchDetailOptions> availableOptions) {
    if (preferredScreen == MatchDetailOptions.editMatch) {
      matchOptionIndex = 0;
    } else if (preferredScreen == MatchDetailOptions.footballMatchDetail) {
      if (availableOptions.contains(MatchDetailOptions.editMatch) &&
          availableOptions.contains(MatchDetailOptions.footballMatchDetail)) {
        matchOptionIndex =  1;
      } else {
        matchOptionIndex =  0;
      }
    } else {
      if (availableOptions.contains(MatchDetailOptions.editMatch)) {
        if (availableOptions.contains(MatchDetailOptions.mutualMatches)) {
          matchOptionIndex =  4;
        } else if (availableOptions
            .contains(MatchDetailOptions.footballMatchDetail)) {
          matchOptionIndex =  1;
        } else {
          matchOptionIndex =  0;
        }
      } else {
        if (availableOptions.contains(MatchDetailOptions.mutualMatches)) {
          matchOptionIndex = 3;
        }
      }
    }
    return matchOptionIndex;
  }

  String getOpponentName(FootballMatchApiModel footballMatch) {
    int userTeamId = globalVariablesController.appTeam!.team.id;
    if(footballMatch.homeTeam == null) {
      return "";
    }
    else if(userTeamId == footballMatch.homeTeam!.id) {
      return footballMatch.awayTeam!.name;
    }
    else if(footballMatch.awayTeam == null) {
      return "";
    }
    else if(userTeamId == footballMatch.awayTeam!.id) {
      return footballMatch.homeTeam!.name;
    }
    return "";
  }

  bool isHomeMatch(FootballMatchApiModel footballMatch) {
    int userTeamId = globalVariablesController.appTeam!.team.id;
    if(footballMatch.homeTeam != null && userTeamId == footballMatch.homeTeam!.id) {
      return true;
    }
    else if(footballMatch.awayTeam != null && userTeamId == footballMatch.awayTeam!.id) {
      return false;
    }
    return true;
  }

  void setupFootballController() {
    if(footballMatch != null) {
      connectWithFootballMatch = true;
    }
    else {
      connectWithFootballMatch = false;
    }
    connectWithFootballController.add(connectWithFootballMatch);
  }

  List<PlayerApiModel> _getListOfPlayersByIds(
      List<PlayerApiModel> players, List<int> playerIdList) {
    List<PlayerApiModel> returnList = [];
    PlayerApiModel? findPlayer(List<PlayerApiModel> players, int playerId) =>
        players.firstWhereOrNull((e) => e.id == playerId);
    for (int playerId in playerIdList) {
      PlayerApiModel? player = findPlayer(players, playerId);
      if (player != null) {
        returnList.add(player);
      }
    }
    return returnList;
  }

  Future<void> newMatch() async {
    await Future.delayed(Duration.zero, () => loadNewMatch());
  }

  Future<void> newMatchByFootballMatch(FootballMatchApiModel footballMatch) async {
    this.footballMatch = footballMatch;
    await Future.delayed(
        Duration.zero, () => loadNewMatchByFootballMatch(footballMatch));
  }

  Future editMatch() async {
    Future.delayed(Duration.zero, () => loadEditMatch());
  }

  Future<void> setupNewMatch() async {
    matchSetup = await _setupMatch(null);
    footballMatch = matchSetup.footballMatch; //musíme udělat předtim, než to vrátíme
  }

  Future<void> setupEditMatch(int id) async {
    matchSetup = await _setupMatch(id);
    footballMatch = matchSetup.footballMatch;
  }

  MatchApiModel returnEditMatch() {
    return matchSetup.match!;
  }

  FootballMatchApiModel returnFootballMatch() {
      return footballMatchDetail!.footballMatch;
  }

  Future<MutualMatches> returnMutualMatches() async {
    return MutualMatches(mutualMatches: footballMatchDetail!.mutualMatches, aggregateScore: footballMatchDetail!.aggregateScore, aggregateMatches: footballMatchDetail!.aggregateMatches);
  }

  Future<List<MatchDetailOptions>> loadFootballMatchDetail(int? footballMatchId, bool editMatch) async {
    List<MatchDetailOptions> matchDetailOptions = [];
    if(footballMatchId != null) {
      footballMatchDetail = await getFootballMatchDetail(footballMatchId);
      matchDetailOptions.add(MatchDetailOptions.footballMatchDetail);
      matchDetailOptions.add(MatchDetailOptions.homeMatchDetail);
      matchDetailOptions.add(MatchDetailOptions.awayMatchDetail);
      if(footballMatchDetail!.mutualMatches.isNotEmpty) {
        matchDetailOptions.add(MatchDetailOptions.mutualMatches);
      }
      int matchId = footballMatchDetail!.footballMatch.findMatchIdForCurrentAppTeamInMatchIdAndAppTeamIdList(ref.read(globalVariablesControllerProvider).appTeam);
      if(matchId != -1 && editMatch) {
        await setupEditMatch(matchId);
        matchDetailOptions.add(MatchDetailOptions.editMatch);
      }
    }
    defaultMatchDetailOptions = matchDetailOptions;
    return matchDetailOptions;
  }

  Future<List<MatchDetailOptions>> setupScreen(int? matchId, int? footballMatchId) async {
    List<MatchDetailOptions> matchDetailOptions = [];
    if(footballMatchId != null) {
      return await loadFootballMatchDetail(footballMatchId, true);
    }
    else if(matchId != null) {
      await setupEditMatch(matchId);
      matchDetailOptions.add(MatchDetailOptions.editMatch);
      if (footballMatch != null) {
        matchDetailOptions = (
            await loadFootballMatchDetail(footballMatch!.id, true));
      }
    }
    return matchDetailOptions;
  }

  Future<List<MatchDetailOptions>> setupScreenForCommonMatchesOnly(int? footballTeamId) async {
    List<MatchDetailOptions> matchDetailOptions = [];
    matchDetailOptions.add(MatchDetailOptions.mutualMatches);
    if(footballTeamId != null) {
      footballMatchDetail = await getFootballMatchDetail(footballTeamId);
    }
    return matchDetailOptions;
  }

  int getMatchDetailOptionForFootballDetail() {
    if(defaultMatchDetailOptions.contains(MatchDetailOptions.editMatch)) {
      return matchOptionIndex;
    }
    return matchOptionIndex+1;
  }

  void changeMatchDetailScreen(int option) {
    matchOptionIndex = option;
    matchDetailScreenController.add(option);
  }

  Stream<int> matchDetailScreen() {
    return matchDetailScreenController.stream;
  }

  Stream<bool> connectWithFootball() {
    return connectWithFootballController.stream;
  }

  void setConnectWithFootballMatch(bool connect) {
    connectWithFootballController.add(connect);
    connectWithFootballMatch = connect;
  }

  bool validateFields() {
    String errorText = validateEmptyField(stringValues[nameKey()]!.trim());
    String playerErrorText;
    if (checkedModelsLists[playerKey()]!.isEmpty) {
      playerErrorText = atLeastOnePlayerMustBePresentValidation;
    } else {
      playerErrorText = "";
    }
    stringErrorTextControllers[nameKey()]!.add(errorText);
    checkedListsErrorTextControllers[playerKey()]!.add(playerErrorText);
    return errorText.isEmpty && playerErrorText.isEmpty;
  }

  Future<MatchSetup> _setupMatch(int? id) async {
    return await matchApiService.setupMatch(id);
  }

  Future<FootballMatchDetail> getFootballMatchDetail(int id) async {
    return await footballApiService.getFootballMatchDetail(id);
  }

  Future<FootballMatchDetail> getFootballTeamDetail(int id) async {
    return await footballApiService.getFootballMatchDetail(id);
  }

  @override
  Future<MatchApiModel?> addModel() async {
    if (validateFields()) {
      return await matchApiService.addMatch(MatchApiModel.withPlayers(
          name: stringValues[nameKey()]!,
          date: dateValues[dateKey()]!,
          seasonId: (dropdownValues[seasonKey()] as SeasonApiModel).id!,
          home: boolValues[homeKey()]!,
          players: checkedModelsLists[playerKey()]!.cast<PlayerApiModel>() + checkedModelsLists[fanKey()]!.cast<PlayerApiModel>(),
          footballMatch: connectWithFootballMatch ? footballMatch : null));
    }
    return null;
  }

  @override
  Future<String> deleteModel(int id) async {
    await matchApiService.deleteMatch(id);
    return "Zápas se soupeřem $originalOpponentName úspěšně smazán";
  }

  @override
  Future<String?> editModel(int id) async {
    if (validateFields()) {
      MatchApiModel response = await matchApiService.editMatch(
          MatchApiModel.withPlayers(
              footballMatch: connectWithFootballMatch ? footballMatch : null,
              id: id,
              name: stringValues[nameKey()]!,
              date: dateValues[dateKey()]!,
              seasonId: (dropdownValues[seasonKey()] as SeasonApiModel).id!,
              home: boolValues[homeKey()]!,
              players: checkedModelsLists[playerKey()]!.cast<PlayerApiModel>() + checkedModelsLists[fanKey()]!.cast<PlayerApiModel>()),
          id);

      return response.toStringForEdit(originalOpponentName);
    }
    return null;
  }
  @override
  String dateKey() {
    return "match_date";
  }

  @override
  String fanKey() {
    return "match_fan";
  }

  @override
  String homeKey() {
    return "match_home";
  }

  @override
  String nameKey() {
    return "match_name";
  }

  @override
  String playerKey() {
    return "match_player";
  }

  @override
  String seasonKey() {
    return "match_season";
  }
}
