import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:trus_app/common/repository/exception/bad_format_exception.dart';
import 'package:trus_app/common/repository/exception/server_exception.dart';
import 'package:trus_app/config.dart';
import 'package:trus_app/models/api/goal/goal_list_multi_add.dart';
import 'package:trus_app/models/api/goal/goal_setup.dart';
import 'package:trus_app/models/api/match/match_setup.dart';
import 'package:trus_app/models/api/receivedfine/received_fine_api_model.dart';

import '../../../../models/api/interfaces/json_and_http_converter.dart';
import '../../../../models/api/receivedfine/received_fine_detailed_response.dart';
import '../../../../models/api/receivedfine/received_fine_list.dart';
import '../../../../models/api/receivedfine/received_fine_response.dart';
import '../../../../models/api/receivedfine/received_fine_setup.dart';
import '../../../general/repository/crud_api_service.dart';

final fineMatchApiServiceProvider =
    Provider<FineMatchApiService>((ref) => FineMatchApiService());

class FineMatchApiService extends CrudApiService {
  Future<ReceivedFineSetup> setupFineMatch(int? matchId, int? seasonId) async {
    final queryParameters = {
      'seasonId': intToString(seasonId),
      'matchId': intToString(matchId),
    };
    const String url = "$serverUrl/$receivedFineApi/setup";
    final ReceivedFineSetup receivedFineSetup = await executeGetRequest(
        Uri.parse(url),
        (dynamic json) => ReceivedFineSetup.fromJson(json),
        queryParameters);
    return receivedFineSetup;
  }

  Future<List<ReceivedFineApiModel>> setupFinePlayer(
      int playerId, int matchId) async {
    final queryParameters = {
      'playerId': playerId.toString(),
      'matchId': matchId.toString(),
    };
    final decodedBody =
        await getModelsWithVariableEndpoint<JsonAndHttpConverter>(
            receivedFineApi, queryParameters, "player/setup");
    return decodedBody.map((model) => model as ReceivedFineApiModel).toList();
  }

  Future<ReceivedFineResponse> addFines(
      ReceivedFineList receivedFineList, bool multiple) async {
    final Map<String, dynamic> requestPayload = receivedFineList.toJson();
    String url;
    if (multiple) {
      url = "$serverUrl/$receivedFineApi/multiple-add";
    } else {
      url = "$serverUrl/$receivedFineApi/player-add";
    }
    try {
      final ReceivedFineResponse response = await executePostRequest(
          Uri.parse(url),
          (dynamic json) => ReceivedFineResponse.fromJson(json),
          jsonEncode(requestPayload));
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<ReceivedFineDetailedResponse> getDetailedReceivedFines(
      int? matchId,
      int? seasonId,
      int? playerId,
      bool? matchStatsOrPlayerStats,
      bool? detailed,
      String? filter) async {
    final queryParameters = {
      'seasonId': intToString(seasonId),
      'matchId': intToString(matchId),
      'playerId': intToString(playerId),
      'matchStatsOrPlayerStats': boolToString(matchStatsOrPlayerStats),
      'detailed': boolToString(detailed),
      'stringFilter': filter,
    };
    const String url = "$serverUrl/$receivedFineApi/get-all-detailed";
    final ReceivedFineDetailedResponse receivedFineDetailedResponse =
        await executeGetRequest(
            Uri.parse(url),
            (dynamic json) => ReceivedFineDetailedResponse.fromJson(json),
            queryParameters);
    return receivedFineDetailedResponse;
  }
}
