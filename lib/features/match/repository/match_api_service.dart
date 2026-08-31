import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/config.dart';
import 'package:trus_app/models/api/match/match_setup.dart';
import 'package:trus_app/models/api/match/match_stats.dart';

import '../../../models/api/interfaces/json_and_http_converter.dart';
import '../../../models/api/match/match_api_model.dart';
import '../../general/repository/crud_api_service.dart';

final matchApiServiceProvider = Provider<MatchApiService>(
  (ref) => MatchApiService(ref),
);

class MatchApiService extends CrudApiService {
  MatchApiService(super.ref);

  Future<List<MatchApiModel>> getMatches() async {
    final decodedBody = await getModels<JsonAndHttpConverter>(matchApi, null);
    return decodedBody.map((model) => model as MatchApiModel).toList();
  }

  Future<List<MatchApiModel>> getMatchesBySeason(int seasonId) async {
    final queryParameters = {'seasonId': seasonId.toString()};
    final decodedBody = await getModels<JsonAndHttpConverter>(
      matchApi,
      queryParameters,
    );
    return decodedBody.map((model) => model as MatchApiModel).toList();
  }

  Future<MatchApiModel> addMatch(MatchApiModel match) async {
    final decodedBody = await addModel<JsonAndHttpConverter>(match);
    return decodedBody as MatchApiModel;
  }

  Future<MatchApiModel> editMatch(MatchApiModel match, int id) async {
    final decodedBody = await editModel<JsonAndHttpConverter>(match, id);
    return decodedBody as MatchApiModel;
  }

  Future<bool> deleteMatch(int id) async {
    return await deleteModel(id, matchApi);
  }

  Future<MatchSetup> setupMatch(int? id, {int? footballMatchId}) async {
    final queryParameters = <String, String>{
      if (id != null) 'matchId': id.toString(),
      if (footballMatchId != null)
        'footballMatchId': footballMatchId.toString(),
    };
    final uri = Uri.parse("$serverUrl/$matchApi/setup").replace(
      queryParameters: queryParameters.isEmpty ? null : queryParameters,
    );
    final MatchSetup matchSetup = await executeGetRequest(
      uri,
      (dynamic json) => MatchSetup.fromJson(json),
      null,
    );
    return matchSetup;
  }

  Future<MatchStats> getMatchStats(int id) async {
    final String url = "$serverUrl/$matchApi/get-stats?matchId=$id";
    final MatchStats matchStats = await executeGetRequest(
      Uri.parse(url),
      (dynamic json) => MatchStats.fromJson(json),
      null,
    );
    return matchStats;
  }
}
