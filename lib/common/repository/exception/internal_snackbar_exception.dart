
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'model/error_response.dart';

class InternalSnackBarException implements Exception {
  String cause;

  InternalSnackBarException([this.cause = 'Nelze provést operaci']);

  @override
  String toString() {
    return cause;
  }
}