import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/config.dart';
import 'package:trus_app/models/api/goal/goal_list_multi_add.dart';
import 'package:trus_app/models/api/goal/goal_setup.dart';
import '../../../models/api/goal/goal_api_model.dart';
import '../../../models/api/goal/goal_detailed_response.dart';
import '../../../models/api/goal/goal_multi_add_response.dart';
import '../../../models/api/interfaces/json_and_http_converter.dart';
import '../../general/repository/crud_api_service.dart';

final goalApiServiceProvider =
    Provider<GoalApiService>((ref) => GoalApiService());

class GoalApiService extends CrudApiService {
  Future<List<GoalApiModel>> getGoals() async {
    final decodedBody = await getModels<JsonAndHttpConverter>(goalApi, null);
    return decodedBody.map((model) => model as GoalApiModel).toList();
  }

  Future<List<GoalSetup>> setupGoal(int id) async {
    final String url = "$serverUrl/$goalApi/setup?matchId=$id";
    final List<GoalSetup> goalSetups = await executeGetRequest(
        Uri.parse(url),
        (dynamic json) => (json as List<dynamic>)
            .map((item) => GoalSetup.fromJson(item))
            .toList(),
        null);
    return goalSetups;
  }

  Future<GoalMultiAddResponse> addMultipleGoals(
      GoalListMultiAdd goalListMultiAdd) async {
    final Map<String, dynamic> requestPayload = goalListMultiAdd.toJson();
    const String url = "$serverUrl/$goalApi/multiple-add";
    final GoalMultiAddResponse response = await executePostRequest(
        Uri.parse(url),
        (dynamic json) => GoalMultiAddResponse.fromJson(json),
        jsonEncode(requestPayload));
    return response;
  }

  Future<GoalDetailedResponse> getDetailedGoal(int? matchId, int? seasonId,
      int? playerId, bool? matchStatsOrPlayerStats, String? filter) async {
    final queryParameters = {
      'seasonId': intToString(seasonId),
      'matchId': intToString(matchId),
      'playerId': intToString(playerId),
      'matchStatsOrPlayerStats': boolToString(matchStatsOrPlayerStats),
      'stringFilter': filter,
    };
    const String url = "$serverUrl/$goalApi/get-all-detailed";
    final GoalDetailedResponse goalDetailedResponse = await executeGetRequest(
        Uri.parse(url),
        (dynamic json) => GoalDetailedResponse.fromJson(json),
        queryParameters);
    return goalDetailedResponse;
  }
}
