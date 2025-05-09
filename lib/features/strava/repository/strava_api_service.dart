
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/config.dart';
import 'package:trus_app/models/api/strava/athlete_activities.dart';

import '../../../models/api/interfaces/json_and_http_converter.dart';
import '../../general/repository/crud_api_service.dart';

final stravaApiServiceProvider =
    Provider<StravaApiService>((ref) => StravaApiService(ref));

class StravaApiService extends CrudApiService {
  StravaApiService(super.ref);

  Future<List<AthleteActivities>> getFootballMatchActivities(int footballMatchId) async {
    final queryParameters = {
      'footballMatchId': footballMatchId.toString(),
    };
    final decodedBody =
    await getModelsWithVariableEndpoint<JsonAndHttpConverter>(stravaApi, queryParameters, "get-football-match");
    return decodedBody.map((model) => model as AthleteActivities).toList();
  }

  Future<void> syncActivities() async {
    const String url = "$serverUrl/$stravaApi/sync";
    return await executePostRequest(Uri.parse(url), (_) => null, jsonEncode(null));
  }

  Future<String> connectToStrava() async {
    const String url = "$serverUrl/$stravaApi/connect";
    return await executeGetRequest<String>(
      Uri.parse(url),
          (json) => json["url"] as String,
      null,
    );
  }
}
