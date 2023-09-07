
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'login_exception.dart';
import 'model/error_response.dart';

class ServerException implements Exception {
  String cause;

  ServerException([this.cause = 'Nelze načíst data z důvodu chyby na straně serveru']);

  @override
  String toString() {
    return cause;
  }
}