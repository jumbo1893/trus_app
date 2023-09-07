import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:trus_app/common/repository/exception/server_exception.dart';
import '../../../../common/repository/exception/json_decode_exception.dart';
import 'dart:convert';
import '../../../common/repository/cookies/cookie_manager.dart';
import '../../../common/repository/cookies/custom_cookie_manager.dart';
import '../../../common/repository/exception/handler/response_validator.dart';

class RequestExecutor extends ResponseValidator {

  CustomCookieManager cookieJar = CookieManager().cookieJar;

  ///[request] request do kterým se ptáme
  /// [mapFunction] mapování na které se namapuje response
  Future<T> _executeRequest<T extends dynamic>(Future<http.Response> Function() request, T Function(dynamic) mapFunction) async {
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
      print(e);
      print(stack);
      rethrow;
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
      mapFunction,
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
      mapFunction,
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
      mapFunction,
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
      mapFunction,
    );
  }
}