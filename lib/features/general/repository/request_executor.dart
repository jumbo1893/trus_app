import 'dart:async';
import 'dart:convert';
import 'dart:io' show HttpClient, Platform, X509Certificate;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'package:native_dio_adapter/native_dio_adapter.dart';
import 'package:trus_app/common/repository/exception/client_timeout_exception.dart';
import 'package:trus_app/config.dart';
import 'package:trus_app/features/general/repository/queue/queued_request.dart';

import '../../../common/repository/exception/handler/response_validator.dart';
import '../../../common/repository/exception/login_exception.dart';
import '../../../common/repository/exception/model/login_expired_exception.dart';
import '../../../common/repository/header/cookies/header_provider.dart';
import '../../../models/api/auth/user_api_model.dart';

final requestExecutorProvider = Provider<RequestExecutor>((ref) {
  return RequestExecutor(ref);
});

class RequestExecutor extends ResponseValidator {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final Ref ref;

  RequestExecutor(this.ref);

  HeaderProvider get _headerProvider => HeaderProvider(ref);

  final Duration timeoutDuration = const Duration(seconds: 30);

  //final List<Future<void> Function()> _requestQueue = [];

  http.Client getClient() {
    if (isTestEnvironment()) {
      HttpClient httpClient = HttpClient();
      httpClient.badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
      return IOClient(httpClient);
    }
    if (Platform.isIOS) {
      final config = URLSessionConfiguration.ephemeralSessionConfiguration()
        ..allowsCellularAccess = true
        ..allowsConstrainedNetworkAccess = true
        ..allowsExpensiveNetworkAccess = true;
      return CupertinoClient.fromSessionConfiguration(config);
    } else {
      return IOClient(); // Uses an HTTP client based on dart:io
    }
  }

  bool isTestEnvironment() {
    return serverUrl != prodUrl;
  }

  ///[request] request do kterým se ptáme
  /// [mapFunction] mapování na které se namapuje response
  Future<T> _executeRequest<T extends dynamic>(
      Future<http.Response> Function(http.Client) request,
      T Function(dynamic) mapFunction,
      bool secondTry) async {
    final client = getClient();
    dynamic response;
    // _requestQueue.add(() async => _executeRequest(request, mapFunction, false));
    try {
      response = await request(client).timeout(timeoutDuration);
      validateStatusCode(response);
      _headerProvider.cookieJar.updateCookie(response);
      if (response.body.isNotEmpty) {
        final decodedBody = json.decode(utf8.decode(response.bodyBytes));
        return mapFunction(decodedBody);
      }
    }
    catch (e, stack) {
      if (e is LoginExpiredException && !secondTry) {
        if (auth.currentUser == null) {
          throw LoginException(
              "Byl jste automaticky odhlášen, nelze pokračovat");
        }
        await reLoginToServer(auth.currentUser!.email!, auth.currentUser!.uid);
        return await _executeRequest(request, mapFunction, true);
      }
      if (e is TimeoutException || e is http.ClientException) {
        _enqueueRequest(request, mapFunction);
        throw ClientTimeoutException();
      }
      else {
        print(e);
        print(stack);
        rethrow;
      }
    }
    return mapFunction(response);
  }


  Future<T> executeGetRequest<T extends dynamic>(Uri uri,
      T Function(dynamic) mapFunction,
      Map<String, String?>? queryParameters) async {
    final headers = await _headerProvider.getHeaders();
    return await _executeRequest(
            (client) =>
            client.get(
              uri.replace(queryParameters: queryParameters),
              headers: headers,
            ),
        mapFunction, false
    );
  }


  Future<T> executePostRequest<T extends dynamic>(Uri uri,
      T Function(dynamic) mapFunction,
      Object body) async {
    final headers = await _headerProvider.getHeaders();
    return await _executeRequest(
            (client) =>
            client.post(
              uri,
              headers: headers,
              body: body,
            ),
        mapFunction, false
    );
  }


  Future<T> executePutRequest<T extends dynamic>(Uri uri,
      T Function(dynamic) mapFunction,
      Object body) async {
    final headers = await _headerProvider.getHeaders();
    return await _executeRequest(
            (client) =>
            client.put(
              uri,
              headers: headers,
              body: body,
            ),
        mapFunction, false
    );
  }


  Future<T> executeDeleteRequest<T extends dynamic>(Uri uri,
      T Function(dynamic) mapFunction,
      Object? body) async {
    final headers = await _headerProvider.getHeaders();
    return await _executeRequest(
            (client) =>
            client.delete(
              uri,
              headers: headers,
              body: body,
            ),
        mapFunction, false
    );
  }


  Future<void> reLoginToServer(String email, String password) async {
    var url = Uri.parse("$serverUrl/$authApi/auth");
    UserApiModel user = UserApiModel(password: password, mail: email);
    await executePostRequest(url, (dynamic json) => UserApiModel.fromJson(json),
        jsonEncode(user.toJson()));
  }

  final List<QueuedRequest> _queuedRequests = [];

  void _enqueueRequest<T>(Future<http.Response> Function(http.Client) request,
      T Function(dynamic) mapFunction,) {
    _queuedRequests.add(
        QueuedRequest<T>(request: request, mapFunction: mapFunction));
  }

  Future<void> retryQueuedRequests() async {
    final requests = List.of(_queuedRequests);
    _queuedRequests.clear();

    for (final req in requests) {
      try {
        await _executeRequest(req.request, req.mapFunction, false);
      } catch (e) {
        print("Retry request failed: $e");
      }
    }
  }
}
