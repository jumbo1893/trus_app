import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:trus_app/common/repository/exception/bad_format_exception.dart';
import 'package:trus_app/common/repository/exception/server_exception.dart';
import 'package:trus_app/config.dart';
import 'package:trus_app/models/api/match/match_setup.dart';

import '../../../common/repository/exception/json_decode_exception.dart';
import '../../../models/api/fine_api_model.dart';
import '../../../models/api/interfaces/json_and_http_converter.dart';
import '../../../models/api/match/match_api_model.dart';
import '../../general/repository/crud_api_service.dart';
import '../../general/repository/request_executor.dart';

final matchApiServiceProvider =
    Provider<MatchApiService>((ref) => MatchApiService());

class MatchApiService extends CrudApiService {
  Future<List<MatchApiModel>> getMatches() async {
    final decodedBody = await getModels<JsonAndHttpConverter>(matchApi, null);
    return decodedBody.map((model) => model as MatchApiModel).toList();
  }

  Future<List<MatchApiModel>> getMatchesBySeason(int seasonId) async {
    final queryParameters = {
      'seasonId': seasonId.toString(),
    };
    final decodedBody =
        await getModels<JsonAndHttpConverter>(matchApi, queryParameters);
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

  Future<MatchSetup> setupMatch(int? id) async {
    final String url = id == null
        ? "$serverUrl/match/setup"
        : "$serverUrl/match/setup?matchId=$id";
    final MatchSetup matchSetup = await executeGetRequest(
        Uri.parse(url), (dynamic json) => MatchSetup.fromJson(json), null);
    return matchSetup;
  }
}
