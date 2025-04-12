import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/config.dart';
import 'package:trus_app/models/api/football/detail/football_team_detail.dart';
import 'package:trus_app/models/api/football/football_match_api_model.dart';
import 'package:trus_app/models/api/football/football_player_api_model.dart';
import 'package:trus_app/models/api/football/stats/football_all_individual_stats_api_model.dart';
import 'package:trus_app/models/api/football/table_team_api_model.dart';

import '../../../models/api/football/detail/football_match_detail.dart';
import '../../../models/api/interfaces/json_and_http_converter.dart';
import '../../../models/helper/title_and_text.dart';
import '../../general/repository/crud_api_service.dart';

final footballApiServiceProvider =
    Provider<FootballApiService>((ref) => FootballApiService(ref));

class FootballApiService extends CrudApiService {
  FootballApiService(super.ref);


  Future<List<FootballMatchApiModel>> getTeamFixtures() async {
    final decodedBody =
    await getModelsWithVariableEndpoint<JsonAndHttpConverter>(
        football, null, "fixtures");
    return decodedBody.map((model) => model as FootballMatchApiModel).toList();
  }

  Future<List<TableTeamApiModel>> getFootballTable() async {
    final decodedBody =
    await getModelsWithoutGetAll<JsonAndHttpConverter>(
        footballTableApi, null);
    return decodedBody.map((model) => model as TableTeamApiModel).toList();
  }

  Future<List<FootballAllIndividualStatsApiModel>> getPlayerStats(bool currentSeason) async {
    final queryParameters = {
      'currentSeason': currentSeason.toString(),
    };
    final decodedBody =
    await getModelsWithoutGetAll<JsonAndHttpConverter>(footballAllIndividualStatsApi, queryParameters);
    return decodedBody.map((model) => model as FootballAllIndividualStatsApiModel).toList();
  }

  Future<FootballMatchDetail> getFootballMatchDetail(int footballMatchId) async {
    final String url = "$serverUrl/$football/detail/$footballMatchId";
    final FootballMatchDetail footballMachDetail = await executeGetRequest(
        Uri.parse(url),
            (dynamic json) => FootballMatchDetail.fromJson(json), null);
    return footballMachDetail;
  }

  Future<FootballTeamDetail> getFootballTeamDetail(int tableTeamId) async {
    final String url = "$serverUrl/$football/team-detail/$tableTeamId";
    final FootballTeamDetail footballTeamDetail = await executeGetRequest(
        Uri.parse(url),
            (dynamic json) => FootballTeamDetail.fromJson(json), null);
    return footballTeamDetail;
  }

  Future<List<FootballPlayerApiModel>> getFootballPlayers() async {
    final decodedBody = await getModels<JsonAndHttpConverter>(footballPlayerApi, null);
    return decodedBody.map((model) => model as FootballPlayerApiModel).toList();
  }

  Future<List<TitleAndText>> getPlayerFacts(int playerId) async {
    final String url = "$serverUrl/$football/player-facts?playerId=$playerId";
    final List<TitleAndText> titleAndText = await executeGetRequest(
        Uri.parse(url),
            (dynamic json) => (json as List<dynamic>)
            .map((item) => TitleAndText.fromJson(item))
            .toList(),
        null);
    return titleAndText;
  }
}
