
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'model/error_response.dart';
import 'model/field_model.dart';

class FieldValidationException implements Exception {
  String cause = 'Validační chyba';
  List<FieldModel>? fields;

  FieldValidationException(this.fields);


  @override
  String toString() {
    return cause;
  }
}