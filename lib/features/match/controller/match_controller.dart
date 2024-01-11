import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/features/season/repository/season_api_service.dart';
import 'package:trus_app/models/api/player_api_model.dart';
import 'package:trus_app/models/api/season_api_model.dart';

import '../../../common/static_text.dart';
import '../../../common/utils/field_validator.dart';
import '../../../models/api/match/match_api_model.dart';
import '../../../models/api/match/match_setup.dart';
import '../../../models/api/pkfl/pkfl_match_api_model.dart';
import '../../../models/api/pkfl/pkfl_match_detail.dart';
import '../../../models/enum/match_detail_options.dart';
import '../../general/crud_operations.dart';
import '../../pkfl/repository/pkfl_api_service.dart';
import '../repository/match_api_service.dart';
import 'package:collection/collection.dart';

final matchControllerProvider = Provider((ref) {
  final pkflApiService = ref.watch(pkflApiServiceProvider);
  final matchApiService = ref.watch(matchApiServiceProvider);
  final seasonApiService = ref.watch(seasonApiServiceProvider);
  return MatchController(
      pkflApiService: pkflApiService,
      matchApiService: matchApiService,
      seasonApiService: seasonApiService,
      ref: ref);
});

class MatchController implements CrudOperations {
  final PkflApiService pkflApiService;
  final MatchApiService matchApiService;
  final SeasonApiService seasonApiService;
  final ProviderRef ref;
  final nameController = StreamController<String>.broadcast();
  final nameErrorTextController = StreamController<String>.broadcast();
  final seasonController = StreamController<SeasonApiModel>.broadcast();
  final playerErrorTextController = StreamController<String>.broadcast();
  final checkedFanController =
      StreamController<List<PlayerApiModel>>.broadcast();
  final checkedPlayerController =
      StreamController<List<PlayerApiModel>>.broadcast();
  final dateController = StreamController<DateTime>.broadcast();
  final homeController = StreamController<bool>.broadcast();
  final connectWithPkflController = StreamController<bool>.broadcast();
  final matchDetailScreenController = StreamController<int>.broadcast();
  String originalOpponentName = "";
  String matchName = "";
  DateTime matchDate = DateTime.now();
  bool matchHome = true;
  bool connectWithPkflMatch = true;
  List<PlayerApiModel> matchPlayers = [];
  List<PlayerApiModel> matchFans = [];
  List<SeasonApiModel> seasons = [];
  List<PlayerApiModel> players = [];
  List<PlayerApiModel> fans = [];
  SeasonApiModel matchSeason = SeasonApiModel.dummy();
  late MatchSetup matchSetup;
  PkflMatchDetail? pkflMatchDetail;
  PkflMatchApiModel? pkflMatch;

  MatchController({
    required this.pkflApiService,
    required this.matchApiService,
    required this.seasonApiService,
    required this.ref,
  });

  Future<void> loadNewMatch() async {
    matchName = "";
    nameController.add("");
    dateController.add(DateTime.now());
    setSeason(matchSetup.primarySeason);
    seasons = matchSetup.seasonList;
    players = matchSetup.playerList;
    fans = matchSetup.fanList;
    matchPlayers = [];
    matchFans = [];
    checkedPlayerController.add([]);
    checkedFanController.add([]);
    matchHome = true;
    homeController.add(true);
    nameErrorTextController.add("");
    playerErrorTextController.add("");
    pkflMatch = matchSetup.pkflMatch;
    setupPkflController();
  }

  void loadEditMatch() {
    matchName = matchSetup.match!.name;
    originalOpponentName = matchSetup.match!.name;
    nameController.add(matchSetup.match!.name);
    matchDate = matchSetup.match!.date;
    dateController.add(matchSetup.match!.date);
    setSeason(matchSetup.primarySeason);
    seasons = matchSetup.seasonList;
    players = matchSetup.playerList;
    fans = matchSetup.fanList;
    matchPlayers =
        _getListOfPlayersByIds(players, matchSetup.match!.playerIdList);
    matchFans = _getListOfPlayersByIds(fans, matchSetup.match!.playerIdList);
    checkedPlayerController.add(matchPlayers);
    checkedFanController.add(matchFans);
    matchHome = matchSetup.match!.home;
    homeController.add(matchSetup.match!.home);
    nameErrorTextController.add("");
    playerErrorTextController.add("");
    pkflMatch = matchSetup.pkflMatch;
    setupPkflController();
  }

