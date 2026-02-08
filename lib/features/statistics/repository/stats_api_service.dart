
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/config.dart';
import 'package:trus_app/models/api/beer/beer_detailed_response.dart';
import 'package:trus_app/models/api/interfaces/detailed_response_model.dart';

import '../../../models/api/goal/goal_detailed_response.dart';
import '../../../models/api/receivedfine/received_fine_detailed_response.dart';
import '../../general/repository/crud_api_service.dart';

final statsApiServiceProvider =
    Provider<StatsApiService>((ref) => StatsApiService(ref));

class StatsApiService extends CrudApiService {
  StatsApiService(super.ref);


  Future<DetailedResponseModel> getDetailedStats(int? matchId, int? seasonId,
      int? playerId, bool? matchStatsOrPlayerStats, String? filter, bool? detailed, String api) async {
    final queryParameters = {
      'seasonId': intToString(seasonId),
      'matchId': intToString(matchId),
      'playerId': intToString(playerId),
      'matchStatsOrPlayerStats': boolToString(matchStatsOrPlayerStats),
      'detailed': boolToString(detailed),
      'stringFilter': filter,
    };
    String url = "$serverUrl/$api/get-all-detailed";
    final DetailedResponseModel detailedResponseModel = await executeGetRequest(
        Uri.parse(url),
        getMapFunction(api),
        queryParameters);
    return detailedResponseModel;
  }

  DetailedResponseModel Function(dynamic) getMapFunction(String api) {
    switch(api) {
      case goalApi: return (dynamic json) => GoalDetailedResponse.fromJson(json);
      case beerApi: return (dynamic json) => BeerDetailedResponse.fromJson(json);
      case receivedFineApi: return (dynamic json) => ReceivedFineDetailedResponse.fromJson(json);
      default: return (dynamic json) => GoalDetailedResponse.fromJson(json);
    }
  }
}
