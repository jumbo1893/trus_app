import 'dart:convert';

import 'package:trus_app/config.dart';
import 'package:trus_app/models/api/achievement/achievement_detail.dart';
import 'package:trus_app/models/api/achievement/player_achievement_api_model.dart';
import 'package:trus_app/models/api/football/football_match_api_model.dart';
import 'package:trus_app/models/api/football/football_player_api_model.dart';
import 'package:trus_app/models/api/football/stats/football_all_individual_stats_api_model.dart';
import 'package:trus_app/models/api/football/table_team_api_model.dart';
import 'package:trus_app/models/api/footbar/footbar_account_sessions.dart';
import 'package:trus_app/models/api/log/log_api_model.dart';
import 'package:trus_app/models/api/notification/push/device_token_api_model.dart';
import 'package:trus_app/models/api/notification/push/enabled_push_notification.dart';
import 'package:trus_app/models/api/strava/athlete_activities.dart';

import '../../../common/repository/exception/json_decode_exception.dart';
import '../../../models/api/auth/user_api_model.dart';
import '../../../models/api/fine_api_model.dart';
import '../../../models/api/goal/goal_api_model.dart';
import '../../../models/api/interfaces/json_and_http_converter.dart';
import '../../../models/api/match/match_api_model.dart';
import '../../../models/api/notification/notification_api_model.dart';
import '../../../models/api/player/player_api_model.dart';
import '../../../models/api/receivedfine/received_fine_api_model.dart';
import '../../../models/api/season_api_model.dart';
import '../../../models/api/stats/stats.dart';
import '../../../models/api/step/step_api_model.dart';
import '../../general/repository/request_executor.dart';

class CrudApiService extends RequestExecutor {
  CrudApiService(super.ref);
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
      case football:
        return FootballMatchApiModel.fromJson(json);
      case footballAllIndividualStatsApi:
        return FootballAllIndividualStatsApiModel.fromJson(json);
      case footballPlayerApi:
        return FootballPlayerApiModel.fromJson(json);
      case footballTableApi:
        return TableTeamApiModel.fromJson(json);
      case stepApi:
        return StepApiModel.fromJson(json);
      case statsApi:
        return Stats.fromJson(json);
      case achievementApi:
        return AchievementDetail.fromJson(json);
      case playerAchievementApi:
        return PlayerAchievementApiModel.fromJson(json);
      case stravaApi:
        return AthleteActivities.fromJson(json);
      case tokenApi:
        return DeviceTokenApiModel.fromJson(json);
      case logApi:
        return LogApiModel.fromJson(json);
      case pushEnabledApi:
        return EnabledPushNotification.fromJson(json);
      case footbarApi:
        return FootbarAccountSessions.fromJson(json);
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
      Map<String, String?>? queryParameters,
      String endpoint) async {
    final decodedBody = await executeGetRequest<List<JsonAndHttpConverter>>(
        Uri.parse("$serverUrl/$apiClass/$endpoint"),
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
  Future<List<T>> getModelsWithVariableControllerEndpoint<T extends JsonAndHttpConverter>(
      String controllerEndpoint,
      Map<String, String?>? queryParameters,
      String apiClass) async {
    final decodedBody = await executeGetRequest<List<JsonAndHttpConverter>>(
        Uri.parse("$serverUrl/$controllerEndpoint/$apiClass"),
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