  Future<void> loadNewMatchByPkflMatch(PkflMatchApiModel pkflMatch) async {
    String name = pkflMatch.opponent == null ? "" : pkflMatch.opponent!.name;
    matchName = name;
    nameController.add(name);
    DateTime date = pkflMatch.date;
    matchDate = date;
    dateController.add(date);
    setSeason(matchSetup.primarySeason);
    seasons = matchSetup.seasonList;
    players = matchSetup.playerList;
    fans = matchSetup.fanList;
    matchPlayers = [];
    matchFans = [];
    checkedPlayerController.add([]);
    checkedFanController.add([]);
    bool homeMatch = pkflMatch.homeMatch;
    matchHome = homeMatch;
    homeController.add(homeMatch);
    nameErrorTextController.add("");
    playerErrorTextController.add("");
    setupPkflController();
  }

  setupPkflController() {
    if(pkflMatch != null) {
      connectWithPkflMatch = true;
    }
    else {
      connectWithPkflMatch = false;
    }
    connectWithPkflController.add(connectWithPkflMatch);
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

  Future<void> newMatchByPkflMatch(PkflMatchApiModel pkflMatch) async {
    this.pkflMatch = pkflMatch;
    await Future.delayed(
        Duration.zero, () => loadNewMatchByPkflMatch(pkflMatch));
  }

  Future<void> editMatch() async {
    Future.delayed(Duration.zero, () => loadEditMatch());
  }

  Future<void> setupNewMatch() async {
    matchSetup = await _setupMatch(null);
    pkflMatch = matchSetup.pkflMatch; //musíme udělat předtim, než to vrátíme
  }

  Future<void> setupEditMatch(int id) async {
    matchSetup = await _setupMatch(id);
    pkflMatch = matchSetup.pkflMatch;
  }

  MatchApiModel returnEditMatch() {
    return matchSetup.match!;
  }

  Future<PkflMatchApiModel> returnPkflMatch() async {
      return pkflMatchDetail!.pkflMatch;
  }

  Future<PkflMatchDetail> returnPkflMatchDetail() async {
    return pkflMatchDetail!;
  }

  Future<List<MatchDetailOptions>> loadPkflMatchDetail(int? pkflMatchId, bool editMatch) async {
    List<MatchDetailOptions> matchDetailOptions = [];
    if(pkflMatchId != null) {
      pkflMatchDetail = await getPkflMatchDetail(pkflMatchId);
      matchDetailOptions.add(MatchDetailOptions.pkflDetail);
      if(pkflMatchDetail!.commonMatches.isNotEmpty) {
        matchDetailOptions.add(MatchDetailOptions.commonMatches);
      }
      if(pkflMatchDetail!.pkflMatch.matchIdList.isNotEmpty && editMatch) {
        await setupEditMatch(pkflMatchDetail!.pkflMatch.matchIdList[0]);
        matchDetailOptions.add(MatchDetailOptions.editMatch);
      }
    }
    return matchDetailOptions;
  }

  Future<List<MatchDetailOptions>> setupScreen(int? matchId, int? pkflMatchId) async {
    List<MatchDetailOptions> matchDetailOptions = [];
    if(pkflMatchId != null) {
      return await loadPkflMatchDetail(pkflMatchId, true);
    }
    else if(matchId != null) {
      await setupEditMatch(matchId);
      matchDetailOptions.add(MatchDetailOptions.editMatch);
      if (pkflMatch != null) {
        matchDetailOptions.addAll(
            await loadPkflMatchDetail(pkflMatch!.id, false));
      }
    }
    return matchDetailOptions;
  }

  Future<List<MatchDetailOptions>> setupScreenForCommonMatchesOnly(int? pkflMatchId) async {
    List<MatchDetailOptions> matchDetailOptions = [];
    matchDetailOptions.add(MatchDetailOptions.commonMatches);
    if(pkflMatchId != null) {
      pkflMatchDetail = await getPkflMatchDetail(pkflMatchId);
    }
    return matchDetailOptions;
  }

  void changeMatchDetailScreen(int option) {
    matchDetailScreenController.add(option);
  }

  Stream<int> matchDetailScreen() {
    return matchDetailScreenController.stream;
  }

  Stream<String> name() {
    return nameController.stream;
  }

  Stream<String> nameErrorText() {
    return nameErrorTextController.stream;
  }

  Stream<SeasonApiModel> season() {
    return seasonController.stream;
  }

  Future<List<SeasonApiModel>> seasonList() {
    return Future.delayed(Duration.zero, () => seasons);
  }

  Future<List<PlayerApiModel>> playerList() {
    return Future.delayed(Duration.zero, () => players);
  }

  Future<List<PlayerApiModel>> fanList() {
    return Future.delayed(Duration.zero, () => fans);
  }

  Stream<String> playerErrorText() {
    return playerErrorTextController.stream;
  }

  Stream<List<PlayerApiModel>> checkedPlayers() {
    return checkedPlayerController.stream;
  }

  Stream<List<PlayerApiModel>> checkedFans() {
    return checkedFanController.stream;
  }

  void initCheckedPlayers() {
    checkedPlayerController.add(matchPlayers);
  }

  void initCheckedFans() {
    checkedFanController.add(matchFans);
  }

  void initSeason() {
    seasonController.add(matchSeason);
  }

  Stream<bool> home() {
    return homeController.stream;
  }

  Stream<bool> connectWithPkfl() {
    return connectWithPkflController.stream;
  }

  Stream<DateTime> date() {
    return dateController.stream;
  }

  void setName(String name) {
    nameController.add(name);
    matchName = name;
  }

  void setSeason(SeasonApiModel season) {
    seasonController.add(season);
    matchSeason = season;
  }

  void setDate(DateTime date) {
    dateController.add(date);
    matchDate = date;
  }

  void setHome(bool home) {
    homeController.add(home);
    matchHome = home;
  }

  void setConnectWithPkflMatch(bool connect) {
    connectWithPkflController.add(connect);
    connectWithPkflMatch = connect;
  }

  void addPlayer(PlayerApiModel player) {
    matchPlayers.add(player);
    checkedPlayerController.add(matchPlayers);
  }

  void removePlayer(PlayerApiModel player) {
    matchPlayers.remove(player);
    checkedPlayerController.add(matchPlayers);
  }

  void addFan(PlayerApiModel fan) {
    matchFans.add(fan);
    checkedFanController.add(matchFans);
  }

  void removeFan(PlayerApiModel fan) {
    matchFans.remove(fan);
    checkedFanController.add(matchFans);
  }

  void setPlayers(List<PlayerApiModel> players) {
    matchPlayers = players;
    checkedPlayerController.add(players);
  }

  void setFans(List<PlayerApiModel> fans) {
    matchFans = fans;
    checkedFanController.add(fans);
  }

  bool validateFields() {
    String errorText = validateEmptyField(matchName.trim());
    String playerErrorText;
    if (matchPlayers.isEmpty) {
      playerErrorText = atLeastOnePlayerMustBePresentValidation;
    } else {
      playerErrorText = "";
    }
    nameErrorTextController.add(errorText);
    playerErrorTextController.add(playerErrorText);
    return errorText.isEmpty && playerErrorText.isEmpty;
  }

  Future<MatchSetup> _setupMatch(int? id) async {
    return await matchApiService.setupMatch(id);
  }

  Future<PkflMatchDetail> getPkflMatchDetail(int id) async {
    return await pkflApiService.getPkflMatchDetail(id);
  }

  @override
  Future<MatchApiModel?> addModel() async {
    if (validateFields()) {
      return await matchApiService.addMatch(MatchApiModel.withPlayers(
          name: matchName,
          date: matchDate,
          seasonId: matchSeason.id!,
          home: matchHome,
          players: matchPlayers + matchFans,
          pkflMatch: connectWithPkflMatch ? pkflMatch : null));
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
              pkflMatch: connectWithPkflMatch ? pkflMatch : null,
              id: id,
              name: matchName,
              date: matchDate,
              seasonId: matchSeason.id!,
              home: matchHome,
              players: matchPlayers + matchFans),
          id);

      return response.toStringForEdit(originalOpponentName);
    }
    return null;
  }
}
