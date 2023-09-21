import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../common/repository/cookies/cookie_manager.dart';
import '../../../common/repository/cookies/custom_cookie_manager.dart';
import '../../../common/repository/exception/handler/response_validator.dart';
import '../../../common/repository/exception/login_exception.dart';
import '../../../common/repository/exception/model/login_expired_exception.dart';
import '../../../config.dart';
import '../../../models/api/user_api_model.dart';

class RequestExecutor extends ResponseValidator {

  FirebaseAuth auth = FirebaseAuth.instance;

  CustomCookieManager cookieJar = CookieManager().cookieJar;

  ///[request] request do kterým se ptáme
  /// [mapFunction] mapování na které se namapuje response
  Future<T> _executeRequest<T extends dynamic>(Future<http.Response> Function() request, T Function(dynamic) mapFunction, bool secondTry) async {
    dynamic response;
    try {
      response = await request();
      validateStatusCode(response);
      cookieJar.updateCookie(response);
      if (response.body.isNotEmpty) {
        final decodedBody = json.decode(utf8.decode(response.bodyBytes));
        return mapFunction(decodedBody);
      }
    } catch (e, stack) {
      if(e is LoginExpiredException && !secondTry) {
        if(auth.currentUser==null) {
          throw LoginException("Byl jste automaticky odhlášen, nelze pokračovat");
        }
        await reLoginToServer(auth.currentUser!.email!, auth.currentUser!.uid);
        return await _executeRequest(request, mapFunction, true);
      }
      else {
        print(e);
        print(stack);
        rethrow;
      }
    }
      return mapFunction(response);
  }



  Future<T> executeGetRequest<T extends dynamic>(Uri uri, T Function(dynamic) mapFunction, Map<String, String?>? queryParameters) async {
    return await _executeRequest(
          () =>
          http.get(
            uri.replace(queryParameters: queryParameters),
            headers: {...cookieJar.getCookies(), 'Content-Type': 'application/json; charset=UTF-8'},
          ),
      mapFunction, false
    );
  }

  Future<T> executePostRequest<T extends dynamic>(Uri uri, T Function(dynamic) mapFunction, Object body) async {
    return await _executeRequest(
          () =>
          http.post(
            uri,
            headers: {...cookieJar.getCookies(), 'Content-Type': 'application/json; charset=UTF-8'},
            body: body,
          ),
      mapFunction, false
    );
  }

  Future<T> executePutRequest<T extends dynamic>(Uri uri, T Function(dynamic) mapFunction, Object body) async {
    return await _executeRequest(
          () =>
          http.put(
            uri,
            headers: {...cookieJar.getCookies(), 'Content-Type': 'application/json; charset=UTF-8'},
            body: body,
          ),
      mapFunction, false
    );
  }

  Future<T> executeDeleteRequest<T extends dynamic>(Uri uri, T Function(dynamic) mapFunction, Object? body) async {
    return await _executeRequest(
          () =>
          http.delete(
            uri,
            headers: {...cookieJar.getCookies(), 'Content-Type': 'application/json; charset=UTF-8'},
            body: body,
          ),
      mapFunction, false
    );
  }

  Future<void> reLoginToServer(
      String email, String password) async {
    var url = Uri.parse("$serverUrl/$authApi/auth");
    UserApiModel user = UserApiModel(password: password, mail: email);
    await executePostRequest(
        url,
            (dynamic json) => UserApiModel.fromJson(json),
        jsonEncode(user.toJson()));
  }
}