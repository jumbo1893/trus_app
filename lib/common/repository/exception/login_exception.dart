
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'model/error_response.dart';

class LoginException implements Exception {
  String cause;

  LoginException([this.cause = 'Nelze načíst data z důvodu chyby na straně serveru']);

  @override
  String toString() {
    return cause;
  }
}