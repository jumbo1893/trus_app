import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/config.dart';
import 'package:trus_app/models/api/beer/beer_detailed_response.dart';
import 'package:trus_app/models/api/interfaces/detailed_response_model.dart';

import '../../../models/api/attendance/attendance_detailed_response.dart';
import '../../../models/api/goal/goal_detailed_response.dart';
import '../../../models/api/receivedfine/received_fine_detailed_response.dart';
import '../../../models/api/receivedfine/stats/received_fine_stats_detail_models.dart';
import '../../general/repository/crud_api_service.dart';
import '../filter/statistics_filter.dart';
import '../../../models/api/fine_api_model.dart';

final statsApiServiceProvider = Provider<StatsApiService>(
  (ref) => StatsApiService(ref),
);

class StatsApiService extends CrudApiService {
  StatsApiService(super.ref);

  Future<List<FineApiModel>> getFineOptions() => executeGetRequest(
    Uri.parse('$serverUrl/$fineApi/statistics/options'),
    (dynamic json) =>
        (json as List).map((item) => FineApiModel.fromJson(item)).toList(),
    null,
  );

  Future<List<String>> getOpponents() => executeGetRequest(
    Uri.parse('$serverUrl/$matchApi/statistics/opponents'),
    (dynamic json) => List<String>.from(json as List),
    null,
  );

  Future<DetailedResponseModel> getDetailedStats(
    int? matchId,
    int? seasonId,
    int? playerId,
    bool? matchStatsOrPlayerStats,
    String? filter,
    bool? detailed,
    String api, {
    StatisticsFilter advancedFilter = const StatisticsFilter(),
  }) async {
    final queryParameters = {
      'seasonId': intToString(seasonId),
      'matchId': intToString(matchId),
      'playerId': intToString(playerId),
      'matchStatsOrPlayerStats': boolToString(matchStatsOrPlayerStats),
      'detailed': boolToString(detailed),
      'stringFilter': filter,
      ...advancedFilter.toQueryParameters(),
    };
    String url = "$serverUrl/$api/get-all-detailed";
    final DetailedResponseModel detailedResponseModel = await executeGetRequest(
      Uri.parse(url),
      getMapFunction(api),
      queryParameters,
    );
    return detailedResponseModel;
  }

  Future<ReceivedFineMatchDetailResponse> getReceivedFineMatchDetail(
    int matchId, {
    StatisticsFilter advancedFilter = const StatisticsFilter(),
  }) async {
    final queryParameters = {
      'matchId': intToString(matchId),
      ...advancedFilter.toQueryParameters(),
    };
    const url = "$serverUrl/$receivedFineApi/statistics/match-detail";
    return executeGetRequest(
      Uri.parse(url),
      (dynamic json) => ReceivedFineMatchDetailResponse.fromJson(json),
      queryParameters,
    );
  }

  Future<ReceivedFinePlayerDetailResponse> getReceivedFinePlayerDetail(
    int playerId,
    int? seasonId, {
    StatisticsFilter advancedFilter = const StatisticsFilter(),
  }) async {
    final queryParameters = {
      'playerId': intToString(playerId),
      'seasonId': intToString(seasonId),
      ...advancedFilter.toQueryParameters(),
    };
    const url = "$serverUrl/$receivedFineApi/statistics/player-detail";
    return executeGetRequest(
      Uri.parse(url),
      (dynamic json) => ReceivedFinePlayerDetailResponse.fromJson(json),
      queryParameters,
    );
  }

  DetailedResponseModel Function(dynamic) getMapFunction(String api) {
    switch (api) {
      case goalApi:
        return (dynamic json) => GoalDetailedResponse.fromJson(json);
      case beerApi:
        return (dynamic json) => BeerDetailedResponse.fromJson(json);
      case receivedFineApi:
        return (dynamic json) => ReceivedFineDetailedResponse.fromJson(json);
      case attendanceApi:
        return (dynamic json) => AttendanceDetailedResponse.fromJson(json);
      default:
        return (dynamic json) => GoalDetailedResponse.fromJson(json);
    }
  }
}
