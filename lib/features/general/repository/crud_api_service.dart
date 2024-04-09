import 'dart:convert';

import 'package:trus_app/config.dart';

import '../../../common/repository/exception/json_decode_exception.dart';
import '../../../models/api/fine_api_model.dart';
import '../../../models/api/goal/goal_api_model.dart';
import '../../../models/api/interfaces/json_and_http_converter.dart';
import '../../../models/api/match/match_api_model.dart';
import '../../../models/api/notification_api_model.dart';
import '../../../models/api/pkfl/pkfl_all_individual_stats.dart';
import '../../../models/api/pkfl/pkfl_match_api_model.dart';
import '../../../models/api/pkfl/pkfl_player_api_model.dart';
import '../../../models/api/pkfl/pkfl_table_team.dart';
import '../../../models/api/player_api_model.dart';
import '../../../models/api/receivedfine/received_fine_api_model.dart';
import '../../../models/api/season_api_model.dart';
import '../../../models/api/step/step_api_model.dart';
import '../../../models/api/user_api_model.dart';
import '../../general/repository/request_executor.dart';

class CrudApiService extends RequestExecutor {
  ///mapuje json na objecty podle parametru apiClass
  JsonAndHttpConverter _mapToModel(Map<String, dynamic> json, String apiClass) {
    switch (apiClass) {
      case matchApi:
        return MatchApiModel.fromJson(json);
      case playerApi:
        return PlayerApiModel.fromJson(json);
      case seasonApi:
        return SeasonApiModel.fromJson(json);
      case fineApi:
        return FineApiModel.fromJson(json);
      case goalApi:
        return GoalApiModel.fromJson(json);
      case receivedFineApi:
        return ReceivedFineApiModel.fromJson(json);
      case authApi:
        return UserApiModel.fromJson(json);
      case notificationApi:
        return NotificationApiModel.fromJson(json);
      case pkflApi:
        return PkflMatchApiModel.fromJson(json);
      case pkflAllIndividualStatsApi:
        return PkflAllIndividualStats.fromJson(json);
      case pkflPlayerApi:
        return PkflPlayerApiModel.fromJson(json);
      case pkflTableApi:
        return PkflTableTeam.fromJson(json);
      case stepApi:
        return StepApiModel.fromJson(json);
      default:
        throw JsonDecodeException();
    }
  }

  ///get request na server
  ///
  /// [apiClass] třída na kterou posíláme req
  /// [queryParameters] parametry requestu
  /// vrací list modelů zabalené v classe JsonAndHttpConverter
  Future<List<T>> getModels<T extends JsonAndHttpConverter>(
      String apiClass, Map<String, String?>? queryParameters) async {
    final decodedBody = await executeGetRequest<List<JsonAndHttpConverter>>(
        Uri.parse("$serverUrl/$apiClass/get-all"),
        (dynamic body) => (body as List<dynamic>)
            .map((e) => _mapToModel(e as Map<String, dynamic>, apiClass) as T)
            .toList(),
        queryParameters);
    return decodedBody.cast<T>();
  }

  ///get request na server
  ///
  /// [apiClass] třída na kterou posíláme req
  /// [queryParameters] parametry requestu
  /// vrací list modelů zabalené v classe JsonAndHttpConverter
  Future<List<T>> getModelsWithoutGetAll<T extends JsonAndHttpConverter>(
      String apiClass, Map<String, String?>? queryParameters) async {
    final decodedBody = await executeGetRequest<List<JsonAndHttpConverter>>(
        Uri.parse("$serverUrl/$apiClass"),
            (dynamic body) => (body as List<dynamic>)
            .map((e) => _mapToModel(e as Map<String, dynamic>, apiClass) as T)
            .toList(),
        queryParameters);
    return decodedBody.cast<T>();
  }

  ///get request na server
  /// místo get-all máme variabilní endpoint
  /// [apiClass] třída na kterou posíláme req
  /// [queryParameters] parametry requestu
  /// vrací list modelů zabalené v classe JsonAndHttpConverter
  Future<List<T>> getModelsWithVariableEndpoint<T extends JsonAndHttpConverter>(
      String apiClass,
      Map<String, String>? queryParameters,
      String endpoint) async {
    final decodedBody = await executeGetRequest<List<JsonAndHttpConverter>>(
        Uri.parse("$serverUrl/$apiClass/$endpoint"),
            (dynamic body) => (body as List<dynamic>)
            .map((e) => _mapToModel(e as Map<String, dynamic>, apiClass) as T)
            .toList(),
        queryParameters);
    return decodedBody.cast<T>();
  }

  ///post request na server
  ///
  /// [model] JsonAndHttpConverter model který chceme přidat
  /// vrací model v classe JsonAndHttpConverter
  Future<T> addModel<T extends JsonAndHttpConverter>(
      JsonAndHttpConverter model) async {
    final Map<String, dynamic> requestPayload = model.toJson();
    final String url = "$serverUrl/${model.httpRequestClass()}/add";
    final T response = await executePostRequest(
        Uri.parse(url),
            (dynamic body) =>
        _mapToModel(body as Map<String, dynamic>, model.httpRequestClass())
        as T,
        jsonEncode(requestPayload));
    return response;
  }

  ///put request na server
  ///
  /// [model] JsonAndHttpConverter model který chceme přidat
  /// [id] id modelu, který chceme změnit
  /// vrací model v classe JsonAndHttpConverter
  Future<T> editModel<T extends JsonAndHttpConverter>(
      JsonAndHttpConverter model, int id) async {
    final Map<String, dynamic> requestPayload = model.toJson();
    final String url = "$serverUrl/${model.httpRequestClass()}/$id";

    final T response = await executePutRequest(
        Uri.parse(url),
            (dynamic body) =>
        _mapToModel(body as Map<String, dynamic>, model.httpRequestClass())
        as T,
        jsonEncode(requestPayload));
    return response;
  }

  ///delete request na server
  ///
  /// [id] id modelu, který chceme smazat
  /// [apiClass] třída na kterou posíláme req
  /// vrací true či vyhodí výjimku
  Future<bool> deleteModel(int id, String apiClass) async {
    final String url = "$serverUrl/$apiClass/$id";

    final bool isDeleted = await executeDeleteRequest(
        Uri.parse(url),
            (_) => true,
      jsonEncode(null)
    );
    return isDeleted;
  }

  String? intToString(int? number) {
    if (number == null) {
      return null;
    }
    return number.toString();
  }

  String? boolToString(bool? boolean) {
    if (boolean == null) {
      return null;
    }
    return boolean.toString();
  }
}
